from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from uuid import UUID


@dataclass
class Group:
    id: UUID
    name: str
    description: Optional[str]
    created_by: UUID
    created_at: datetime


@dataclass
class GroupMember:
    id: UUID
    group_id: UUID
    user_id: UUID
    joined_at: datetime
