"""Database fixtures for tests."""

import pytest
import uuid
from datetime import datetime

from app.domain.models.achievement import AchievementType
from app.domain.models.habit import HabitFrequency
from app.infrastructure.database.models import (
    AchievementModel,
    HabitModel,
    UserModel,
)


@pytest.fixture
async def test_user(db_session):
    """Create a test user."""
    user = UserModel(
        id=uuid.uuid4(),
        username="testuser",
        email="test@example.com",
        total_points=100,
        current_level=1,
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)
    return user


@pytest.fixture
async def test_habit(db_session, test_user):
    """Create a test habit."""
    habit = HabitModel(
        id=uuid.uuid4(),
        user_id=test_user.id,
        name="Test Habit",
        description="Test description",
        frequency=HabitFrequency.DAILY,
        difficulty=3,
        target_days=30,
        is_active=True,
    )
    db_session.add(habit)
    await db_session.commit()
    await db_session.refresh(habit)
    return habit


@pytest.fixture
async def test_achievement(db_session):
    """Create a test achievement."""
    achievement = AchievementModel(
        id=uuid.uuid4(),
        name="Test Achievement",
        description="Test description",
        icon="star",
        achievement_type=AchievementType.STREAK,
        condition_value=7,
        reward_points=50,
        is_active=True,
    )
    db_session.add(achievement)
    await db_session.commit()
    await db_session.refresh(achievement)
    return achievement
