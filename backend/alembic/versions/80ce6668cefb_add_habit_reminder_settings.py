"""add habit_reminder_settings

Revision ID: 80ce6668cefb
Revises: 7592a47ea984
Create Date: 2026-05-23 22:59:07.722863

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

revision = '80ce6668cefb'
down_revision = '7592a47ea984'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'habit_reminder_settings',
        sa.Column('id', UUID(as_uuid=True), primary_key=True),
        sa.Column('habit_id', UUID(as_uuid=True), sa.ForeignKey('habits.id', ondelete='CASCADE'), nullable=False),
        sa.Column('user_id', UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('reminder_enabled', sa.Boolean(), nullable=False, server_default=sa.text('false')),
        sa.Column('reminder_time', sa.Time(), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.UniqueConstraint('habit_id', 'user_id', name='uq_habit_reminder'),
    )

def downgrade() -> None:
    op.drop_table('habit_reminder_settings')
