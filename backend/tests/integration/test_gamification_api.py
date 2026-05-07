"""Integration tests for gamification API endpoints."""

import uuid
from datetime import date, datetime

import pytest
from sqlalchemy.exc import IntegrityError

from app.infrastructure.database.models import HabitCompletionModel
from tests.fixtures.database_fixtures import test_user, test_habit


@pytest.mark.asyncio
class TestGamificationAPI:
    """Test gamification API endpoints."""

    async def test_get_user_level_success(self, client, test_user):
        """Test getting user level."""
        response = await client.get(f"/api/v1/gamification/user/{test_user.id}/level")

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == str(test_user.id)
        assert "level" in data
        assert "total_points" in data
        assert "points_to_next_level" in data
        assert "progress_percent" in data

    async def test_get_user_level_not_found(self, client):
        """Test getting level for non-existent user."""
        import uuid

        fake_id = uuid.uuid4()
        response = await client.get(f"/api/v1/gamification/user/{fake_id}/level")

        assert response.status_code == 404

    async def test_get_user_points_success(self, client, test_user):
        """Test getting user points."""
        response = await client.get(f"/api/v1/gamification/user/{test_user.id}/points")

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == str(test_user.id)
        assert data["total_points"] == test_user.total_points
        assert data["current_level"] == test_user.current_level

    async def test_complete_habit_success(self, client, test_user, test_habit):
        """Test completing a habit."""
        request_data = {
            "habit_id": str(test_habit.id),
            "user_id": str(test_user.id),
            "completion_date": str(date.today()),
        }

        response = await client.post(
            "/api/v1/gamification/complete-habit", json=request_data
        )

        assert response.status_code == 201
        data = response.json()
        assert data["habit_id"] == str(test_habit.id)
        assert data["user_id"] == str(test_user.id)
        assert "points_earned" in data
        assert "current_streak" in data

    async def test_complete_habit_duplicate(self, client, test_user, test_habit):
        """Test that duplicate completion is prevented."""
        request_data = {
            "habit_id": str(test_habit.id),
            "user_id": str(test_user.id),
            "completion_date": str(date.today()),
        }

        # First completion
        response1 = await client.post(
            "/api/v1/gamification/complete-habit", json=request_data
        )
        assert response1.status_code == 201

        # Second completion (duplicate)
        response2 = await client.post(
            "/api/v1/gamification/complete-habit", json=request_data
        )
        assert response2.status_code == 400
        assert "already completed" in response2.json()["detail"].lower()

    async def test_db_unique_index_blocks_same_day_duplicate(
        self, db_session, test_user, test_habit
    ):
        """DB-level uq_completion_per_day must reject a duplicate insert."""
        today = date.today()
        timestamp = datetime.combine(today, datetime.min.time())

        first = HabitCompletionModel(
            id=uuid.uuid4(),
            habit_id=test_habit.id,
            user_id=test_user.id,
            completed_at=timestamp,
            points_earned=10,
            current_streak=1,
        )
        db_session.add(first)
        await db_session.flush()

        duplicate = HabitCompletionModel(
            id=uuid.uuid4(),
            habit_id=test_habit.id,
            user_id=test_user.id,
            completed_at=timestamp,
            points_earned=10,
            current_streak=1,
        )
        db_session.add(duplicate)

        with pytest.raises(IntegrityError):
            await db_session.flush()
