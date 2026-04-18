"""merge heads

Revision ID: 85f155293e92
Revises: 004_group_invites_password, 003_unique_completion_per_day
Create Date: 2026-05-08 17:04:09.587187

"""
from alembic import op
import sqlalchemy as sa


revision = '85f155293e92'
down_revision = ('004_group_invites_password', '003_unique_completion_per_day')
branch_labels = None
depends_on = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
