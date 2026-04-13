"""Add mobile feature tables and columns.

Revision ID: 003_mobile_features
Revises: 002_group_achievements
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "003_mobile_features"
down_revision = "002_group_achievements"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("groups", sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")))

    op.add_column("habits", sa.Column("group_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("habits", sa.Column("scheduled_time", sa.Time(), nullable=True))
    op.add_column("habits", sa.Column("reminder_enabled", sa.Boolean(), nullable=False, server_default=sa.text("false")))
    op.add_column("habits", sa.Column("reminder_time", sa.Time(), nullable=True))
    op.create_foreign_key(
        "fk_habits_group_id_groups",
        "habits",
        "groups",
        ["group_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.create_index("ix_habits_group_id", "habits", ["group_id"])

    op.create_table(
        "user_notification_settings",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
            unique=True,
        ),
        sa.Column("allow_notifications", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("sound_enabled", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("vibration_enabled", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_user_notification_settings_user_id", "user_notification_settings", ["user_id"])

    op.create_table(
        "notifications",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("title", sa.String(length=40), nullable=False),
        sa.Column("body", sa.String(length=120), nullable=False),
        sa.Column("read", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("kind", sa.String(length=30), nullable=False, server_default="info"),
        sa.Column(
            "group_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("groups.id", ondelete="SET NULL"),
            nullable=True,
        ),
    )
    op.create_index("ix_notifications_user_id", "notifications", ["user_id"])
    op.create_index("ix_notifications_created_at", "notifications", ["created_at"])
    op.create_index("ix_notifications_group_id", "notifications", ["group_id"])


def downgrade() -> None:
    op.drop_table("notifications")
    op.drop_table("user_notification_settings")

    op.drop_index("ix_habits_group_id", table_name="habits")
    op.drop_constraint("fk_habits_group_id_groups", "habits", type_="foreignkey")
    op.drop_column("habits", "reminder_time")
    op.drop_column("habits", "reminder_enabled")
    op.drop_column("habits", "scheduled_time")
    op.drop_column("habits", "group_id")

    op.drop_column("groups", "is_active")
