from datetime import datetime, timedelta, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.infrastructure.database.models import (
    NotificationModel,
    UserModel,
    UserNotificationSettingsModel,
)
from app.schemas.mobile import (
    NotificationHistoryResponse,
    NotificationItemResponse,
    NotificationSendRequest,
    NotificationSettingsResponse,
    NotificationSettingsUpdateRequest,
)

router = APIRouter()


@router.get("/history/{user_id}", response_model=NotificationHistoryResponse)
async def get_history(user_id: UUID, db: AsyncSession = Depends(get_db)):
    user = await db.get(UserModel, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    cutoff = datetime.now(timezone.utc) - timedelta(days=30)
    stmt = (
        select(NotificationModel)
        .where(NotificationModel.user_id == user_id, NotificationModel.created_at >= cutoff)
        .order_by(NotificationModel.created_at.desc())
    )
    rows = (await db.execute(stmt)).scalars().all()
    return NotificationHistoryResponse(
        items=[
            NotificationItemResponse(
                id=n.id,
                title=n.title,
                body=n.body,
                received_at=n.created_at,
                read=bool(n.read),
            )
            for n in rows
        ]
    )


@router.post("/mark-read/{notification_id}", status_code=status.HTTP_204_NO_CONTENT)
async def mark_read(notification_id: UUID, db: AsyncSession = Depends(get_db)):
    notification = await db.get(NotificationModel, notification_id)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    notification.read = True
    await db.flush()


@router.get("/settings/{user_id}", response_model=NotificationSettingsResponse)
async def get_settings(user_id: UUID, db: AsyncSession = Depends(get_db)):
    settings = (
        await db.execute(
            select(UserNotificationSettingsModel).where(
                UserNotificationSettingsModel.user_id == user_id
            )
        )
    ).scalar_one_or_none()
    if settings is None:
        settings = UserNotificationSettingsModel(
            user_id=user_id,
            allow_notifications=True,
            sound_enabled=True,
            vibration_enabled=True,
        )
        db.add(settings)
        await db.flush()
    return NotificationSettingsResponse(
        allow_notifications=bool(settings.allow_notifications),
        sound_enabled=bool(settings.sound_enabled),
        vibration_enabled=bool(settings.vibration_enabled),
    )


@router.put("/settings", response_model=NotificationSettingsResponse)
async def update_settings(
    request: NotificationSettingsUpdateRequest, db: AsyncSession = Depends(get_db)
):
    settings = (
        await db.execute(
            select(UserNotificationSettingsModel).where(
                UserNotificationSettingsModel.user_id == request.user_id
            )
        )
    ).scalar_one_or_none()
    if settings is None:
        settings = UserNotificationSettingsModel(user_id=request.user_id)
        db.add(settings)
    settings.allow_notifications = request.allow_notifications
    settings.sound_enabled = request.sound_enabled
    settings.vibration_enabled = request.vibration_enabled
    await db.flush()
    return NotificationSettingsResponse(
        allow_notifications=bool(settings.allow_notifications),
        sound_enabled=bool(settings.sound_enabled),
        vibration_enabled=bool(settings.vibration_enabled),
    )


@router.post("/send", status_code=status.HTTP_201_CREATED)
async def send_notification(request: NotificationSendRequest, db: AsyncSession = Depends(get_db)):
    user = await db.get(UserModel, request.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    notification = NotificationModel(
        user_id=request.user_id,
        title=request.title,
        body=request.body,
        kind=request.kind,
        group_id=request.group_id,
        read=False,
    )
    db.add(notification)
    await db.flush()
    return {"id": str(notification.id)}


@router.get("/unread-count/{user_id}")
async def unread_count(user_id: UUID, db: AsyncSession = Depends(get_db)):
    stmt = select(NotificationModel).where(
        NotificationModel.user_id == user_id,
        NotificationModel.read == False,  # noqa: E712
    )
    rows = (await db.execute(stmt)).scalars().all()
    return {"count": len(rows)}
