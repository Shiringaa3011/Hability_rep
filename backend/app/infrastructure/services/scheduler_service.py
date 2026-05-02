from datetime import datetime, time, timedelta, timezone
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from sqlalchemy import select

from app.core.database import async_session_factory
from app.infrastructure.database.models import (
    HabitModel,
    UserModel,
    NotificationModel,
    PendingNotificationModel,
)
from app.infrastructure.services.fcm_service import send_push_notification

scheduler = AsyncIOScheduler()


async def check_habit_reminders():
    """Проверяет привычки и отправляет напоминания"""
    now = datetime.now(timezone.utc)
    current_time = now.time()
    current_weekday = now.isoweekday()
    today_end = now.replace(hour=23, minute=59, second=59, microsecond=0)

    async with async_session_factory() as session:
        stmt = select(HabitModel).where(
            HabitModel.is_active == True,
            HabitModel.reminder_enabled == True,
        )
        habits = (await session.execute(stmt)).scalars().all()

        for habit in habits:
            if habit.frequency == 'weekly':
                if habit.day_of_week != current_weekday:
                    continue

            if habit.reminder_time is not None:
                reminder_time = habit.reminder_time
            elif habit.scheduled_time is not None:
                reminder_dt = datetime.combine(now.date(), habit.scheduled_time) - timedelta(minutes=30)
                reminder_time = reminder_dt.time()
            else:
                reminder_time = time(12, 0)

            if reminder_time.hour != current_time.hour or reminder_time.minute != current_time.minute:
                continue

            await send_or_queue(
                session=session,
                user_id=habit.user_id,
                title="Напоминание о привычке",
                body=f"Не забудьте выполнить «{habit.name}»",
                kind="habit_reminder",
                expires_at=today_end,
            )

        await session.commit()


async def process_pending_notifications():
    """Обработать очередь отложенных уведомлений"""
    now = datetime.now(timezone.utc)

    async with async_session_factory() as session:
        expired_stmt = select(PendingNotificationModel).where(
            PendingNotificationModel.delivered == False,
            PendingNotificationModel.expires_at < now,
        )
        expired = (await session.execute(expired_stmt)).scalars().all()
        for p in expired:
            await session.delete(p)

        pending_stmt = select(PendingNotificationModel).where(
            PendingNotificationModel.delivered == False,
            PendingNotificationModel.scheduled_for <= now,
            PendingNotificationModel.expires_at > now,
        )
        pending = (await session.execute(pending_stmt)).scalars().all()

        for p in pending:
            user = await session.get(UserModel, p.user_id)
            if user and user.fcm_token:
                success = await send_push_notification(
                    device_token=user.fcm_token,
                    title=p.title,
                    body=p.body,
                )
                if success:
                    p.delivered = True
                    session.add(NotificationModel(
                        user_id=p.user_id,
                        title=p.title,
                        body=p.body,
                        kind=p.kind,
                    ))

        await session.commit()


async def send_or_queue(session, user_id, title, body, kind, expires_at=None, group_id=None):
    """Отправить push или сохранить в очередь"""
    user = await session.get(UserModel, user_id)
    now = datetime.now(timezone.utc)

    if expires_at is None:
        expires_at = now + timedelta(hours=24)

    if user and user.fcm_token:
        success = await send_push_notification(
            device_token=user.fcm_token,
            title=title,
            body=body,
        )
        if success:
            session.add(NotificationModel(
                user_id=user_id,
                title=title,
                body=body,
                kind=kind,
                group_id=group_id,
            ))
            return

    session.add(PendingNotificationModel(
        user_id=user_id,
        title=title,
        body=body,
        kind=kind,
        scheduled_for=now,
        expires_at=expires_at,
    ))


def start_scheduler():
    """Запустить планировщик"""
    scheduler.add_job(
        check_habit_reminders,
        CronTrigger(minute='*'),
        id='habit_reminders',
        replace_existing=True,
    )
    scheduler.add_job(
        process_pending_notifications,
        CronTrigger(second='30'),
        id='pending_notifications',
        replace_existing=True,
    )
    scheduler.start()


def stop_scheduler():
    """Остановить планировщик"""
    if scheduler.running:
        scheduler.shutdown(wait=False)