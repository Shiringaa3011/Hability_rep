from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.domain.services.group_achievement_service import GroupAchievementService
from app.schemas.group_achievement import (
    AvailableGroupAchievementsResponse,
    EarnedGroupAchievementResponse,
    GroupAchievementProgressResponse,
    GroupAchievementResponse,
    GroupAchievementsListResponse,
)

router = APIRouter()


@router.get("", response_model=List[GroupAchievementResponse])
async def list_all_group_achievements(db: AsyncSession = Depends(get_db)):
    service = GroupAchievementService(db)
    achievements = await service.achievement_repo.get_active_achievements()

    return [
        GroupAchievementResponse(
            id=a.id,  # type: ignore[arg-type]
            name=a.name,  # type: ignore[arg-type]
            description=a.description,  # type: ignore[arg-type]
            icon=a.icon,  # type: ignore[arg-type]
            type=a.achievement_type,  # type: ignore[arg-type]
            condition_value=a.condition_value,  # type: ignore[arg-type]
            reward_points=a.reward_points,  # type: ignore[arg-type]
            is_active=a.is_active,  # type: ignore[arg-type]
        )
        for a in achievements
    ]


@router.get("/{group_id}", response_model=GroupAchievementsListResponse)
async def get_group_achievements(
    group_id: UUID, db: AsyncSession = Depends(get_db)
):
    service = GroupAchievementService(db)
    earned = await service.get_group_achievements(group_id)

    enriched = []
    for e in earned:
        achievement = await service.achievement_repo.get_by_id(
            e.achievement_id  # type: ignore[arg-type]
        )
        enriched.append(
            EarnedGroupAchievementResponse(
                id=e.id,  # type: ignore[arg-type]
                group_id=e.group_id,  # type: ignore[arg-type]
                achievement_id=e.achievement_id,  # type: ignore[arg-type]
                earned_at=e.earned_at,  # type: ignore[arg-type]
                notified=e.notified,  # type: ignore[arg-type]
                achievement=GroupAchievementResponse(
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

    return GroupAchievementsListResponse(
        group_id=group_id,
        earned_achievements=enriched,
        total_earned=len(enriched),
    )


@router.get(
    "/{group_id}/progress",
    response_model=AvailableGroupAchievementsResponse,
)
async def get_group_achievements_progress(
    group_id: UUID, db: AsyncSession = Depends(get_db)
):
    service = GroupAchievementService(db)
    data = await service.get_available_group_achievements(group_id)

    achievements = [
        GroupAchievementProgressResponse(
            id=UUID(a["id"]),
            name=a["name"],
            description=a["description"],
            icon=a["icon"],
            type=a["type"],
            condition_value=a["condition_value"],
            reward_points=a["reward_points"],
            is_earned=a["is_earned"],
            progress=a["progress"],
            progress_percent=a["progress_percent"],
        )
        for a in data
    ]

    total_earned = sum(1 for a in achievements if a.is_earned)

    return AvailableGroupAchievementsResponse(
        achievements=achievements,
        total_available=len(achievements),
        total_earned=total_earned,
    )


@router.post("/{group_id}/check", status_code=status.HTTP_200_OK)
async def check_group_achievements(
    group_id: UUID, db: AsyncSession = Depends(get_db)
):
    service = GroupAchievementService(db)
    new_achievements = await service.check_and_award_achievements(group_id)

    return {
        "group_id": str(group_id),
        "new_achievements_count": len(new_achievements),
        "new_achievements": [
            {
                "achievement_id": str(ea.achievement_id),
                "earned_at": ea.earned_at.isoformat(),
            }
            for ea in new_achievements
        ],
    }


@router.get("/{group_id}/new", response_model=GroupAchievementsListResponse)
async def get_new_group_achievements(
    group_id: UUID, db: AsyncSession = Depends(get_db)
):
    service = GroupAchievementService(db)
    unnotified = await service.earned_repo.get_unnotified(group_id)

    enriched = []
    for e in unnotified:
        achievement = await service.achievement_repo.get_by_id(
            e.achievement_id  # type: ignore[arg-type]
        )
        enriched.append(
            EarnedGroupAchievementResponse(
                id=e.id,  # type: ignore[arg-type]
                group_id=e.group_id,  # type: ignore[arg-type]
                achievement_id=e.achievement_id,  # type: ignore[arg-type]
                earned_at=e.earned_at,  # type: ignore[arg-type]
                notified=e.notified,  # type: ignore[arg-type]
                achievement=GroupAchievementResponse(
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

    return GroupAchievementsListResponse(
        group_id=group_id,
        earned_achievements=enriched,
        total_earned=len(enriched),
    )


@router.post("/{group_id}/notify", status_code=status.HTTP_200_OK)
async def mark_group_achievements_notified(
    group_id: UUID, db: AsyncSession = Depends(get_db)
):
    service = GroupAchievementService(db)
    count = await service.earned_repo.mark_all_as_notified(group_id)
    return {"group_id": str(group_id), "marked_count": count}
