from datetime import date, datetime, timedelta
from typing import Dict, List, Optional, Tuple
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.gamification import HabitStats
from app.domain.models.stats import (
    GroupMemberStats,
    GroupStats,
    StatsPeriod,
    TimelinePoint,
    UserStats as UserStatsEntity,
)
from app.infrastructure.database.models import GroupMemberModel, UserModel
from app.infrastructure.database.repositories.completion_repository import (
    CompletionRepository,
)
from app.infrastructure.database.repositories.habit_repository import HabitRepository
from app.infrastructure.database.repositories.stats_repository import StatsRepository
from app.infrastructure.database.repositories.user_repository import UserRepository


class StatsService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.user_repo = UserRepository(session)
        self.habit_repo = HabitRepository(session)
        self.completion_repo = CompletionRepository(session)
        self.stats_repo = StatsRepository(session)

    async def get_user_stats(
        self, user_id: UUID, period: StatsPeriod = StatsPeriod.WEEK
    ) -> Optional[UserStatsEntity]:
        start_date, end_date = self._get_date_range(period)

        completions = await self.completion_repo.get_by_user(
            user_id, start_date, end_date
        )

        habits = await self.habit_repo.get_by_user(user_id, active_only=True)

        total_completions = len(completions)

        expected_completions = self._calculate_expected_completions(habits, period)
        completion_rate = min(
            (total_completions / expected_completions * 100)
            if expected_completions > 0
            else 0,
            100.0,
        )
        missed_count = max(0, expected_completions - total_completions)

        current_streak, max_streak = await self._calculate_streaks(user_id)

        total_points = sum(c.points_earned for c in completions)  # type: ignore[misc]

        stats_entity = UserStatsEntity(
            id=UUID(int=0),  # Temporary ID, TODO: change on real one
            user_id=user_id,
            period=period,
            total_completions=total_completions,
            completion_rate=round(completion_rate, 2),
            current_streak=current_streak,
            max_streak=max_streak,
            total_points_period=total_points,  # type: ignore[arg-type]
            updated_at=datetime.now(),
            missed_count=missed_count,
        )

        await self.stats_repo.upsert_stats(
            user_id=user_id,
            period=period,
            total_completions=total_completions,
            completion_rate=completion_rate,
            current_streak=current_streak,
            max_streak=max_streak,
            total_points_period=total_points,  # type: ignore[arg-type]
        )

        return stats_entity

    async def get_habit_stats(
        self, habit_id: UUID, period: StatsPeriod = StatsPeriod.WEEK
    ) -> Optional[HabitStats]:
        habit = await self.habit_repo.get_by_id(habit_id)
        if not habit:
            return None

        start_date, end_date = self._get_date_range(period)

        completions = await self.completion_repo.get_by_habit(
            habit_id, start_date, end_date
        )

        total_completions = len(completions)
        total_points = sum(c.points_earned for c in completions)  # type: ignore[misc]

        from app.domain.services.gamification_service import GamificationService

        gamification_service = GamificationService(self.session)
        current_streak, max_streak = await gamification_service.get_streak_info(
            habit_id
        )

        expected_completions = self._calculate_expected_completions([habit], period)
        completion_rate = min(
            (total_completions / expected_completions * 100)
            if expected_completions > 0
            else 0,
            100.0,
        )
        missed_count = max(0, expected_completions - total_completions)

        return HabitStats(
            habit_id=habit_id,
            habit_name=habit.name,  # type: ignore[arg-type]
            total_completions=total_completions,
            current_streak=current_streak,
            max_streak=max_streak,
            total_points_earned=total_points,  # type: ignore[arg-type]
            completion_rate=round(completion_rate, 2),
            missed_count=missed_count,
        )

    async def get_user_habits_stats(
        self, user_id: UUID, period: StatsPeriod = StatsPeriod.WEEK
    ) -> List[HabitStats]:
        habits = await self.habit_repo.get_by_user(user_id, active_only=True)

        stats_list = []
        for habit in habits:
            habit_stats = await self.get_habit_stats(habit.id, period)  # type: ignore[arg-type]
            if habit_stats:
                stats_list.append(habit_stats)

        return stats_list

    async def get_group_stats(
        self, group_id: UUID, period: StatsPeriod = StatsPeriod.WEEK
    ) -> GroupStats:
        members_info = await self._get_group_members_with_username(group_id)

        if not members_info:
            return GroupStats(group_id=group_id, period=period)

        raw_members = []
        for user_id, username in members_info:
            completions, rate, points = await self._compute_member_period_stats(
                user_id, period
            )
            raw_members.append(
                {
                    "user_id": user_id,
                    "username": username,
                    "total_completions": completions,
                    "completion_rate": rate,
                    "total_points": points,
                }
            )

        ranked = self._rank_members(raw_members)

        total_points_group = sum(m.total_points for m in ranked)
        total_completions = sum(m.total_completions for m in ranked)
        average_rate = sum(m.completion_rate for m in ranked) / len(ranked)
        active_count = sum(1 for m in ranked if m.total_completions > 0)

        return GroupStats(
            group_id=group_id,
            period=period,
            members=ranked,
            total_points_group=total_points_group,
            average_completion_rate=round(average_rate, 2),
            total_completions=total_completions,
            active_members_count=active_count,
        )

    async def _get_group_members_with_username(
        self, group_id: UUID
    ) -> List[Tuple[UUID, str]]:
        result = await self.session.execute(
            select(GroupMemberModel.user_id, UserModel.username)
            .join(UserModel, UserModel.id == GroupMemberModel.user_id)
            .where(GroupMemberModel.group_id == group_id)
        )
        return [(row.user_id, row.username) for row in result.all()]

    async def _compute_member_period_stats(
        self, user_id: UUID, period: StatsPeriod
    ) -> Tuple[int, float, int]:
        start_date, end_date = self._get_date_range(period)

        completions = await self.completion_repo.get_by_user(
            user_id, start_date, end_date
        )
        habits = await self.habit_repo.get_by_user(user_id, active_only=True)

        total_completions = len(completions)
        expected = self._calculate_expected_completions(habits, period)
        completion_rate = (
            (total_completions / expected * 100) if expected > 0 else 0.0
        )
        total_points = sum(c.points_earned for c in completions)  # type: ignore[misc]

        return total_completions, round(completion_rate, 2), total_points

    @staticmethod
    def _rank_members(raw_members: List[Dict]) -> List[GroupMemberStats]:
        sorted_members = sorted(
            raw_members,
            key=lambda m: (-m["total_points"], m["username"]),
        )

        ranked: List[GroupMemberStats] = []
        prev_points: Optional[int] = None
        current_rank = 0
        for index, member in enumerate(sorted_members):
            if member["total_points"] != prev_points:
                current_rank = index + 1
                prev_points = member["total_points"]
            ranked.append(
                GroupMemberStats(
                    user_id=member["user_id"],
                    username=member["username"],
                    rank=current_rank,
                    total_completions=member["total_completions"],
                    completion_rate=member["completion_rate"],
                    total_points=member["total_points"],
                )
            )
        return ranked

    def _get_date_range(self, period: StatsPeriod) -> tuple[datetime, datetime]:
        today = date.today()
        end_date = datetime.combine(today, datetime.max.time())

        if period == StatsPeriod.DAY:
            start_date = datetime.combine(today, datetime.min.time())
        elif period == StatsPeriod.WEEK:
            start_date = datetime.combine(
                today - timedelta(days=7), datetime.min.time()
            )
        else:
            start_date = datetime.combine(
                today - timedelta(days=30), datetime.min.time()
            )

        return start_date, end_date

    def _calculate_expected_completions(self, habits: list, period: StatsPeriod) -> int:
        from app.domain.models.habit import HabitFrequency

        if period == StatsPeriod.DAY:
            return sum(1 for h in habits if h.frequency == HabitFrequency.DAILY)
        elif period == StatsPeriod.WEEK:
            daily_count = sum(1 for h in habits if h.frequency == HabitFrequency.DAILY)
            weekly_count = sum(
                1 for h in habits if h.frequency == HabitFrequency.WEEKLY
            )
            return daily_count * 7 + weekly_count
        else:
            daily_count = sum(1 for h in habits if h.frequency == HabitFrequency.DAILY)
            weekly_count = sum(
                1 for h in habits if h.frequency == HabitFrequency.WEEKLY
            )
            return daily_count * 30 + weekly_count * 4

    async def _calculate_streaks(self, user_id: UUID) -> tuple[int, int]:
        habits = await self.habit_repo.get_by_user(user_id, active_only=True)

        from app.domain.services.gamification_service import GamificationService

        gamification_service = GamificationService(self.session)

        current_streaks = []
        max_streaks = []

        for habit in habits:
            current, maximum = await gamification_service.get_streak_info(habit.id)  # type: ignore[arg-type]
            current_streaks.append(current)
            max_streaks.append(maximum)

        return (
            max(current_streaks) if current_streaks else 0,
            max(max_streaks) if max_streaks else 0,
        )

    async def calculate_completion_rate(
        self, user_id: UUID, period: StatsPeriod = StatsPeriod.WEEK
    ) -> float:
        stats = await self.get_user_stats(user_id, period)
        return stats.completion_rate if stats else 0.0

    async def get_user_timeline(
        self, user_id: UUID, period: StatsPeriod
    ) -> List[TimelinePoint]:
        if period == StatsPeriod.DAY:
            raise ValueError("period 'day' is not supported for timeline")

        buckets = self._build_timeline_buckets(period)
        result: List[TimelinePoint] = []
        for label, start, end in buckets:
            completions = await self.completion_repo.get_by_user(user_id, start, end)
            points = sum(c.points_earned for c in completions)  # type: ignore[misc]
            result.append(TimelinePoint(date=label, points=points))
        return result

    def _build_timeline_buckets(
        self, period: StatsPeriod
    ) -> List[Tuple[str, datetime, datetime]]:
        if period == StatsPeriod.DAY:
            raise ValueError("period 'day' is not supported for timeline")

        today = date.today()
        if period == StatsPeriod.WEEK:
            return self._build_week_buckets(today)
        return self._build_month_buckets(today)

    @staticmethod
    def _build_week_buckets(today: date) -> List[Tuple[str, datetime, datetime]]:
        buckets = []
        for days_ago in range(6, -1, -1):
            day = today - timedelta(days=days_ago)
            start = datetime.combine(day, datetime.min.time())
            end = datetime.combine(day, datetime.max.time())
            buckets.append((day.isoformat(), start, end))
        return buckets

    @staticmethod
    def _build_month_buckets(today: date) -> List[Tuple[str, datetime, datetime]]:
        buckets = []
        for i in range(4, -1, -1):
            bucket_end_day = today - timedelta(days=7 * i)
            bucket_start_day = today - timedelta(days=7 * i + 6)
            start = datetime.combine(bucket_start_day, datetime.min.time())
            end = datetime.combine(bucket_end_day, datetime.max.time())
            buckets.append((bucket_start_day.isoformat(), start, end))
        return buckets
