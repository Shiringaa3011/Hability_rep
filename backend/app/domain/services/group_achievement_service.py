import uuid
from datetime import datetime
from typing import Dict, List
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.group_achievement import GroupAchievementType
from app.domain.models.stats import StatsPeriod
from app.domain.services.stats_service import StatsService
from app.infrastructure.database.models import (
    EarnedGroupAchievementModel,
    GroupMemberModel,
)
from app.infrastructure.database.repositories.completion_repository import (
    CompletionRepository,
)
from app.infrastructure.database.repositories.group_achievement_repository import (
    EarnedGroupAchievementRepository,
    GroupAchievementRepository,
)


class GroupAchievementService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.achievement_repo = GroupAchievementRepository(session)
        self.earned_repo = EarnedGroupAchievementRepository(session)
        self.completion_repo = CompletionRepository(session)

    async def _get_group_member_ids(self, group_id: UUID) -> List[UUID]:
        result = await self.session.execute(
            select(GroupMemberModel.user_id).where(
                GroupMemberModel.group_id == group_id
            )
        )
        return list(result.scalars().all())

    async def check_and_award_achievements(
        self, group_id: UUID
    ) -> List[EarnedGroupAchievementModel]:
        member_ids = await self._get_group_member_ids(group_id)
        if not member_ids:
            return []

        all_achievements = await self.achievement_repo.get_active_achievements()
        group_values = await self._get_group_values(group_id, member_ids)

        newly_awarded = []

        for achievement in all_achievements:
            has = await self.earned_repo.check_group_has_achievement(
                group_id, achievement.id  # type: ignore[arg-type]
            )
            if has:
                continue

            value = group_values.get(achievement.achievement_type, 0)  # type: ignore[call-overload]

            if value >= achievement.condition_value:
                earned = EarnedGroupAchievementModel(
                    id=uuid.uuid4(),
                    group_id=group_id,
                    achievement_id=achievement.id,
                    earned_at=datetime.now(),
                    notified=False,
                )
                earned = await self.earned_repo.create(earned)
                newly_awarded.append(earned)

        return newly_awarded

    async def get_group_achievements(
        self, group_id: UUID
    ) -> List[EarnedGroupAchievementModel]:
        return await self.earned_repo.get_by_group(group_id)

    async def get_available_group_achievements(
        self, group_id: UUID
    ) -> List[Dict]:
        member_ids = await self._get_group_member_ids(group_id)
        all_achievements = await self.achievement_repo.get_active_achievements()
        group_values = await self._get_group_values(group_id, member_ids)

        result = []
        for achievement in all_achievements:
            has = await self.earned_repo.check_group_has_achievement(
                group_id, achievement.id  # type: ignore[arg-type]
            )
            value = group_values.get(achievement.achievement_type, 0)  # type: ignore[call-overload]
            progress = min(value, achievement.condition_value)
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
                    "is_earned": has,
                    "progress": progress,
                    "progress_percent": round(progress_percent, 2),
                }
            )
        return result

    async def _get_group_values(
        self, group_id: UUID, member_ids: List[UUID]
    ) -> Dict[GroupAchievementType, int]:
        if not member_ids:
            return {}

        values: Dict[GroupAchievementType, int] = {}

        # GROUP_TOTAL_HABITS: sum of all members' completions
        total = 0
        for uid in member_ids:
            total += await self.completion_repo.count_completions(uid)
        values[GroupAchievementType.GROUP_TOTAL_HABITS] = total

        # GROUP_ALL_STREAK: minimum streak across all members (all must have >= N)
        stats_service = StatsService(self.session)
        min_streak = None
        for uid in member_ids:
            current_streak, _ = await stats_service._calculate_streaks(uid)
            if min_streak is None or current_streak < min_streak:
                min_streak = current_streak
        values[GroupAchievementType.GROUP_ALL_STREAK] = min_streak or 0

        # GROUP_PERFECT_WEEK: 1 if ALL members had 100% completion rate this week
        all_perfect = True
        for uid in member_ids:
            stats = await stats_service.get_user_stats(uid, StatsPeriod.WEEK)
            if not stats or stats.completion_rate < 100:
                all_perfect = False
                break
        values[GroupAchievementType.GROUP_PERFECT_WEEK] = 1 if all_perfect else 0

        return values
