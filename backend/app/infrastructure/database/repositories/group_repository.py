from typing import List
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.infrastructure.database.models import GroupModel, HabitModel
from app.infrastructure.database.repositories.base_repository import BaseRepository


class GroupRepository(BaseRepository[GroupModel]):
    def __init__(self, session: AsyncSession):
        super().__init__(GroupModel, session)

    async def get_user_groups_with_counts(self, user_id: UUID) -> List[dict]:
        """
        Возвращает группы пользователя с количеством привычек в каждой.
        """
        query = (
            select(
                GroupModel,
                func.count(HabitModel.id).label("habits_count")
            )
            .outerjoin(HabitModel, GroupModel.id == HabitModel.group_id)
            .where(
                GroupModel.created_by == user_id,
                GroupModel.is_active == True
            )
            .group_by(GroupModel.id)
        )
        result = await self.session.execute(query)
        rows = result.all()
        
        return [
            {
                "id": row.GroupModel.id,
                "name": row.GroupModel.name,
                "description": row.GroupModel.description,
                "created_by": row.GroupModel.created_by,
                "created_at": row.GroupModel.created_at,
                "is_active": row.GroupModel.is_active,
                "habits_count": row.habits_count or 0,
            }
            for row in rows
        ]

    async def get_user_groups(self, user_id: UUID) -> List[GroupModel]:
        """Возвращает группы пользователя без подсчёта привычек."""
        result = await self.session.execute(
            select(GroupModel)
            .where(GroupModel.created_by == user_id, GroupModel.is_active == True)
        )
        return list(result.scalars().all())

    async def get_group_with_members(self, group_id: UUID):
        """Возвращает группу с участниками (для детального экрана)."""
        # Этот метод можно реализовать позже, если нужно
        pass