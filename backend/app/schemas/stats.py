from datetime import datetime
from typing import List
from uuid import UUID

from pydantic import BaseModel, Field

from app.domain.models.stats import StatsPeriod


class UserStatsResponse(BaseModel):
    user_id: UUID
    period: StatsPeriod = Field(..., description="Statistics period")
    total_completions: int = Field(..., ge=0, description="Total completions in period")
    completion_rate: float = Field(..., ge=0, le=100, description="Completion rate (%)")
    current_streak: int = Field(..., ge=0, description="Current streak")
    max_streak: int = Field(..., ge=0, description="Maximum streak")
    total_points_earned: int = Field(
        ..., ge=0, description="Total points earned in period"
    )
    updated_at: datetime = Field(..., description="Last update timestamp")

    class Config:
        from_attributes = True


class HabitStatsResponse(BaseModel):
    habit_id: UUID
    habit_name: str = Field(..., description="Habit name")
    total_completions: int = Field(..., ge=0, description="Total completions")
    current_streak: int = Field(..., ge=0, description="Current streak")
    max_streak: int = Field(..., ge=0, description="Maximum streak")
    total_points_earned: int = Field(..., ge=0, description="Total points earned")
    completion_rate: float = Field(..., ge=0, le=100, description="Completion rate (%)")

    class Config:
        from_attributes = True


class UserHabitsStatsResponse(BaseModel):
    user_id: UUID
    period: StatsPeriod
    habits: List[HabitStatsResponse] = Field(
        ..., description="Statistics for each habit"
    )

    class Config:
        from_attributes = True


class GroupStatsResponse(BaseModel):
    group_id: UUID
    period: StatsPeriod
    total_completions: int = Field(..., ge=0, description="Total group completions")
    average_completion_rate: float = Field(
        ..., ge=0, le=100, description="Average completion rate (%)"
    )
    members: List[dict] = Field(..., description="Member statistics")

    class Config:
        from_attributes = True
