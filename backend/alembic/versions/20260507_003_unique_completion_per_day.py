"""Add unique index preventing duplicate habit completions on the same day.

Revision ID: 003_unique_completion_per_day
Revises: 002_group_achievements
"""

<<<<<<< HEAD
=======
import sqlalchemy as sa
>>>>>>> main
from alembic import op

revision = "003_unique_completion_per_day"
down_revision = "002_group_achievements"
branch_labels = None
depends_on = None


def upgrade() -> None:
<<<<<<< HEAD
    op.execute("""
        CREATE OR REPLACE FUNCTION to_utc_date(timestamptz)
        RETURNS date AS $$
            SELECT ($1 AT TIME ZONE 'UTC')::date;
        $$ LANGUAGE SQL IMMUTABLE
    """)
    
    op.execute("""
        CREATE UNIQUE INDEX uq_completion_per_day 
        ON habit_completions (habit_id, user_id, to_utc_date(completed_at))
    """)
=======
    op.add_column(
        "habit_completions",
        sa.Column("completion_date", sa.Date(), nullable=True),
    )
    op.execute(
        "UPDATE habit_completions SET completion_date = (completed_at AT TIME ZONE 'UTC')::date"
    )
    op.alter_column("habit_completions", "completion_date", nullable=False)
    op.execute(
        "CREATE UNIQUE INDEX uq_completion_per_day "
        "ON habit_completions (habit_id, user_id, completion_date)"
    )
>>>>>>> main


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS uq_completion_per_day")
<<<<<<< HEAD
    op.execute("DROP FUNCTION IF EXISTS to_utc_date(timestamptz)")
=======
    op.drop_column("habit_completions", "completion_date")
>>>>>>> main
