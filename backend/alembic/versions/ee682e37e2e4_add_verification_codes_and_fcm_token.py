"""add verification_codes and fcm_token

Revision ID: ee682e37e2e4
Revises: c0c271280dbb
Create Date: 2026-05-21

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

revision: str = 'ee682e37e2e4'
down_revision: Union[str, None] = 'c0c271280dbb'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Добавить колонку fcm_token в users
    op.add_column('users', sa.Column('fcm_token', sa.String(255), nullable=True))
    
    # Создать таблицу verification_codes
    op.create_table(
        'verification_codes',
        sa.Column('id', UUID(as_uuid=True), primary_key=True),
        sa.Column('email', sa.String(255), nullable=False, index=True),
        sa.Column('code', sa.String(6), nullable=False),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('used', sa.Boolean(), nullable=False, default=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )


def downgrade() -> None:
    op.drop_table('verification_codes')
    op.drop_column('users', 'fcm_token')