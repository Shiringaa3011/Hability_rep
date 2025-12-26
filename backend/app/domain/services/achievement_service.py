import uuid
from datetime import datetime
from typing import Dict, List
from uuid import UUID
from app.domain.services.stats_service import StatsService

from sqlalchemy.ext.asyncio import AsyncSession
from app.domain.models.stats import StatsPeriod
from app.domain.models.achievement import AchievementType
from app.infrastructure.database.models import UserAchievementModel
from app.infrastructure.database.repositories.achievement_repository import (
    AchievementRepository,
    UserAchievementRepository,
)
from app.infrastructure.database.repositories.completion_repository import (
    CompletionRepository,
)
from app.infrastructure.database.repositories.user_repository import UserRepository


class AchievementService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.achievement_repo = AchievementRepository(session)
        self.user_achievement_repo = UserAchievementRepository(session)
        self.user_repo = UserRepository(session)
        self.completion_repo = CompletionRepository(session)

    async def check_and_award_achievements(
        self, user_id: UUID
    ) -> List[UserAchievementModel]:
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            return []

        all_achievements = await self.achievement_repo.get_active_achievements()

        user_values = await self._get_user_achievement_values(user_id)

        newly_awarded = []

        for achievement in all_achievements:
            has_achievement = (
                await self.user_achievement_repo.check_user_has_achievement(
                    user_id,
                    achievement.id,  # type: ignore[arg-type]
                )
            )

            if has_achievement:
                continue

            user_value = user_values.get(achievement.achievement_type, 0)  # type: ignore[call-overload]

            if user_value >= achievement.condition_value:
                user_achievement = UserAchievementModel(
                    id=uuid.uuid4(),
                    user_id=user_id,
                    achievement_id=achievement.id,
                    earned_at=datetime.now(),
                    notified=False,
                )
                user_achievement = await self.user_achievement_repo.create(
                    user_achievement
                )

                if achievement.reward_points > 0:
                    await self.user_repo.add_points(user_id, achievement.reward_points)  # type: ignore[arg-type]

                newly_awarded.append(user_achievement)

        return newly_awarded

    async def get_user_achievements(self, user_id: UUID) -> List[UserAchievementModel]:
        return await self.user_achievement_repo.get_by_user(user_id)

    async def get_available_achievements(self, user_id: UUID) -> List[Dict]:
        all_achievements = await self.achievement_repo.get_active_achievements()
        user_values = await self._get_user_achievement_values(user_id)

        result = []

        for achievement in all_achievements:
            has_achievement = (
                await self.user_achievement_repo.check_user_has_achievement(
                    user_id,
                    achievement.id,  # type: ignore[arg-type]
                )
            )

            user_value = user_values.get(achievement.achievement_type, 0)  # type: ignore[call-overload]
            progress = min(user_value, achievement.condition_value)
            progress_percent = (
                (progress / achievement.condition_value * 100)
                if achievement.condition_value > 0
                else 0
            )

            result.append(
                {
                    "id": str(achievement.id),
                    "name": achievement.name,
                    "description": achievement.description,
                    "icon": achievement.icon,
                    "type": achievement.achievement_type.value,
                    "condition_value": achievement.condition_value,
                    "reward_points": achievement.reward_points,
                    "is_earned": has_achievement,
                    "progress": progress,
                    "progress_percent": round(progress_percent, 2),
                }
            )

        return result

    async def check_achievement_conditions(
        self, user_id: UUID, achievement_id: UUID
    ) -> bool:
        achievement = await self.achievement_repo.get_by_id(achievement_id)
        if not achievement or not achievement.is_active:
            return False

        user_values = await self._get_user_achievement_values(user_id)
        user_value = user_values.get(achievement.achievement_type, 0)  # type: ignore[call-overload]

        return user_value >= achievement.condition_value  # type: ignore[no-any-return]

    async def _get_user_achievement_values(
        self, user_id: UUID
    ) -> Dict[AchievementType, int]:
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            return {}

        values = {}

        values[AchievementType.POINTS] = user.total_points  # type: ignore[assignment]

        values[AchievementType.LEVEL] = user.current_level  # type: ignore[assignment]

        total_completions = await self.completion_repo.count_completions(user_id)
        values[AchievementType.TOTAL_HABITS] = total_completions  # type: ignore[assignment]

        stats_service = StatsService(self.session)
        _, max_streak = await stats_service._calculate_streaks(user_id)
        values[AchievementType.STREAK] = max_streak  # type: ignore[assignment]

        stats = await stats_service.get_user_stats(user_id, StatsPeriod.WEEK)
        perfect_week = 1 if (stats and stats.completion_rate >= 100) else 0
        values[AchievementType.PERFECT_WEEK] = perfect_week  # type: ignore[assignment]

        return values  # type: ignore[return-value]
