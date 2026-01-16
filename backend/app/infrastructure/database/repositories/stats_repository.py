from typing import List, Optional
from uuid import UUID, uuid4

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.stats import StatsPeriod
from app.infrastructure.database.models import UserStatsModel
from app.infrastructure.database.repositories.base_repository import BaseRepository


class StatsRepository(BaseRepository[UserStatsModel]):
    def __init__(self, session: AsyncSession):
        super().__init__(UserStatsModel, session)

    async def get_by_user_and_period(
        self, user_id: UUID, period: StatsPeriod
    ) -> Optional[UserStatsModel]:
        result = await self.session.execute(
            select(UserStatsModel).where(
                UserStatsModel.user_id == user_id, UserStatsModel.period == period
            )
        )
        return result.scalar_one_or_none()

    async def get_by_user(self, user_id: UUID) -> List[UserStatsModel]:
        result = await self.session.execute(
            select(UserStatsModel).where(UserStatsModel.user_id == user_id)
        )
        return list(result.scalars().all())

    async def upsert_stats(
        self,
        user_id: UUID,
        period: StatsPeriod,
        total_completions: int,
        completion_rate: float,
        current_streak: int,
        max_streak: int,
        total_points_period: int,
    ) -> UserStatsModel:
        stats = await self.get_by_user_and_period(user_id, period)

        if stats:
            stats.total_completions = total_completions  # type: ignore[assignment]
            stats.completion_rate = completion_rate  # type: ignore[assignment]
            stats.current_streak = current_streak  # type: ignore[assignment]
            stats.max_streak = max_streak  # type: ignore[assignment]
            stats.total_points_period = total_points_period  # type: ignore[assignment]
            return await self.update(stats)
        else:
            new_stats = UserStatsModel(
                id=uuid4(),
                user_id=user_id,
                period=period,
                total_completions=total_completions,
                completion_rate=completion_rate,
                current_streak=current_streak,
                max_streak=max_streak,
                total_points_period=total_points_period,
            )
            return await self.create(new_stats)
