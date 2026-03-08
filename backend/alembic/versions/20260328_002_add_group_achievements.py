"""Add group achievements tables.

Revision ID: 002_group_achievements
Revises: 001_initial
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "002_group_achievements"
down_revision = "001_initial"
branch_labels = None
depends_on = None


def upgrade() -> None:
    groupachievementtype = postgresql.ENUM(
        "group_total_habits",
        "group_all_streak",
        "group_perfect_week",
        name="groupachievementtype",
        create_type=False,
    )
    groupachievementtype.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "group_achievements",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(200), nullable=False, unique=True),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("icon", sa.String(100), nullable=False),
        sa.Column(
            "achievement_type",
            groupachievementtype,
            nullable=False,
        ),
        sa.Column("condition_value", sa.Integer(), nullable=False),
        sa.Column(
            "reward_points", sa.Integer(), nullable=False, server_default="0"
        ),
        sa.Column(
            "is_active",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("true"),
        ),
    )

    op.create_index(
        "ix_group_achievements_type_active",
        "group_achievements",
        ["achievement_type", "is_active"],
    )

    op.create_table(
        "earned_group_achievements",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "group_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("groups.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "achievement_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("group_achievements.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "earned_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column(
            "notified",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
        ),
        sa.UniqueConstraint(
            "group_id",
            "achievement_id",
            name="uq_group_achievement_earned",
        ),
    )

    op.create_index(
        "ix_earned_group_achievements_group_id",
        "earned_group_achievements",
        ["group_id"],
    )
    op.create_index(
        "ix_earned_group_achievements_achievement_id",
        "earned_group_achievements",
        ["achievement_id"],
    )


def downgrade() -> None:
    op.drop_table("earned_group_achievements")
    op.drop_table("group_achievements")
    op.execute("DROP TYPE IF EXISTS groupachievementtype")
