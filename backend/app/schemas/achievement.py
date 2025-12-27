from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from app.domain.models.achievement import AchievementType


class AchievementResponse(BaseModel):
    id: UUID
    name: str = Field(..., description="Achievement name")
    description: str = Field(..., description="Achievement description")
    icon: str = Field(..., description="Achievement icon identifier")
    type: AchievementType = Field(..., description="Achievement type")
    condition_value: int = Field(..., ge=0, description="Value required to earn")
    reward_points: int = Field(..., ge=0, description="Bonus points for earning")
    is_active: bool = Field(..., description="Is achievement active")

    class Config:
        from_attributes = True


class UserAchievementResponse(BaseModel):
    id: UUID
    user_id: UUID
    achievement_id: UUID
    earned_at: datetime = Field(..., description="When achievement was earned")
    notified: bool = Field(..., description="Has user been notified")
    achievement: Optional[AchievementResponse] = Field(
        None, description="Achievement details"
    )

    class Config:
        from_attributes = True


class AchievementProgressResponse(BaseModel):
    id: UUID
    name: str
    description: str
    icon: str
    type: AchievementType
    condition_value: int = Field(..., description="Target value")
    reward_points: int
    is_earned: bool = Field(..., description="Has user earned this achievement")
    progress: int = Field(..., ge=0, description="Current progress value")
    progress_percent: float = Field(
        ..., ge=0, le=100, description="Progress percentage"
    )

    class Config:
        from_attributes = True


class UserAchievementsListResponse(BaseModel):
    user_id: UUID
    earned_achievements: List[UserAchievementResponse] = Field(
        ..., description="Earned achievements"
    )
    total_earned: int = Field(..., ge=0, description="Total achievements earned")

    class Config:
        from_attributes = True


class AvailableAchievementsResponse(BaseModel):
    achievements: List[AchievementProgressResponse] = Field(
        ..., description="All achievements"
    )
    total_available: int = Field(..., ge=0, description="Total achievements available")
    total_earned: int = Field(..., ge=0, description="Total earned by user")

    class Config:
        from_attributes = True


class ErrorResponse(BaseModel):
    detail: str = Field(..., description="Error message")

    class Config:
        from_attributes = True
