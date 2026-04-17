"""Integration tests for missed_count statistics field."""

import pytest

from tests.fixtures.database_fixtures import test_habit, test_user


@pytest.mark.asyncio
class TestStatsMissedCount:
    async def test_user_stats_missed_count_no_completions(
        self, client, test_user, test_habit
    ):
        response = await client.get(
            f"/api/v1/stats/user/{test_user.id}?period=week"
        )

        assert response.status_code == 200
        data = response.json()
        assert data["total_completions"] == 0
        assert data["missed_count"] == 7

    async def test_habit_stats_missed_count_no_completions(
        self, client, test_user, test_habit
    ):
        response = await client.get(
            f"/api/v1/stats/user/{test_user.id}/habits?period=week"
        )

        assert response.status_code == 200
        data = response.json()
        assert len(data["habits"]) == 1
        habit = data["habits"][0]
        assert habit["total_completions"] == 0
        assert habit["missed_count"] == 7

    async def test_user_stats_missed_count_zero_when_no_active_habits(
        self, client, test_user
    ):
        response = await client.get(
            f"/api/v1/stats/user/{test_user.id}?period=week"
        )

        assert response.status_code == 200
        data = response.json()
        assert data["missed_count"] == 0
