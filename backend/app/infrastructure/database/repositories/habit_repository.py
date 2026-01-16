from typing import List
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.infrastructure.database.models import HabitModel
from app.infrastructure.database.repositories.base_repository import BaseRepository


class HabitRepository(BaseRepository[HabitModel]):
    def __init__(self, session: AsyncSession):
        super().__init__(HabitModel, session)

    async def get_by_user(
        self, user_id: UUID, active_only: bool = True
    ) -> List[HabitModel]:
        query = select(HabitModel).where(HabitModel.user_id == user_id)
        if active_only:
            query = query.where(HabitModel.is_active == True)  # noqa: E712

        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def get_active_habit(self, habit_id: UUID) -> HabitModel | None:
        result = await self.session.execute(
            select(HabitModel).where(
                HabitModel.id == habit_id,
                HabitModel.is_active == True,  # noqa: E712
            )
        )
        return result.scalar_one_or_none()

    async def deactivate(self, habit_id: UUID) -> bool:
        habit = await self.get_by_id(habit_id)
        if habit:
            habit.is_active = False  # type: ignore[assignment]
            await self.update(habit)
            return True
        return False

    async def activate(self, habit_id: UUID) -> bool:
        habit = await self.get_by_id(habit_id)
        if habit:
            habit.is_active = True  # type: ignore[assignment]
            await self.update(habit)
            return True
        return False
