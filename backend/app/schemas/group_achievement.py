from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from app.domain.models.group_achievement import GroupAchievementType


class GroupAchievementResponse(BaseModel):
    id: UUID
    name: str = Field(..., description="Achievement name")
    description: str = Field(..., description="Achievement description")
    icon: str = Field(..., description="Achievement icon identifier")
    type: GroupAchievementType = Field(..., description="Group achievement type")
    condition_value: int = Field(..., ge=0)
    reward_points: int = Field(..., ge=0)
    is_active: bool

    class Config:
        from_attributes = True


class EarnedGroupAchievementResponse(BaseModel):
    id: UUID
    group_id: UUID
    achievement_id: UUID
    earned_at: datetime
    notified: bool
    achievement: Optional[GroupAchievementResponse] = None

    class Config:
        from_attributes = True


class GroupAchievementsListResponse(BaseModel):
    group_id: UUID
    earned_achievements: List[EarnedGroupAchievementResponse]
    total_earned: int = Field(..., ge=0)

    class Config:
        from_attributes = True


class GroupAchievementProgressResponse(BaseModel):
    id: UUID
    name: str
    description: str
    icon: str
    type: GroupAchievementType
    condition_value: int
    reward_points: int
    is_earned: bool
    progress: int = Field(..., ge=0)
    progress_percent: float = Field(..., ge=0, le=100)

    class Config:
        from_attributes = True


class AvailableGroupAchievementsResponse(BaseModel):
    achievements: List[GroupAchievementProgressResponse]
    total_available: int = Field(..., ge=0)
    total_earned: int = Field(..., ge=0)

    class Config:
        from_attributes = True
