from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.domain.services.achievement_service import AchievementService
from app.schemas.achievement import (
    AchievementProgressResponse,
    AchievementResponse,
    AvailableAchievementsResponse,
    UserAchievementResponse,
    UserAchievementsListResponse,
)

router = APIRouter()


@router.get("", response_model=List[AchievementResponse])
async def list_all_achievements(db: AsyncSession = Depends(get_db)):
    service = AchievementService(db)

    achievements = await service.achievement_repo.get_active_achievements()

    return [
        AchievementResponse(
            id=ach.id,  # type: ignore[arg-type]
            name=ach.name,  # type: ignore[arg-type]
            description=ach.description,  # type: ignore[arg-type]
            icon=ach.icon,  # type: ignore[arg-type]
            type=ach.achievement_type,  # type: ignore[arg-type]
            condition_value=ach.condition_value,  # type: ignore[arg-type]
            reward_points=ach.reward_points,  # type: ignore[arg-type]
            is_active=ach.is_active,  # type: ignore[arg-type]
        )
        for ach in achievements
    ]


@router.get("/user/{user_id}", response_model=UserAchievementsListResponse)
async def get_user_achievements(user_id: UUID, db: AsyncSession = Depends(get_db)):
    service = AchievementService(db)

    user_achievements = await service.get_user_achievements(user_id)

    enriched_achievements = []
    for ua in user_achievements:
        achievement = await service.achievement_repo.get_by_id(ua.achievement_id)  # type: ignore[arg-type]

        enriched_achievements.append(
            UserAchievementResponse(
                id=ua.id,  # type: ignore[arg-type]
                user_id=ua.user_id,  # type: ignore[arg-type]
                achievement_id=ua.achievement_id,  # type: ignore[arg-type]
                earned_at=ua.earned_at,  # type: ignore[arg-type]
                notified=ua.notified,  # type: ignore[arg-type]
                achievement=AchievementResponse(
                    id=achievement.id,  # type: ignore[arg-type]
                    name=achievement.name,  # type: ignore[arg-type]
                    description=achievement.description,  # type: ignore[arg-type]
                    icon=achievement.icon,  # type: ignore[arg-type]
                    type=achievement.achievement_type,  # type: ignore[arg-type]
                    condition_value=achievement.condition_value,  # type: ignore[arg-type]
                    reward_points=achievement.reward_points,  # type: ignore[arg-type]
                    is_active=achievement.is_active,  # type: ignore[arg-type]
                )
                if achievement
                else None,
            )
        )

    return UserAchievementsListResponse(
        user_id=user_id,
        earned_achievements=enriched_achievements,
        total_earned=len(enriched_achievements),
    )


@router.get("/user/{user_id}/progress", response_model=AvailableAchievementsResponse)
async def get_achievements_progress(user_id: UUID, db: AsyncSession = Depends(get_db)):
    service = AchievementService(db)

    achievements_data = await service.get_available_achievements(user_id)

    achievements = [
        AchievementProgressResponse(
            id=UUID(ach["id"]),
            name=ach["name"],
            description=ach["description"],
            icon=ach["icon"],
            type=ach["type"],
            condition_value=ach["condition_value"],
            reward_points=ach["reward_points"],
            is_earned=ach["is_earned"],
            progress=ach["progress"],
            progress_percent=ach["progress_percent"],
        )
        for ach in achievements_data
    ]

    total_earned = sum(1 for ach in achievements if ach.is_earned)

    return AvailableAchievementsResponse(
        achievements=achievements,
        total_available=len(achievements),
        total_earned=total_earned,
    )


@router.post("/user/{user_id}/check", status_code=status.HTTP_200_OK)
async def check_new_achievements(user_id: UUID, db: AsyncSession = Depends(get_db)):
    service = AchievementService(db)

    new_achievements = await service.check_and_award_achievements(user_id)

    return {
        "user_id": str(user_id),
        "new_achievements_count": len(new_achievements),
        "new_achievements": [
            {
                "achievement_id": str(ua.achievement_id),
                "earned_at": ua.earned_at.isoformat(),
            }
            for ua in new_achievements
        ],
    }
