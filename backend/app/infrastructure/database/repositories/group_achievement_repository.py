from typing import List
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.group_achievement import GroupAchievementType
from app.infrastructure.database.models import (
    EarnedGroupAchievementModel,
    GroupAchievementModel,
)
from app.infrastructure.database.repositories.base_repository import BaseRepository


class GroupAchievementRepository(BaseRepository[GroupAchievementModel]):
    def __init__(self, session: AsyncSession):
        super().__init__(GroupAchievementModel, session)

    async def get_active_achievements(self) -> List[GroupAchievementModel]:
        result = await self.session.execute(
            select(GroupAchievementModel)
            .where(GroupAchievementModel.is_active == True)  # noqa: E712
            .order_by(GroupAchievementModel.condition_value)
        )
        return list(result.scalars().all())

    async def get_by_type(
        self, achievement_type: GroupAchievementType
    ) -> List[GroupAchievementModel]:
        result = await self.session.execute(
            select(GroupAchievementModel)
            .where(
                GroupAchievementModel.achievement_type == achievement_type,
                GroupAchievementModel.is_active == True,  # noqa: E712
            )
            .order_by(GroupAchievementModel.condition_value)
        )
        return list(result.scalars().all())


class EarnedGroupAchievementRepository(
    BaseRepository[EarnedGroupAchievementModel]
):
    def __init__(self, session: AsyncSession):
        super().__init__(EarnedGroupAchievementModel, session)

    async def get_by_group(
        self, group_id: UUID
    ) -> List[EarnedGroupAchievementModel]:
        result = await self.session.execute(
            select(EarnedGroupAchievementModel)
            .where(EarnedGroupAchievementModel.group_id == group_id)
            .order_by(EarnedGroupAchievementModel.earned_at.desc())
        )
        return list(result.scalars().all())

    async def check_group_has_achievement(
        self, group_id: UUID, achievement_id: UUID
    ) -> bool:
        result = await self.session.execute(
            select(EarnedGroupAchievementModel).where(
                EarnedGroupAchievementModel.group_id == group_id,
                EarnedGroupAchievementModel.achievement_id == achievement_id,
            )
        )
        return result.scalar_one_or_none() is not None

    async def get_unnotified(
        self, group_id: UUID
    ) -> List[EarnedGroupAchievementModel]:
        result = await self.session.execute(
            select(EarnedGroupAchievementModel)
            .where(
                EarnedGroupAchievementModel.group_id == group_id,
                EarnedGroupAchievementModel.notified == False,  # noqa: E712
            )
            .order_by(EarnedGroupAchievementModel.earned_at)
        )
        return list(result.scalars().all())

    async def mark_as_notified(self, earned_id: UUID) -> bool:
        earned = await self.get_by_id(earned_id)
        if earned:
            earned.notified = True  # type: ignore[assignment]
            await self.update(earned)
            return True
        return False

    async def mark_all_as_notified(self, group_id: UUID) -> int:
        unnotified = await self.get_unnotified(group_id)
        for item in unnotified:
            item.notified = True  # type: ignore[assignment]
            await self.update(item)
        return len(unnotified)
