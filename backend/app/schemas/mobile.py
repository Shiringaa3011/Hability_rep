from datetime import date, datetime, time
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field


class GroupCreateRequest(BaseModel):
    user_id: UUID
    name: str = Field(min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)


class GroupResponse(BaseModel):
    id: UUID
    name: str
    description: Optional[str]
    created_by: UUID
    created_at: datetime
    is_active: bool
    habits_count: int = Field(default=0)


class GroupMemberResponse(BaseModel):
    id: UUID
    user_id: UUID
    username: str
    points: int
    reactions: int
    joined_at: datetime


class GroupDetailResponse(BaseModel):
    group: GroupResponse
    members: List[GroupMemberResponse]
    group_achievements: List[str]


class HabitCreateUpdateRequest(BaseModel):
    user_id: UUID
    title: str = Field(min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)
    group_id: Optional[UUID] = None
    frequency: str = Field(default="daily", pattern="^(daily|weekly)$")
    scheduled_time: Optional[time] = None
    reminders_enabled: bool = False
    reminder_time: Optional[time] = None
    day_of_week: Optional[int] = Field(None, ge=1, le=7, description="1=Monday, 7=Sunday for weekly habits")


class HabitResponse(BaseModel):
    id: UUID
    user_id: UUID
    title: str
    description: Optional[str]
    group_id: Optional[UUID]
    group_name: Optional[str]
    frequency: str
    scheduled_time: Optional[str]
    completed_today: bool
    reminders_enabled: bool
    reminder_time: Optional[str]
    day_of_week: Optional[int] = None


class DayHabitsResponse(BaseModel):
    habits: List[HabitResponse]


class NotificationSettingsResponse(BaseModel):
    allow_notifications: bool
    sound_enabled: bool
    vibration_enabled: bool


class NotificationSettingsUpdateRequest(BaseModel):
    user_id: UUID
    allow_notifications: bool
    sound_enabled: bool
    vibration_enabled: bool


class NotificationItemResponse(BaseModel):
    id: UUID
    title: str
    body: str
    received_at: datetime
    read: bool


class NotificationHistoryResponse(BaseModel):
    items: List[NotificationItemResponse]


class NotificationSendRequest(BaseModel):
    user_id: UUID
    title: str = Field(min_length=1, max_length=40)
    body: str = Field(min_length=1, max_length=120)
    kind: str = "info"
    group_id: Optional[UUID] = None


class HabitCompletionToggleRequest(BaseModel):
    day: date
    completed: bool


class GroupInviteCreateRequest(BaseModel):
    group_id: UUID
    from_user_id: UUID
    to_username: str = Field(min_length=1, max_length=100)


class GroupInviteResponse(BaseModel):
    id: UUID
    group_id: UUID
    group_name: str
    from_user_id: UUID
    from_username: str
    to_user_id: UUID
    status: str
    created_at: datetime


class GroupInviteDecisionRequest(BaseModel):
    user_id: UUID
    accept: bool


class RegisterRequest(BaseModel):
    email: str = Field(min_length=5, max_length=255)
    password: str = Field(min_length=6, max_length=128)
    username: Optional[str] = Field(default=None, max_length=100)


class RegisterResponse(BaseModel):
    user_id: UUID
    username: str
    email: str

class FcmTokenRequest(BaseModel):
    user_id: UUID
    fcm_token: str

class SendCodeRequest(BaseModel):
    email: str

class VerifyCodeRequest(BaseModel):
    email: str
    code: str = Field(min_length=6, max_length=6)

class LoginRequest(BaseModel):
    email: str
    password: str