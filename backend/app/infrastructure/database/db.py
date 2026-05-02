import os
from pathlib import Path
import asyncpg
from asyncpg import Pool

pool: Pool = None

def _get_project_root() -> Path:
    """Возвращает корневую папку проекта (где лежат папки src, sql, docker-compose.yml)."""
    return Path(__file__).parent.parent

def _load_sql_file(relative_path: str) -> str:
    """Загружает SQL-файл из папки sql/ (относительно корня проекта)."""
    root = _get_project_root()
    sql_path = root / "sql" / relative_path
    with open(sql_path, 'r', encoding='utf-8') as f:
        return f.read()

async def init_db_pool():
    """Создаёт пул соединений к PostgreSQL."""
    global pool
    pool = await asyncpg.create_pool(
        user=os.getenv("POSTGRES_USER", "habitly_user"),
        password=os.getenv("POSTGRES_PASSWORD", "habitly_pass"),
        database=os.getenv("POSTGRES_DB", "habitly_db"),
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        min_size=1,
        max_size=10,
        command_timeout=60
    )
    print("Пул соединений с PostgreSQL создан.")
    return pool

async def close_db_pool():
    """Закрывает пул соединений."""
    global pool
    if pool:
        await pool.close()
        print("Пул соединений закрыт.")

async def create_tables():
    """
    Создаёт таблицы, если их нет, выполняя SQL из файла sql/schema.sql.
    """
    if pool is None:
        raise RuntimeError("Пул не инициализирован. Сначала вызовите init_db_pool().")
    
    schema_sql = _load_sql_file("schema.sql")
    async with pool.acquire() as conn:
        await conn.execute(schema_sql)
        print("Таблицы созданы/проверены (из schema.sql).")

def load_query(relative_path: str) -> str:
    """
    Загружает SQL-запрос из файла.
    Возвращает строку с запросом.
    """
    return _load_sql_file(relative_path)