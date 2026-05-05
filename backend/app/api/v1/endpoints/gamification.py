from uuid import UUID
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy import func, select
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

from app.domain.models.gamification import calculate_level
from app.infrastructure.services.scheduler_service import send_or_queue
from app.infrastructure.database.models import (
    UserModel,
    NotificationModel,
    HabitModel,
    GroupMemberModel,
    GroupModel,
    HabitCompletionModel,
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
                ua.achievement_id
            )
            if achievement:
                new_achievements.append(
                    NewAchievementInfo(
                        achievement_id=achievement.id,
                        name=achievement.name,
                        icon=achievement.icon,
                        reward_points=achievement.reward_points,
                    )
                )
        user = await db.get(UserModel, request.user_id)
        old_level = calculate_level(user.total_points - completion.points_earned)
        new_level = calculate_level(user.total_points)

        if new_level > old_level:
            db.add(NotificationModel(
                user_id=request.user_id,
                title="Новый уровень!",
                body=f"Вы достигли уровня {new_level}",
                kind="level_up",
            ))
            if user.fcm_token:
                await send_or_queue(
                    session=db,
                    user_id=request.user_id,
                    title="Новый уровень!",
                    body=f"Вы достигли уровня {new_level}",
                    kind="level_up",
                )

        for achievement_info in new_achievements:
            db.add(NotificationModel(
                user_id=request.user_id,
                title="Новая награда!",
                body=f"Получено достижение «{achievement_info.name}»",
                kind="achievement_unlocked",
            ))
            if user.fcm_token:
                await send_or_queue(
                    session=db,
                    user_id=request.user_id,
                    title="Новая награда!",
                    body=f"Получено достижение «{achievement_info.name}»",
                    kind="achievement_unlocked",
                )

        habit = await db.get(HabitModel, request.habit_id)
        if habit and habit.group_id:
            group_habits_stmt = select(HabitModel.id).where(
                HabitModel.group_id == habit.group_id
            )
            group_habit_ids = (await db.execute(group_habits_stmt)).scalars().all()

            if group_habit_ids:
                members_stmt = (
                    select(
                        GroupMemberModel,
                        func.coalesce(
                            func.sum(HabitCompletionModel.points_earned).filter(
                                HabitCompletionModel.habit_id.in_(group_habit_ids)
                            ),
                            0,
                        ).label("total"),
                    )
                    .outerjoin(
                        HabitCompletionModel,
                        HabitCompletionModel.user_id == GroupMemberModel.user_id,
                    )
                    .where(GroupMemberModel.group_id == habit.group_id)
                    .group_by(GroupMemberModel.id)
                    .order_by(
                        func.coalesce(
                            func.sum(HabitCompletionModel.points_earned).filter(
                                HabitCompletionModel.habit_id.in_(group_habit_ids)
                            ),
                            0,
                        ).desc()
                    )
                )
                members_rows = (await db.execute(members_stmt)).all()

            if members_rows:
                new_leader_member = members_rows[0][0]
                old_members_stmt = (
                    select(
                        GroupMemberModel,
                        func.coalesce(
                            func.sum(HabitCompletionModel.points_earned).filter(
                                HabitCompletionModel.habit_id.in_(group_habit_ids),
                                HabitCompletionModel.id != completion.id,
                            ),
                            0,
                        ).label("total"),
                    )
                    .outerjoin(
                        HabitCompletionModel,
                        HabitCompletionModel.user_id == GroupMemberModel.user_id,
                    )
                    .where(GroupMemberModel.group_id == habit.group_id)
                    .group_by(GroupMemberModel.id)
                    .order_by(
                        func.coalesce(
                            func.sum(HabitCompletionModel.points_earned).filter(
                                HabitCompletionModel.habit_id.in_(group_habit_ids),
                                HabitCompletionModel.id != completion.id,
                            ),
                            0,
                        ).desc()
                    )
                )
                old_rows = (await db.execute(old_members_stmt)).all()
                old_leader_id = old_rows[0][0].user_id if old_rows else None

                if new_leader_member.user_id == request.user_id and old_leader_id != request.user_id:
                    group = await db.get(GroupModel, habit.group_id)
                    if group:
                        db.add(NotificationModel(
                            user_id=request.user_id,
                            title="Вы стали лидером!",
                            body=f"Вы заняли первое место в группе «{group.name}»",
                            kind="new_leader",
                            group_id=group.id,
                        ))
                        if user.fcm_token:
                            await send_or_queue(
                                session=db,
                                user_id=request.user_id,
                                title="Вы стали лидером!",
                                body=f"Вы заняли первое место в группе «{group.name}»",
                                kind="new_leader",
                                group_id=group.id,
                            )

        return CompleteHabitResponse(
            completion_id=completion.id,
            habit_id=completion.habit_id,
            user_id=completion.user_id,
            completed_at=completion.completed_at,
            points_earned=completion.points_earned,
            current_streak=completion.current_streak,
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
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return level_info


@router.get("/user/{user_id}/points", response_model=UserPointsResponse)
async def get_user_points(user_id: UUID, db: AsyncSession = Depends(get_db)):
    service = GamificationService(db)
    user_repo = service.user_repo

    user = await user_repo.get_by_id(user_id)

    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return UserPointsResponse(
        user_id=user.id,
        total_points=user.total_points,
        current_level=user.current_level,
    )
