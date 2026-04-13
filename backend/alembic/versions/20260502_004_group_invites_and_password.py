"""Add group invites table and password hash.

Revision ID: 004_group_invites_password
Revises: 003_mobile_features
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "004_group_invites_password"
down_revision = "003_mobile_features"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column("password_hash", sa.String(length=255), nullable=False, server_default=""),
    )

    op.create_table(
        "group_invites",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "group_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("groups.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "from_user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "to_user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("status", sa.String(length=20), nullable=False, server_default="pending"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_group_invites_group_id", "group_invites", ["group_id"])
    op.create_index("ix_group_invites_from_user_id", "group_invites", ["from_user_id"])
    op.create_index("ix_group_invites_to_user_id", "group_invites", ["to_user_id"])
    op.create_index("ix_group_invites_status", "group_invites", ["status"])
    op.create_index(
        "ix_group_invites_group_to_status",
        "group_invites",
        ["group_id", "to_user_id", "status"],
    )


def downgrade() -> None:
    op.drop_table("group_invites")
    op.drop_column("users", "password_hash")
