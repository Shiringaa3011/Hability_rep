"""Database seeding script with sample data."""

import asyncio
import uuid
from datetime import datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import AsyncSessionLocal
from app.domain.models.achievement import AchievementType
from app.domain.models.habit import HabitFrequency
from app.infrastructure.database.models import (
    AchievementModel,
    GroupMemberModel,
    GroupModel,
    HabitCompletionModel,
    HabitModel,
    UserModel,
)


async def seed_database():
    """Seed database with sample data."""
    async with AsyncSessionLocal() as session:
        print("🌱 Starting database seeding...")

        # Create users
        print("Creating users...")
        test_user_id = uuid.UUID("00000000-0000-0000-0000-000000000001")
        test_user = UserModel(
            id=test_user_id,
            username="test_user",
            email="test@example.com",
            total_points=250,
            current_level=1,
        )
        user1 = UserModel(
            id=uuid.uuid4(),
            username="john_doe",
            email="john@example.com",
            total_points=250,
            current_level=1,
        )
        user2 = UserModel(
            id=uuid.uuid4(),
            username="jane_smith",
            email="jane@example.com",
            total_points=500,
            current_level=2,
        )
        user3 = UserModel(
            id=uuid.uuid4(),
            username="bob_wilson",
            email="bob@example.com",
            total_points=100,
            current_level=1,
        )

        session.add_all([test_user, user1, user2, user3])
        await session.flush()
        print(f"✓ Created 4 users (including test_user with fixed UUID)")

        # Create habits
        print("Creating habits...")
        # Habits for test user
        test_habit1 = HabitModel(
            id=uuid.uuid4(),
            user_id=test_user.id,
            name="Morning Exercise",
            description="30 minutes of exercise every morning",
            frequency=HabitFrequency.DAILY,
            difficulty=3,
            target_days=30,
            is_active=True,
        )
        test_habit2 = HabitModel(
            id=uuid.uuid4(),
            user_id=test_user.id,
            name="Read Books",
            description="Read for 20 minutes before bed",
            frequency=HabitFrequency.DAILY,
            difficulty=2,
            target_days=60,
            is_active=True,
        )
        habit1 = HabitModel(
            id=uuid.uuid4(),
            user_id=user1.id,
            name="Morning Exercise",
            description="30 minutes of exercise every morning",
            frequency=HabitFrequency.DAILY,
            difficulty=3,
            target_days=30,
            is_active=True,
        )
        habit2 = HabitModel(
            id=uuid.uuid4(),
            user_id=user1.id,
            name="Read Books",
            description="Read for 20 minutes before bed",
            frequency=HabitFrequency.DAILY,
            difficulty=2,
            target_days=60,
            is_active=True,
        )
        habit3 = HabitModel(
            id=uuid.uuid4(),
            user_id=user2.id,
            name="Meditation",
            description="10 minutes of meditation",
            frequency=HabitFrequency.DAILY,
            difficulty=2,
            target_days=30,
            is_active=True,
        )
        habit4 = HabitModel(
            id=uuid.uuid4(),
            user_id=user2.id,
            name="Weekly Review",
            description="Review goals and progress weekly",
            frequency=HabitFrequency.WEEKLY,
            difficulty=3,
            target_days=12,
            is_active=True,
        )
        habit5 = HabitModel(
            id=uuid.uuid4(),
            user_id=user3.id,
            name="Drink Water",
            description="8 glasses of water per day",
            frequency=HabitFrequency.DAILY,
            difficulty=1,
            target_days=30,
            is_active=True,
        )

        session.add_all(
            [test_habit1, test_habit2, habit1, habit2, habit3, habit4, habit5]
        )
        await session.flush()
        print(f"✓ Created 7 habits (2 for test_user)")

        # Create habit completions (last 7 days)
        print("Creating habit completions...")
        completions = []
        today = datetime.now()

        for i in range(7):
            date = today - timedelta(days=i)
            completions.append(
                HabitCompletionModel(
                    id=uuid.uuid4(),
                    habit_id=test_habit1.id,
                    user_id=test_user.id,
                    completed_at=date,
                    points_earned=30 + i * 3,
                    current_streak=i + 1,
                )
            )
            if i < 5:  # Not every day for reading
                completions.append(
                    HabitCompletionModel(
                        id=uuid.uuid4(),
                        habit_id=test_habit2.id,
                        user_id=test_user.id,
                        completed_at=date,
                        points_earned=20 + i * 2,
                        current_streak=i + 1,
                    )
                )

        # User 1 completions - consistent performer
        for i in range(7):
            date = today - timedelta(days=i)
            completions.append(
                HabitCompletionModel(
                    id=uuid.uuid4(),
                    habit_id=habit1.id,
                    user_id=user1.id,
                    completed_at=date,
                    points_earned=30 + i * 3,  # Increasing with streak
                    current_streak=i + 1,
                )
            )
            if i < 5:  # Not every day for reading
                completions.append(
                    HabitCompletionModel(
                        id=uuid.uuid4(),
                        habit_id=habit2.id,
                        user_id=user1.id,
                        completed_at=date,
                        points_earned=20 + i * 2,
                        current_streak=i + 1,
                    )
                )

        # User 2 completions - high achiever
        for i in range(7):
            date = today - timedelta(days=i)
            completions.append(
                HabitCompletionModel(
                    id=uuid.uuid4(),
                    habit_id=habit3.id,
                    user_id=user2.id,
                    completed_at=date,
                    points_earned=20 + i * 2,
                    current_streak=i + 1,
                )
            )

        # Weekly habit completion
        completions.append(
            HabitCompletionModel(
                id=uuid.uuid4(),
                habit_id=habit4.id,
                user_id=user2.id,
                completed_at=today - timedelta(days=1),
                points_earned=30,
                current_streak=1,
            )
        )

        # User 3 completions - beginner
        for i in range(3):
            date = today - timedelta(days=i)
            completions.append(
                HabitCompletionModel(
                    id=uuid.uuid4(),
                    habit_id=habit5.id,
                    user_id=user3.id,
                    completed_at=date,
                    points_earned=10 + i,
                    current_streak=i + 1,
                )
            )

        session.add_all(completions)
        await session.flush()
        print(f"✓ Created {len(completions)} habit completions")

        # Create achievements
        print("Creating achievements...")
        achievements = [
            AchievementModel(
                id=uuid.uuid4(),
                name="First Step",
                description="Complete your first habit",
                icon="star",
                achievement_type=AchievementType.TOTAL_HABITS,
                condition_value=1,
                reward_points=10,
                is_active=True,
            ),
            AchievementModel(
                id=uuid.uuid4(),
                name="Week Warrior",
                description="Maintain a 7-day streak",
                icon="flame",
                achievement_type=AchievementType.STREAK,
                condition_value=7,
                reward_points=50,
                is_active=True,
            ),
            AchievementModel(
                id=uuid.uuid4(),
                name="Habit Master",
                description="Complete 50 habits",
                icon="trophy",
                achievement_type=AchievementType.TOTAL_HABITS,
                condition_value=50,
                reward_points=100,
                is_active=True,
            ),
            AchievementModel(
                id=uuid.uuid4(),
                name="Level Up",
                description="Reach level 5",
                icon="medal",
                achievement_type=AchievementType.LEVEL,
                condition_value=5,
                reward_points=200,
                is_active=True,
            ),
            AchievementModel(
                id=uuid.uuid4(),
                name="Point Collector",
                description="Earn 1000 points",
                icon="gem",
                achievement_type=AchievementType.POINTS,
                condition_value=1000,
                reward_points=150,
                is_active=True,
            ),
            AchievementModel(
                id=uuid.uuid4(),
                name="Perfect Week",
                description="Complete all habits for a week",
                icon="crown",
                achievement_type=AchievementType.PERFECT_WEEK,
                condition_value=1,
                reward_points=100,
                is_active=True,
            ),
            AchievementModel(
                id=uuid.uuid4(),
                name="Month Streak",
                description="Maintain a 30-day streak",
                icon="fire",
                achievement_type=AchievementType.STREAK,
                condition_value=30,
                reward_points=300,
                is_active=True,
            ),
        ]

        session.add_all(achievements)
        await session.flush()
        print(f"✓ Created {len(achievements)} achievements")

        # Create a group
        print("Creating groups...")
        group1 = GroupModel(
            id=uuid.uuid4(),
            name="Morning Enthusiasts",
            description="Group for people who love morning routines",
            created_by=user1.id,
        )

        session.add(group1)
        await session.flush()

        # Add members to group
        members = [
            GroupMemberModel(
                id=uuid.uuid4(),
                group_id=group1.id,
                user_id=user1.id,
            ),
            GroupMemberModel(
                id=uuid.uuid4(),
                group_id=group1.id,
                user_id=user2.id,
            ),
        ]

        session.add_all(members)
        await session.flush()
        print(f"✓ Created 1 group with 2 members")

        # Commit all changes
        await session.commit()

        print("\n✅ Database seeding completed successfully!")
        print(f"\nSample data created:")
        print(
            f"  - 4 users (test_user with UUID 00000000-0000-0000-0000-000000000001, john_doe, jane_smith, bob_wilson)"
        )
        print(f"  - 7 habits (2 for test_user)")
        print(f"  - {len(completions)} completions")
        print(f"  - {len(achievements)} achievements")
        print(f"  - 1 group")


async def clear_database():
    """Clear all data from database (use with caution)."""
    async with AsyncSessionLocal() as session:
        print("🗑️  Clearing database...")

        # Order matters due to foreign keys
        await session.execute("DELETE FROM user_achievements")
        await session.execute("DELETE FROM group_members")
        await session.execute("DELETE FROM groups")
        await session.execute("DELETE FROM habit_completions")
        await session.execute("DELETE FROM habits")
        await session.execute("DELETE FROM achievements")
        await session.execute("DELETE FROM user_stats")
        await session.execute("DELETE FROM users")

        await session.commit()
        print("✅ Database cleared!")


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "--clear":
        asyncio.run(clear_database())
    else:
        asyncio.run(seed_database())
