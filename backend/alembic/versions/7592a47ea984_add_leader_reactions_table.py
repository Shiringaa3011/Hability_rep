"""add leader_reactions table

Revision ID: 7592a47ea984
Revises: e665707af454
Create Date: 2026-05-23

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID


revision: str = '7592a47ea984'
down_revision: Union[str, None] = 'e665707af454'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'leader_reactions',
        sa.Column('id', UUID(as_uuid=True), primary_key=True),
        sa.Column('group_id', UUID(as_uuid=True), sa.ForeignKey('groups.id', ondelete='CASCADE'), nullable=False),
        sa.Column('from_user_id', UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('to_user_id', UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.UniqueConstraint('group_id', 'from_user_id', 'to_user_id', name='uq_leader_reaction'),
    )
    op.create_index('ix_leader_reactions_group_id', 'leader_reactions', ['group_id'])
    op.create_index('ix_leader_reactions_to_user_id', 'leader_reactions', ['to_user_id'])


def downgrade() -> None:
    op.drop_table('leader_reactions')