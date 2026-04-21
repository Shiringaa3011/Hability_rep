import asyncpg
from asyncpg import Pool
from app.infrastructure.database.db import pool
from typing import Optional, Dict, Any
from datetime import date

class UserRepository:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def create_user(self, username: str, email: str, password_hash: str) -> str:
        """Создаёт пользователя и возвращает его user_id."""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                """
                INSERT INTO users (username, email, password_hash)
                VALUES ($1, $2, $3)
                RETURNING user_id
                """,
                username, email, password_hash
            )
            return str(row['user_id'])

    async def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Возвращает пользователя по email или None."""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT user_id, username, email, password_hash, created_at FROM users WHERE email = $1",
                email
            )
            if row:
                return dict(row)
            return None

    async def get_user_by_username(self, username: str) -> Optional[Dict[str, Any]]:
        """Возвращает пользователя по username."""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT user_id, username, email, password_hash, created_at FROM users WHERE username = $1",
                username
            )
            if row:
                return dict(row)
            return None

    async def get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Возвращает пользователя по user_id (без пароля)."""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT user_id, username, email, created_at FROM users WHERE user_id = $1",
                user_id
            )
            if row:
                return dict(row)
            return None
        
class HabitRepository:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def create_habit(self, user_id: str, title: str, description: str, target_days_per_week: int) -> str:
        """Создаёт привычку и возвращает её habit_id."""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                """
                INSERT INTO habits (user_id, title, description, target_days_per_week)
                VALUES ($1, $2, $3, $4)
                RETURNING habit_id
                """,
                user_id, title, description, target_days_per_week
            )
            return str(row['habit_id'])

    async def get_habits_by_user(self, user_id: str) -> list:
        """Возвращает список всех привычек пользователя."""
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT habit_id, user_id, title, description, target_days_per_week, created_at, updated_at
                FROM habits
                WHERE user_id = $1
                ORDER BY created_at DESC
                """,
                user_id
            )
            
            return [dict(row) for row in rows]

    async def get_habit_by_id(self, habit_id: str) -> Optional[Dict[str, Any]]:
        """Возвращает привычку по ID."""
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                """
                SELECT habit_id, user_id, title, description, target_days_per_week, created_at, updated_at
                FROM habits
                WHERE habit_id = $1
                """,
                habit_id
            )
            if row:
                return dict(row)
            return None

    async def update_habit(self, habit_id: str, title: str, description: str, target_days_per_week: int) -> bool:
        """Обновляет привычку. Возвращает True, если обновление произошло."""
        async with self.pool.acquire() as conn:
            result = await conn.execute(
                """
                UPDATE habits
                SET title = $2, description = $3, target_days_per_week = $4, updated_at = NOW()
                WHERE habit_id = $1
                """,
                habit_id, title, description, target_days_per_week
            )
            return result.split()[1] != '0'

    async def delete_habit(self, habit_id: str) -> bool:
        """Удаляет привычку. Возвращает True, если удаление произошло."""
        async with self.pool.acquire() as conn:
            result = await conn.execute(
                "DELETE FROM habits WHERE habit_id = $1",
                habit_id
            )
            return result.split()[1] != '0'
        

class CompletionRepository:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def complete_habit(self, habit_id: str, completed_date: str) -> bool:
        """
        Отмечает выполнение привычки за указанную дату (формат 'YYYY-MM-DD').
        Возвращает True, если запись создана (новая), False если уже была.
        """
        async with self.pool.acquire() as conn:
            try:
                await conn.execute(
                    """
                    INSERT INTO habit_completions (habit_id, completed_date)
                    VALUES ($1, $2)
                    """,
                    habit_id, completed_date
                )
                return True
            except asyncpg.UniqueViolationError:
                return False

    async def get_completions_for_habit(self, habit_id: str, start_date: str, end_date: str) -> list:
        """
        Возвращает список дат выполнения привычки в заданном диапазоне.
        """
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT completed_date
                FROM habit_completions
                WHERE habit_id = $1 AND completed_date BETWEEN $2 AND $3
                """,
                habit_id, start_date, end_date
            )
            return [row['completed_date'].isoformat() for row in rows]

    async def get_all_completions_for_user(self, user_id: str, start_date: date, end_date: date) -> dict:
        """
        Для всех привычек пользователя возвращает словарь:
        { habit_id: [дата1, дата2, ...] }
        """
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT h.habit_id, hc.completed_date
                FROM habits h
                LEFT JOIN habit_completions hc ON h.habit_id = hc.habit_id
                WHERE h.user_id = $1
                AND (hc.completed_date IS NULL OR hc.completed_date BETWEEN $2 AND $3)
                """,
                user_id, start_date, end_date
            )
            print(f"DEBUG get_all_completions: user_id={user_id}, start={start_date}, end={end_date}")
            print(f"DEBUG rows count={len(rows)}")
            for r in rows:
                print(f"  habit_id={r['habit_id']}, completed_date={r['completed_date']}")
            result = {}
            for row in rows:
                habit_id = str(row['habit_id'])
                if habit_id not in result:
                    result[habit_id] = []
                if row['completed_date']:
                    result[habit_id].append(row['completed_date'].isoformat())
            return result