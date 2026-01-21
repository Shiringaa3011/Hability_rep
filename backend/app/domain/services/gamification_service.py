import uuid
from datetime import date, datetime, timedelta
from typing import Optional, Tuple
from uuid import UUID
from app.domain.services.achievement_service import AchievementService

from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.gamification import (
    UserLevel,
    calculate_level,
    calculate_points_with_streak,
    points_for_next_level,
)
from app.domain.models.habit import HabitFrequency
from app.infrastructure.database.models import HabitCompletionModel, HabitModel
from app.infrastructure.database.repositories.achievement_repository import (
    AchievementRepository,
    UserAchievementRepository,
)
from app.infrastructure.database.repositories.completion_repository import (
    CompletionRepository,
)
from app.infrastructure.database.repositories.habit_repository import HabitRepository
from app.infrastructure.database.repositories.user_repository import UserRepository


class GamificationService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.user_repo = UserRepository(session)
        self.habit_repo = HabitRepository(session)
        self.completion_repo = CompletionRepository(session)
        self.achievement_repo = AchievementRepository(session)
        self.user_achievement_repo = UserAchievementRepository(session)

    async def process_habit_completion(
        self, habit_id: UUID, user_id: UUID, completion_date: Optional[date] = None
    ) -> Tuple[HabitCompletionModel, bool]:
        if completion_date is None:
            completion_date = date.today()

        habit = await self.habit_repo.get_active_habit(habit_id)
        if not habit:
            raise ValueError("Habit not found or not active")

        if habit.user_id != user_id:
            raise ValueError("Habit does not belong to user")

        already_completed = await self.completion_repo.check_completion_exists(
            habit_id, user_id, completion_date
        )
        if already_completed:
            raise ValueError("Habit already completed today")

        current_streak = await self._calculate_streak(habit)

        base_points = habit.difficulty * 10
        points_earned = calculate_points_with_streak(base_points, current_streak)  # type: ignore[arg-type]

        completion = HabitCompletionModel(
            id=uuid.uuid4(),
            habit_id=habit_id,
            user_id=user_id,
            completed_at=datetime.combine(completion_date, datetime.now().time()),
            points_earned=points_earned,
            current_streak=current_streak,
        )
        completion = await self.completion_repo.create(completion)

        await self.user_repo.add_points(user_id, points_earned)

        await self.update_user_level(user_id)

        achievement_service = AchievementService(self.session)
        await achievement_service.check_and_award_achievements(user_id)

        return completion, True

    async def _calculate_streak(self, habit: HabitModel) -> int:
        latest_completion = await self.completion_repo.get_latest_completion(habit.id)  # type: ignore[arg-type]

        if not latest_completion:
            return 1

        today = date.today()
        last_completion_date = latest_completion.completed_at.date()

        if habit.frequency == HabitFrequency.DAILY:
            yesterday = today - timedelta(days=1)
            if last_completion_date == yesterday:
                return latest_completion.current_streak + 1  # type: ignore[return-value]
            elif last_completion_date == today:
                return latest_completion.current_streak  # type: ignore[return-value]
            else:
                return 1

        elif habit.frequency == HabitFrequency.WEEKLY:
            days_since_completion = (today - last_completion_date).days
            if days_since_completion <= 7:
                return latest_completion.current_streak + 1  # type: ignore[return-value]
            else:
                return 1

        return 1

    async def update_user_level(self, user_id: UUID) -> Optional[int]:
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            return None

        new_level = calculate_level(user.total_points)  # type: ignore[arg-type]

        if new_level != user.current_level:
            await self.user_repo.update_level(user_id, new_level)
            return new_level

        return user.current_level  # type: ignore[return-value]

    async def get_user_level(self, user_id: UUID) -> Optional[UserLevel]:
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            return None

        level = calculate_level(user.total_points)  # type: ignore[arg-type]
        points_for_current_level = level**2 * 100
        points_for_next = points_for_next_level(level)
        points_to_next = points_for_next - user.total_points  # type: ignore[operator]
        points_in_current_level = user.total_points - points_for_current_level  # type: ignore[operator]
        points_needed_in_level = points_for_next - points_for_current_level

        progress_percent = (
            (points_in_current_level / points_needed_in_level * 100)
            if points_needed_in_level > 0
            else 0
        )

        return UserLevel(
            user_id=user_id,
            level=level,
            total_points=user.total_points,  # type: ignore[arg-type]
            points_to_next_level=points_to_next,  # type: ignore[arg-type]
            progress_percent=round(progress_percent, 2),
        )

    async def calculate_points(self, habit: HabitModel, streak: int) -> int:
        base_points = habit.difficulty * 10
        return calculate_points_with_streak(base_points, streak)  # type: ignore[arg-type]

    async def get_streak_info(self, habit_id: UUID) -> Tuple[int, int]:
        habit = await self.habit_repo.get_by_id(habit_id)
        if not habit:
            return 0, 0

        latest_completion = await self.completion_repo.get_latest_completion(habit_id)
        current_streak = latest_completion.current_streak if latest_completion else 0

        if latest_completion:
            today = date.today()
            last_completion_date = latest_completion.completed_at.date()

            if habit.frequency == HabitFrequency.DAILY:
                if (today - last_completion_date).days > 1:
                    current_streak = 0
            elif habit.frequency == HabitFrequency.WEEKLY:
                if (today - last_completion_date).days > 7:
                    current_streak = 0

        completions = await self.completion_repo.get_by_habit(habit_id)
        max_streak = max([c.current_streak for c in completions]) if completions else 0  # type: ignore[type-var]

        return current_streak, max_streak  # type: ignore[return-value]
