from typing import List
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.achievement import AchievementType
from app.infrastructure.database.models import AchievementModel, UserAchievementModel
from app.infrastructure.database.repositories.base_repository import BaseRepository


class AchievementRepository(BaseRepository[AchievementModel]):
    def __init__(self, session: AsyncSession):
        super().__init__(AchievementModel, session)

    async def get_active_achievements(self) -> List[AchievementModel]:
        result = await self.session.execute(
            select(AchievementModel)
            .where(AchievementModel.is_active == True)  # noqa: E712
            .order_by(AchievementModel.condition_value)
        )
        return list(result.scalars().all())

    async def get_by_type(
        self, achievement_type: AchievementType
    ) -> List[AchievementModel]:
        result = await self.session.execute(
            select(AchievementModel)
            .where(
                AchievementModel.achievement_type == achievement_type,
                AchievementModel.is_active == True,  # noqa: E712
            )
            .order_by(AchievementModel.condition_value)
        )
        return list(result.scalars().all())


class UserAchievementRepository(BaseRepository[UserAchievementModel]):
    def __init__(self, session: AsyncSession):
        super().__init__(UserAchievementModel, session)

    async def get_by_user(self, user_id: UUID) -> List[UserAchievementModel]:
        result = await self.session.execute(
            select(UserAchievementModel)
            .where(UserAchievementModel.user_id == user_id)
            .order_by(UserAchievementModel.earned_at.desc())
        )
        return list(result.scalars().all())

    async def check_user_has_achievement(
        self, user_id: UUID, achievement_id: UUID
    ) -> bool:
        result = await self.session.execute(
            select(UserAchievementModel).where(
                UserAchievementModel.user_id == user_id,
                UserAchievementModel.achievement_id == achievement_id,
            )
        )
        return result.scalar_one_or_none() is not None

    async def get_unnotified_achievements(
        self, user_id: UUID
    ) -> List[UserAchievementModel]:
        result = await self.session.execute(
            select(UserAchievementModel)
            .where(
                UserAchievementModel.user_id == user_id,
                UserAchievementModel.notified == False,  # noqa: E712
            )
            .order_by(UserAchievementModel.earned_at)
        )
        return list(result.scalars().all())

    async def mark_as_notified(self, user_achievement_id: UUID) -> bool:
        user_achievement = await self.get_by_id(user_achievement_id)
        if user_achievement:
            user_achievement.notified = True  # type: ignore[assignment]
            await self.update(user_achievement)
            return True
        return False
