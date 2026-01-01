from datetime import date, datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class CompleteHabitRequest(BaseModel):
    habit_id: UUID = Field(..., description="Habit ID")
    user_id: UUID = Field(..., description="User ID")
    completion_date: Optional[date] = Field(
        None, description="Date of completion (default: today)"
    )


class CompleteHabitResponse(BaseModel):
    completion_id: UUID = Field(..., description="Completion record ID")
    habit_id: UUID
    user_id: UUID
    completed_at: datetime
    points_earned: int = Field(..., description="Points awarded for this completion")
    current_streak: int = Field(..., description="Current streak after this completion")

    class Config:
        from_attributes = True


class UserLevelResponse(BaseModel):
    user_id: UUID
    level: int = Field(..., ge=0, description="Current level")
    total_points: int = Field(..., ge=0, description="Total points earned")
    points_to_next_level: int = Field(
        ..., ge=0, description="Points needed for next level"
    )
    progress_percent: float = Field(
        ..., ge=0, le=100, description="Progress to next level (%)"
    )

    class Config:
        from_attributes = True


class UserPointsResponse(BaseModel):
    user_id: UUID
    total_points: int = Field(..., ge=0, description="Total points earned")
    current_level: int = Field(..., ge=0, description="Current level")

    class Config:
        from_attributes = True


class StreakInfoResponse(BaseModel):
    habit_id: UUID
    current_streak: int = Field(..., ge=0, description="Current streak")
    max_streak: int = Field(..., ge=0, description="Maximum streak achieved")
    last_completion_date: Optional[str] = Field(
        None, description="Last completion date"
    )

    class Config:
        from_attributes = True
