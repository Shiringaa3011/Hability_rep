"""Tests for group statistics ranking logic."""

from uuid import uuid4

from app.domain.services.stats_service import StatsService


def _member(username: str, points: int, completions: int = 0, rate: float = 0.0):
    return {
        "user_id": uuid4(),
        "username": username,
        "total_points": points,
        "total_completions": completions,
        "completion_rate": rate,
    }


class TestRankMembers:
    def test_distinct_points_assign_unique_ranks(self):
        raw = [
            _member("alice", 100),
            _member("bob", 300),
            _member("carol", 200),
        ]

        ranked = StatsService._rank_members(raw)

        assert [m.username for m in ranked] == ["bob", "carol", "alice"]
        assert [m.rank for m in ranked] == [1, 2, 3]

    def test_tied_points_share_rank_and_sort_alphabetically(self):
        raw = [
            _member("zoe", 200),
            _member("alice", 200),
            _member("mike", 200),
        ]

        ranked = StatsService._rank_members(raw)

        assert [m.username for m in ranked] == ["alice", "mike", "zoe"]
        assert [m.rank for m in ranked] == [1, 1, 1]

    def test_mixed_ties_skip_ranks_correctly(self):
        raw = [
            _member("first", 500),
            _member("zed", 300),
            _member("ann", 300),
            _member("low", 100),
        ]

        ranked = StatsService._rank_members(raw)

        assert [m.username for m in ranked] == ["first", "ann", "zed", "low"]
        assert [m.rank for m in ranked] == [1, 2, 2, 4]

    def test_empty_input_returns_empty_list(self):
        assert StatsService._rank_members([]) == []

    def test_single_member_gets_rank_one(self):
        raw = [_member("solo", 50)]

        ranked = StatsService._rank_members(raw)

        assert len(ranked) == 1
        assert ranked[0].rank == 1
        assert ranked[0].username == "solo"

    def test_zero_points_members_all_share_top_rank(self):
        raw = [
            _member("bob", 0),
            _member("alice", 0),
        ]

        ranked = StatsService._rank_members(raw)

        assert [m.username for m in ranked] == ["alice", "bob"]
        assert [m.rank for m in ranked] == [1, 1]

    def test_member_fields_propagated(self):
        raw = [_member("alice", 150, completions=7, rate=85.5)]

        ranked = StatsService._rank_members(raw)

        assert ranked[0].total_points == 150
        assert ranked[0].total_completions == 7
        assert ranked[0].completion_rate == 85.5
