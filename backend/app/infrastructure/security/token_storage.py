from typing import Optional
import redis.asyncio as redis

class TokenStorage:
    def __init__(self, redis_client: redis.Redis):
        self.redis_client = redis_client

    async def save_token(self, token: str, user_id: str, ttl_seconds: int = 86400) -> None:
        await self.redis_client.setex(token, ttl_seconds, user_id)

    async def get_user_id_by_token(self, token: str) -> Optional[str]:
        return await self.redis_client.get(token)

    async def delete_token(self, token: str) -> None:
        await self.redis_client.delete(token)

    async def exists(self, token: str) -> bool:
        return await self.redis_client.exists(token) == 1