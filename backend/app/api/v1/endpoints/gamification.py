from uuid import UUID
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.domain.services.achievement_service import AchievementService
from app.domain.services.gamification_service import GamificationService
from app.schemas.gamification import (
    CompleteHabitRequest,
    CompleteHabitResponse,
    NewAchievementInfo,
    UserLevelResponse,
    UserPointsResponse,
)

router = APIRouter()


@router.post(
    "/complete-habit",
    response_model=CompleteHabitResponse,
    status_code=status.HTTP_201_CREATED,
)
async def complete_habit(
    request: CompleteHabitRequest, db: AsyncSession = Depends(get_db)
):
    service = GamificationService(db)

    try:
        completion, _ = await service.process_habit_completion(
            habit_id=request.habit_id,
            user_id=request.user_id,
            completion_date=request.completion_date,
        )

        achievement_service = AchievementService(db)
        newly_awarded = await achievement_service.check_and_award_achievements(
            request.user_id
        )

        new_achievements = []
        for ua in newly_awarded:
            achievement = await achievement_service.achievement_repo.get_by_id(
                ua.achievement_id  # type: ignore[arg-type]
            )
            if achievement:
                new_achievements.append(
                    NewAchievementInfo(
                        achievement_id=achievement.id,  # type: ignore[arg-type]
                        name=achievement.name,  # type: ignore[arg-type]
                        icon=achievement.icon,  # type: ignore[arg-type]
                        reward_points=achievement.reward_points,  # type: ignore[arg-type]
                    )
                )

        return CompleteHabitResponse(
            completion_id=completion.id,  # type: ignore[arg-type]
            habit_id=completion.habit_id,  # type: ignore[arg-type]
            user_id=completion.user_id,  # type: ignore[arg-type]
            completed_at=completion.completed_at,  # type: ignore[arg-type]
            points_earned=completion.points_earned,  # type: ignore[arg-type]
            current_streak=completion.current_streak,  # type: ignore[arg-type]
            new_achievements=new_achievements,
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to complete habit: {str(e)}",
        )


@router.get("/user/{user_id}/level", response_model=UserLevelResponse)
async def get_user_level(user_id: UUID, db: AsyncSession = Depends(get_db)):
    service = GamificationService(db)

    level_info = await service.get_user_level(user_id)

    if not level_info:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    return level_info


@router.get("/user/{user_id}/points", response_model=UserPointsResponse)
async def get_user_points(user_id: UUID, db: AsyncSession = Depends(get_db)):
    service = GamificationService(db)
    user_repo = service.user_repo

    user = await user_repo.get_by_id(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    return UserPointsResponse(
        user_id=user.id,  # type: ignore[arg-type]
        total_points=user.total_points,  # type: ignore[arg-type]
        current_level=user.current_level,  # type: ignore[arg-type]
    )
