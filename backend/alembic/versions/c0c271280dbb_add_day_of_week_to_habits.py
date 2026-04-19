"""add_day_of_week_to_habits

Revision ID: c0c271280dbb
Revises: 85f155293e92
Create Date: 2026-05-09 09:02:55.867374

"""
from alembic import op
import sqlalchemy as sa


revision = 'c0c271280dbb'
down_revision = '85f155293e92'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('habits', sa.Column('day_of_week', sa.Integer, nullable=True))


def downgrade() -> None:
    op.drop_column('habits', 'day_of_week')
