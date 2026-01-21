from datetime import date, datetime
from typing import List, Optional
from uuid import UUID

from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.infrastructure.database.models import HabitCompletionModel
from app.infrastructure.database.repositories.base_repository import BaseRepository


class CompletionRepository(BaseRepository[HabitCompletionModel]):
    def __init__(self, session: AsyncSession):
        super().__init__(HabitCompletionModel, session)

    async def get_by_user(
        self,
        user_id: UUID,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> List[HabitCompletionModel]:
        query = select(HabitCompletionModel).where(
            HabitCompletionModel.user_id == user_id
        )

        if start_date:
            query = query.where(HabitCompletionModel.completed_at >= start_date)
        if end_date:
            query = query.where(HabitCompletionModel.completed_at <= end_date)

        query = query.order_by(HabitCompletionModel.completed_at.desc())

        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def get_by_habit(
        self,
        habit_id: UUID,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> List[HabitCompletionModel]:
        query = select(HabitCompletionModel).where(
            HabitCompletionModel.habit_id == habit_id
        )

        if start_date:
            query = query.where(HabitCompletionModel.completed_at >= start_date)
        if end_date:
            query = query.where(HabitCompletionModel.completed_at <= end_date)

        query = query.order_by(HabitCompletionModel.completed_at.desc())

        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def get_latest_completion(
        self, habit_id: UUID
    ) -> Optional[HabitCompletionModel]:
        result = await self.session.execute(
            select(HabitCompletionModel)
            .where(HabitCompletionModel.habit_id == habit_id)
            .order_by(HabitCompletionModel.completed_at.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()

    async def check_completion_exists(
        self, habit_id: UUID, user_id: UUID, completion_date: date
    ) -> bool:
        result = await self.session.execute(
            select(func.count(HabitCompletionModel.id)).where(
                and_(
                    HabitCompletionModel.habit_id == habit_id,
                    HabitCompletionModel.user_id == user_id,
                    func.date(HabitCompletionModel.completed_at) == completion_date,
                )
            )
        )
        count = result.scalar()
        return (count or 0) > 0

    async def count_completions(
        self,
        user_id: UUID,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> int:
        query = select(func.count(HabitCompletionModel.id)).where(
            HabitCompletionModel.user_id == user_id
        )

        if start_date:
            query = query.where(HabitCompletionModel.completed_at >= start_date)
        if end_date:
            query = query.where(HabitCompletionModel.completed_at <= end_date)

        result = await self.session.execute(query)
        return result.scalar() or 0

    async def sum_points_earned(
        self,
        user_id: UUID,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> int:
        query = select(func.sum(HabitCompletionModel.points_earned)).where(
            HabitCompletionModel.user_id == user_id
        )

        if start_date:
            query = query.where(HabitCompletionModel.completed_at >= start_date)
        if end_date:
            query = query.where(HabitCompletionModel.completed_at <= end_date)

        result = await self.session.execute(query)
        return result.scalar() or 0
