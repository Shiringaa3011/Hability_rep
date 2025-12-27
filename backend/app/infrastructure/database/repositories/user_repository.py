from typing import Optional
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.infrastructure.database.models import UserModel
from app.infrastructure.database.repositories.base_repository import BaseRepository


class UserRepository(BaseRepository[UserModel]):
    def __init__(self, session: AsyncSession):
        super().__init__(UserModel, session)

    async def get_by_username(self, username: str) -> Optional[UserModel]:
        result = await self.session.execute(
            select(UserModel).where(UserModel.username == username)
        )
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> Optional[UserModel]:
        result = await self.session.execute(
            select(UserModel).where(UserModel.email == email)
        )
        return result.scalar_one_or_none()

    async def add_points(self, user_id: UUID, points: int) -> Optional[UserModel]:
        user = await self.get_by_id(user_id)
        if user:
            user.total_points += points  # type: ignore[assignment]
            return await self.update(user)
        return None

    async def update_level(self, user_id: UUID, level: int) -> Optional[UserModel]:
        user = await self.get_by_id(user_id)
        if user:
            user.current_level = level  # type: ignore[assignment]
            return await self.update(user)
        return None
