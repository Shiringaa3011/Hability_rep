"""add pending_notifications

Revision ID: e665707af454
Revises: ee682e37e2e4
Create Date: 2026-05-23

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

revision: str = 'e665707af454'
down_revision: Union[str, None] = 'ee682e37e2e4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'pending_notifications',
        sa.Column('id', UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('title', sa.String(40), nullable=False),
        sa.Column('body', sa.String(120), nullable=False),
        sa.Column('kind', sa.String(30), nullable=False, server_default='habit_reminder'),
        sa.Column('scheduled_for', sa.DateTime(timezone=True), nullable=False),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('delivered', sa.Boolean(), nullable=False, server_default=sa.text('false')),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table('pending_notifications')