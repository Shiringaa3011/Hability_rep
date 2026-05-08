"""Add unique index preventing duplicate habit completions on the same day.

Revision ID: 003_unique_completion_per_day
Revises: 002_group_achievements
"""

from alembic import op

revision = "003_unique_completion_per_day"
down_revision = "002_group_achievements"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(
        "CREATE UNIQUE INDEX uq_completion_per_day "
        "ON habit_completions (habit_id, user_id, (completed_at::date))"
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS uq_completion_per_day")
