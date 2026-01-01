"""Tests for gamification algorithms."""

import pytest

from app.domain.models.gamification import (
    calculate_level,
    calculate_points_with_streak,
    points_for_next_level,
)


class TestGamificationAlgorithms:
    """Test gamification calculation algorithms."""

    def test_calculate_level_zero_points(self):
        """Test level calculation with zero points."""
        assert calculate_level(0) == 0

    def test_calculate_level_first_level(self):
        """Test level calculation for first level."""
        assert calculate_level(100) == 1
        assert calculate_level(150) == 1
        assert calculate_level(399) == 1

    def test_calculate_level_second_level(self):
        """Test level calculation for second level."""
        assert calculate_level(400) == 2
        assert calculate_level(500) == 2
        assert calculate_level(899) == 2

    def test_calculate_level_high_points(self):
        """Test level calculation with high points."""
        assert calculate_level(2500) == 5
        assert calculate_level(10000) == 10

    def test_calculate_level_negative_points_raises_error(self):
        """Test that negative points raise ValueError."""
        with pytest.raises(ValueError, match="Total points cannot be negative"):
            calculate_level(-100)

    def test_points_for_next_level_zero(self):
        """Test points required for level 1."""
        assert points_for_next_level(0) == 100

    def test_points_for_next_level_one(self):
        """Test points required for level 2."""
        assert points_for_next_level(1) == 400

    def test_points_for_next_level_five(self):
        """Test points required for level 6."""
        assert points_for_next_level(5) == 3600

    def test_points_for_next_level_negative_raises_error(self):
        """Test that negative level raises ValueError."""
        with pytest.raises(ValueError, match="Level cannot be negative"):
            points_for_next_level(-1)

    def test_calculate_points_with_streak_no_streak(self):
        """Test points calculation with no streak."""
        assert calculate_points_with_streak(30, 0) == 30

    def test_calculate_points_with_streak_small(self):
        """Test points calculation with small streak."""
        # base_points * (1 + streak * 0.1)
        # 30 * (1 + 1 * 0.1) = 30 * 1.1 = 33
        assert calculate_points_with_streak(30, 1) == 33

    def test_calculate_points_with_streak_large(self):
        """Test points calculation with large streak."""
        # 30 * (1 + 7 * 0.1) = 30 * 1.7 = 51
        assert calculate_points_with_streak(30, 7) == 51

    def test_calculate_points_with_streak_negative_base_raises_error(self):
        """Test that negative base points raise ValueError."""
        with pytest.raises(ValueError, match="Base points cannot be negative"):
            calculate_points_with_streak(-10, 5)

    def test_calculate_points_with_streak_negative_streak_raises_error(self):
        """Test that negative streak raises ValueError."""
        with pytest.raises(ValueError, match="Streak cannot be negative"):
            calculate_points_with_streak(30, -1)
