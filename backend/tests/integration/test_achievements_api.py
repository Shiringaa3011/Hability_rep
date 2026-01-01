"""Integration tests for achievements API endpoints."""

import pytest

from tests.fixtures.database_fixtures import test_user, test_achievement


@pytest.mark.asyncio
class TestAchievementsAPI:
    """Test achievements API endpoints."""

    async def test_list_all_achievements(self, client, test_achievement):
        """Test getting list of all achievements."""
        response = await client.get("/api/v1/achievements")

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1
        assert any(ach["id"] == str(test_achievement.id) for ach in data)

    async def test_get_user_achievements(self, client, test_user):
        """Test getting user achievements."""
        response = await client.get(f"/api/v1/achievements/user/{test_user.id}")

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == str(test_user.id)
        assert "earned_achievements" in data
        assert "total_earned" in data
        assert isinstance(data["earned_achievements"], list)

    async def test_get_achievements_progress(self, client, test_user, test_achievement):
        """Test getting achievements with progress."""
        response = await client.get(
            f"/api/v1/achievements/user/{test_user.id}/progress"
        )

        assert response.status_code == 200
        data = response.json()
        assert "achievements" in data
        assert "total_available" in data
        assert "total_earned" in data
        assert isinstance(data["achievements"], list)

        # Check that our test achievement is in the list
        achievements = data["achievements"]
        assert len(achievements) >= 1

        # Each achievement should have required fields
        for ach in achievements:
            assert "id" in ach
            assert "name" in ach
            assert "is_earned" in ach
            assert "progress" in ach
            assert "progress_percent" in ach

    async def test_check_new_achievements(self, client, test_user):
        """Test checking for new achievements."""
        response = await client.post(f"/api/v1/achievements/user/{test_user.id}/check")

        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == str(test_user.id)
        assert "new_achievements_count" in data
        assert "new_achievements" in data
        assert isinstance(data["new_achievements"], list)
