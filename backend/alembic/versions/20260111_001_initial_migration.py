from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute("""
        DO $$ BEGIN
            CREATE TYPE habitfrequency AS ENUM ('daily', 'weekly');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)
    op.execute("""
        DO $$ BEGIN
            CREATE TYPE achievementtype AS ENUM ('streak', 'total_habits', 'level', 'points', 'perfect_week');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)
    op.execute("""
        DO $$ BEGIN
            CREATE TYPE statsperiod AS ENUM ('day', 'week', 'month');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)

    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("username", sa.String(100), nullable=False, unique=True),
        sa.Column("email", sa.String(255), nullable=False, unique=True),
        sa.Column("total_points", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("current_level", sa.Integer(), nullable=False, server_default="0"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
            onupdate=sa.func.now(),
        ),
    )
    op.create_index("ix_users_username", "users", ["username"])
    op.create_index("ix_users_email", "users", ["email"])

    op.create_table(
        "habits",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("name", sa.String(200), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column(
            "frequency",
            postgresql.ENUM(
                "daily", "weekly", name="habitfrequency", create_type=False
            ),
            nullable=False,
            server_default="daily",
        ),
        sa.Column("difficulty", sa.Integer(), nullable=False),
        sa.Column("target_days", sa.Integer(), nullable=False, server_default="30"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_habits_user_id", "habits", ["user_id"])
    op.create_index("ix_habits_user_active", "habits", ["user_id", "is_active"])

    op.create_table(
        "habit_completions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("habit_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "completed_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column("points_earned", sa.Integer(), nullable=False),
        sa.Column("current_streak", sa.Integer(), nullable=False, server_default="1"),
        sa.ForeignKeyConstraint(["habit_id"], ["habits.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_habit_completions_habit_id", "habit_completions", ["habit_id"])
    op.create_index("ix_habit_completions_user_id", "habit_completions", ["user_id"])
    op.create_index(
        "ix_habit_completions_completed_at", "habit_completions", ["completed_at"]
    )
    op.create_index(
        "ix_completions_habit_date", "habit_completions", ["habit_id", "completed_at"]
    )

    op.execute("""
        CREATE OR REPLACE FUNCTION date_only(timestamp with time zone)
        RETURNS date AS $$
            SELECT ($1 AT TIME ZONE 'UTC')::date;
        $$ LANGUAGE SQL IMMUTABLE;
    """)

    op.execute("""
        CREATE UNIQUE INDEX uq_user_habit_completion_date 
        ON habit_completions (user_id, habit_id, date_only(completed_at))
    """)

    op.create_table(
        "achievements",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(200), nullable=False, unique=True),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("icon", sa.String(100), nullable=False),
        sa.Column(
            "achievement_type",
            postgresql.ENUM(
                "streak",
                "total_habits",
                "level",
                "points",
                "perfect_week",
                name="achievementtype",
                create_type=False,
            ),
            nullable=False,
        ),
        sa.Column("condition_value", sa.Integer(), nullable=False),
        sa.Column("reward_points", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default="true"),
    )
    op.create_index(
        "ix_achievements_achievement_type", "achievements", ["achievement_type"]
    )
    op.create_index(
        "ix_achievements_type_active", "achievements", ["achievement_type", "is_active"]
    )

    op.create_table(
        "user_achievements",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("achievement_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "earned_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column("notified", sa.Boolean(), nullable=False, server_default="false"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(
            ["achievement_id"], ["achievements.id"], ondelete="CASCADE"
        ),
        sa.UniqueConstraint("user_id", "achievement_id", name="uq_user_achievement"),
    )
    op.create_index("ix_user_achievements_user_id", "user_achievements", ["user_id"])
    op.create_index(
        "ix_user_achievements_achievement_id", "user_achievements", ["achievement_id"]
    )

    op.create_table(
        "groups",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(200), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("created_by", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.ForeignKeyConstraint(["created_by"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_groups_created_by", "groups", ["created_by"])

    op.create_table(
        "group_members",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("group_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "joined_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.ForeignKeyConstraint(["group_id"], ["groups.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("group_id", "user_id", name="uq_group_member"),
    )
    op.create_index("ix_group_members_group_id", "group_members", ["group_id"])
    op.create_index("ix_group_members_user_id", "group_members", ["user_id"])

    op.create_table(
        "user_stats",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "period",
            postgresql.ENUM(
                "day", "week", "month", name="statsperiod", create_type=False
            ),
            nullable=False,
        ),
        sa.Column(
            "total_completions", sa.Integer(), nullable=False, server_default="0"
        ),
        sa.Column("completion_rate", sa.Float(), nullable=False, server_default="0.0"),
        sa.Column("current_streak", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("max_streak", sa.Integer(), nullable=False, server_default="0"),
        sa.Column(
            "total_points_period", sa.Integer(), nullable=False, server_default="0"
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
            onupdate=sa.func.now(),
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "period", name="uq_user_stats_period"),
    )
    op.create_index("ix_user_stats_user_id", "user_stats", ["user_id"])
    op.create_index("ix_user_stats_period", "user_stats", ["period"])
    op.create_index("ix_user_stats_user_period", "user_stats", ["user_id", "period"])


def downgrade() -> None:
    op.drop_table("user_stats")
    op.drop_table("group_members")
    op.drop_table("groups")
    op.drop_table("user_achievements")
    op.drop_table("achievements")
    op.drop_table("habit_completions")
    op.drop_table("habits")
    op.drop_table("users")

    op.execute("DROP TYPE IF EXISTS habitfrequency CASCADE")
    op.execute("DROP TYPE IF EXISTS achievementtype CASCADE")
    op.execute("DROP TYPE IF EXISTS statsperiod CASCADE")
