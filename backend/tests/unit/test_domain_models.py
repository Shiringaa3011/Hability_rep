"""Tests for domain models."""

import pytest
from datetime import datetime
from uuid import uuid4

from app.domain.models.achievement import Achievement, AchievementType, UserAchievement
from app.domain.models.completion import HabitCompletion
from app.domain.models.gamification import UserLevel
from app.domain.models.habit import Habit, HabitFrequency
from app.domain.models.stats import StatsPeriod, UserStats
from app.domain.models.user import User


class TestHabitModel:
    """Test Habit domain model."""

    def test_habit_creation_valid(self):
        """Test creating valid habit."""
        habit = Habit(
            id=uuid4(),
            user_id=uuid4(),
            name="Test Habit",
            description="Test description",
            frequency=HabitFrequency.DAILY,
            difficulty=3,
            target_days=30,
            is_active=True,
            created_at=datetime.now(),
        )
        assert habit.difficulty == 3
        assert habit.name == "Test Habit"

    def test_habit_invalid_difficulty_raises_error(self):
        """Test that invalid difficulty raises ValueError."""
        with pytest.raises(ValueError, match="Difficulty must be between 1 and 5"):
            Habit(
                id=uuid4(),
                user_id=uuid4(),
                name="Test",
                description=None,
                frequency=HabitFrequency.DAILY,
                difficulty=6,  # Invalid
                target_days=30,
                is_active=True,
                created_at=datetime.now(),
            )

    def test_habit_calculate_base_points(self):
        """Test base points calculation."""
        habit = Habit(
            id=uuid4(),
            user_id=uuid4(),
            name="Test",
            description=None,
            frequency=HabitFrequency.DAILY,
            difficulty=4,
            target_days=30,
            is_active=True,
            created_at=datetime.now(),
        )
        assert habit.calculate_base_points() == 40


class TestHabitCompletionModel:
    """Test HabitCompletion domain model."""

    def test_completion_creation_valid(self):
        """Test creating valid completion."""
        completion = HabitCompletion(
            id=uuid4(),
            habit_id=uuid4(),
            user_id=uuid4(),
            completed_at=datetime.now(),
            points_earned=30,
            current_streak=5,
        )
        assert completion.points_earned == 30
        assert completion.current_streak == 5

    def test_completion_negative_points_raises_error(self):
        """Test that negative points raise ValueError."""
        with pytest.raises(ValueError, match="Points earned cannot be negative"):
            HabitCompletion(
                id=uuid4(),
                habit_id=uuid4(),
                user_id=uuid4(),
                completed_at=datetime.now(),
                points_earned=-10,
                current_streak=1,
            )


class TestAchievementModel:
    """Test Achievement domain model."""

    def test_achievement_check_condition_met(self):
        """Test achievement condition is met."""
        achievement = Achievement(
            id=uuid4(),
            name="Test",
            description="Test",
            icon="star",
            achievement_type=AchievementType.STREAK,
            condition_value=7,
            reward_points=50,
            is_active=True,
        )
        assert achievement.check_condition(7) is True
        assert achievement.check_condition(8) is True

    def test_achievement_check_condition_not_met(self):
        """Test achievement condition is not met."""
        achievement = Achievement(
            id=uuid4(),
            name="Test",
            description="Test",
            icon="star",
            achievement_type=AchievementType.STREAK,
            condition_value=7,
            reward_points=50,
            is_active=True,
        )
        assert achievement.check_condition(6) is False


class TestUserStatsModel:
    """Test UserStats domain model."""

    def test_stats_creation_valid(self):
        """Test creating valid stats."""
        stats = UserStats(
            id=uuid4(),
            user_id=uuid4(),
            period=StatsPeriod.WEEK,
            total_completions=10,
            completion_rate=90.5,
            current_streak=5,
            max_streak=10,
            total_points_period=150,
            updated_at=datetime.now(),
        )
        assert stats.completion_rate == 90.5

    def test_stats_invalid_completion_rate_raises_error(self):
        """Test that invalid completion rate raises ValueError."""
        with pytest.raises(
            ValueError, match="Completion rate must be between 0 and 100"
        ):
            UserStats(
                id=uuid4(),
                user_id=uuid4(),
                period=StatsPeriod.WEEK,
                total_completions=10,
                completion_rate=150.0,  # Invalid
                current_streak=5,
                max_streak=10,
                total_points_period=150,
                updated_at=datetime.now(),
            )


class TestUserLevelModel:
    """Test UserLevel domain model."""

    def test_user_level_creation_valid(self):
        """Test creating valid user level."""
        level = UserLevel(
            user_id=uuid4(),
            level=5,
            total_points=2500,
            points_to_next_level=1100,
            progress_percent=69.4,
        )
        assert level.level == 5
        assert level.progress_percent == 69.4

    def test_user_level_invalid_progress_raises_error(self):
        """Test that invalid progress percent raises ValueError."""
        with pytest.raises(
            ValueError, match="Progress percent must be between 0 and 100"
        ):
            UserLevel(
                user_id=uuid4(),
                level=5,
                total_points=2500,
                points_to_next_level=1100,
                progress_percent=150.0,  # Invalid
            )
