from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.domain.models.stats import StatsPeriod
from app.domain.services.stats_service import StatsService
from app.schemas.stats import (
    GroupStatsResponse,
    HabitStatsResponse,
    UserHabitsStatsResponse,
    UserStatsResponse,
)

router = APIRouter()


@router.get("/user/{user_id}", response_model=UserStatsResponse)
async def get_user_stats(
    user_id: UUID,
    period: StatsPeriod = Query(StatsPeriod.WEEK, description="Statistics period"),
    db: AsyncSession = Depends(get_db),
):
    service = StatsService(db)

    stats = await service.get_user_stats(user_id, period)

    if not stats:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found or no statistics available",
        )

    return UserStatsResponse(
        user_id=stats.user_id,
        period=stats.period,
        total_completions=stats.total_completions,
        completion_rate=stats.completion_rate,
        current_streak=stats.current_streak,
        max_streak=stats.max_streak,
        total_points_earned=stats.total_points_period,
        updated_at=stats.updated_at,
    )


@router.get("/user/{user_id}/habits", response_model=UserHabitsStatsResponse)
async def get_user_habits_stats(
    user_id: UUID,
    period: StatsPeriod = Query(StatsPeriod.WEEK, description="Statistics period"),
    db: AsyncSession = Depends(get_db),
):
    service = StatsService(db)

    habits_stats = await service.get_user_habits_stats(user_id, period)

    return UserHabitsStatsResponse(
        user_id=user_id,
        period=period,
        habits=[
            HabitStatsResponse(
                habit_id=hs.habit_id,
                habit_name=hs.habit_name,
                total_completions=hs.total_completions,
                current_streak=hs.current_streak,
                max_streak=hs.max_streak,
                total_points_earned=hs.total_points_earned,
                completion_rate=hs.completion_rate,
            )
            for hs in habits_stats
        ],
    )


@router.get("/user/{user_id}/streak/{habit_id}")
async def get_streak_info(
    user_id: UUID, habit_id: UUID, db: AsyncSession = Depends(get_db)
):
    service = StatsService(db)

    habit_stats = await service.get_habit_stats(habit_id, StatsPeriod.WEEK)

    if not habit_stats:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Habit not found"
        )

    return {
        "habit_id": str(habit_id),
        "current_streak": habit_stats.current_streak,
        "max_streak": habit_stats.max_streak,
    }


@router.get("/group/{group_id}", response_model=GroupStatsResponse)
async def get_group_stats(
    group_id: UUID,
    period: StatsPeriod = Query(StatsPeriod.WEEK, description="Statistics period"),
    db: AsyncSession = Depends(get_db),
):
    service = StatsService(db)

    stats = await service.get_group_stats(group_id, period)

    return GroupStatsResponse(
        group_id=group_id,
        period=period,
        total_completions=stats.get("total_completions", 0),
        average_completion_rate=stats.get("average_completion_rate", 0.0),
        members=stats.get("members", []),
    )
