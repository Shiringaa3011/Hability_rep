from datetime import date, datetime, time, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.domain.models.habit import HabitFrequency
from app.infrastructure.database.models import (
    GroupModel,
    HabitCompletionModel,
    HabitModel,
    NotificationModel,
    UserModel,
)
from app.schemas.mobile import (
    DayHabitsResponse,
    HabitCompletionToggleRequest,
    HabitCreateUpdateRequest,
    HabitResponse,
)

router = APIRouter()


def _time_to_label(value):
    return value.strftime("%H:%M") if value else None


@router.get("/user/{user_id}/day", response_model=DayHabitsResponse)
async def get_day_habits(
    user_id: UUID,
    day: date = Query(...),
    group_id: UUID | None = Query(default=None),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(UserModel, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    stmt = select(HabitModel).where(
        HabitModel.user_id == user_id,
        HabitModel.is_active == True,  # noqa: E712
    )
    if group_id:
        stmt = stmt.where(HabitModel.group_id == group_id)
    habits = list((await db.execute(stmt.order_by(HabitModel.created_at.desc()))).scalars().all())

    result: list[HabitResponse] = []
    for habit in habits:
        done_stmt = select(func.count(HabitCompletionModel.id)).where(
            and_(
                HabitCompletionModel.habit_id == habit.id,
                HabitCompletionModel.user_id == user_id,
                func.date(HabitCompletionModel.completed_at) == day,
            )
        )
        done = (await db.execute(done_stmt)).scalar_one() > 0
        group_name = None
        if habit.group_id:
            group = await db.get(GroupModel, habit.group_id)
            group_name = group.name if group else None
        result.append(
            HabitResponse(
                id=habit.id,
                user_id=habit.user_id,
                title=habit.name,
                description=habit.description,
                group_id=habit.group_id,
                group_name=group_name,
                frequency=habit.frequency.value,
                scheduled_time=_time_to_label(habit.scheduled_time),
                completed_today=done,
                reminders_enabled=bool(habit.reminder_enabled),
                reminder_time=_time_to_label(habit.reminder_time),
            )
        )
    return DayHabitsResponse(habits=result)


@router.get("/{habit_id}", response_model=HabitResponse)
async def get_habit(habit_id: UUID, db: AsyncSession = Depends(get_db)):
    habit = await db.get(HabitModel, habit_id)
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    group_name = None
    if habit.group_id:
        group = await db.get(GroupModel, habit.group_id)
        group_name = group.name if group else None
    return HabitResponse(
        id=habit.id,
        user_id=habit.user_id,
        title=habit.name,
        description=habit.description,
        group_id=habit.group_id,
        group_name=group_name,
        frequency=habit.frequency.value,
        scheduled_time=_time_to_label(habit.scheduled_time),
        completed_today=False,
        reminders_enabled=bool(habit.reminder_enabled),
        reminder_time=_time_to_label(habit.reminder_time),
    )


@router.post("", response_model=HabitResponse, status_code=status.HTTP_201_CREATED)
async def create_habit(request: HabitCreateUpdateRequest, db: AsyncSession = Depends(get_db)):
    user = await db.get(UserModel, request.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    habit = HabitModel(
        user_id=request.user_id,
        name=request.title.strip(),
        description=request.description.strip() if request.description else None,
        group_id=request.group_id,
        frequency=HabitFrequency(request.frequency),
        difficulty=2,
        target_days=30 if request.frequency == "daily" else 12,
        scheduled_time=request.scheduled_time,
        reminder_enabled=request.reminders_enabled,
        reminder_time=request.reminder_time,
        is_active=True,
    )
    db.add(habit)
    await db.flush()
    await db.refresh(habit)
    return HabitResponse(
        id=habit.id,
        user_id=habit.user_id,
        title=habit.name,
        description=habit.description,
        group_id=habit.group_id,
        group_name=None,
        frequency=habit.frequency.value,
        scheduled_time=_time_to_label(habit.scheduled_time),
        completed_today=False,
        reminders_enabled=bool(habit.reminder_enabled),
        reminder_time=_time_to_label(habit.reminder_time),
    )


@router.put("/{habit_id}", response_model=HabitResponse)
async def update_habit(
    habit_id: UUID, request: HabitCreateUpdateRequest, db: AsyncSession = Depends(get_db)
):
    habit = await db.get(HabitModel, habit_id)
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    if habit.user_id != request.user_id:
        raise HTTPException(status_code=403, detail="Access denied")

    habit.name = request.title.strip()
    habit.description = request.description.strip() if request.description else None
    habit.group_id = request.group_id
    habit.frequency = HabitFrequency(request.frequency)
    habit.target_days = 30 if request.frequency == "daily" else 12
    habit.scheduled_time = request.scheduled_time
    habit.reminder_enabled = request.reminders_enabled
    habit.reminder_time = request.reminder_time
    await db.flush()
    await db.refresh(habit)
    return HabitResponse(
        id=habit.id,
        user_id=habit.user_id,
        title=habit.name,
        description=habit.description,
        group_id=habit.group_id,
        group_name=None,
        frequency=habit.frequency.value,
        scheduled_time=_time_to_label(habit.scheduled_time),
        completed_today=False,
        reminders_enabled=bool(habit.reminder_enabled),
        reminder_time=_time_to_label(habit.reminder_time),
    )


@router.post("/{habit_id}/completion", status_code=status.HTTP_204_NO_CONTENT)
async def toggle_completion(
    habit_id: UUID,
    request: HabitCompletionToggleRequest,
    db: AsyncSession = Depends(get_db),
):
    habit = await db.get(HabitModel, habit_id)
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")

    day = request.day
    exists_stmt = select(HabitCompletionModel).where(
        HabitCompletionModel.habit_id == habit_id,
        HabitCompletionModel.user_id == habit.user_id,
        func.date(HabitCompletionModel.completed_at) == day,
    )
    existing = (await db.execute(exists_stmt)).scalar_one_or_none()

    if request.completed and existing is None:
        completion = HabitCompletionModel(
            habit_id=habit.id,
            user_id=habit.user_id,
            points_earned=10,
            current_streak=1,
            completed_at=datetime.combine(day, time.min, tzinfo=timezone.utc),
        )
        db.add(completion)
        db.add(
            NotificationModel(
                user_id=habit.user_id,
                title="Привычка выполнена",
                body=f"Отмечено выполнение «{habit.name}».",
                kind="habit_completed",
                group_id=habit.group_id,
            )
        )
        await db.flush()
    elif (not request.completed) and existing is not None:
        await db.delete(existing)
