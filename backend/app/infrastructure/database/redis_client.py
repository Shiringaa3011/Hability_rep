import os
import redis.asyncio as redis

redis_client: redis.Redis = None

async def init_redis():
    """Инициализирует асинхронного Redis клиента."""
    global redis_client
    redis_client = await redis.from_url(
        os.getenv("REDIS_URL", "redis://localhost:6379"),
        decode_responses=True  # автоматически декодировать строки
    )
    # Проверим подключение
    await redis_client.ping()
    print("Redis подключён.")

async def close_redis():
    """Закрывает соединение с Redis."""
    if redis_client:
        await redis_client.aclose()
        print("Redis отключён.")