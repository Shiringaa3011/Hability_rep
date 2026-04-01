from asyncpg import Pool
from app.infrastructure.database.db import pool
from typing import List, Dict, Any, Optional
from datetime import date
import os

class GroupRepository:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def create_group(self, name: str, admin_user_id: str, max_members: int = None) -> str:
        if max_members is None:
            max_members = int(os.getenv("GROUP_MAX_MEMBERS", "10"))
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "INSERT INTO groups (name, admin_user_id, max_members) VALUES ($1, $2, $3) RETURNING group_id",
                name, admin_user_id, max_members
            )
            return str(row['group_id'])

    async def get_group_by_id(self, group_id: str) -> Optional[Dict[str, Any]]:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow("SELECT * FROM groups WHERE group_id = $1", group_id)
            return dict(row) if row else None

    async def get_groups_by_user(self, user_id: str) -> List[Dict[str, Any]]:
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT g.* FROM groups g
                JOIN group_members gm ON g.group_id = gm.group_id
                WHERE gm.user_id = $1
                """,
                user_id
            )
            return [dict(row) for row in rows]

    async def delete_group(self, group_id: str) -> bool:
        async with self.pool.acquire() as conn:
            result = await conn.execute("DELETE FROM groups WHERE group_id = $1", group_id)
            return result.split()[1] != '0'

    async def add_member(self, group_id: str, user_id: str) -> bool:
        async with self.pool.acquire() as conn:
            try:
                await conn.execute(
                    "INSERT INTO group_members (group_id, user_id) VALUES ($1, $2)",
                    group_id, user_id
                )
                return True
            except:
                return False

    async def remove_member(self, group_id: str, user_id: str) -> bool:
        async with self.pool.acquire() as conn:
            result = await conn.execute(
                "DELETE FROM group_members WHERE group_id = $1 AND user_id = $2",
                group_id, user_id
            )
            return result.split()[1] != '0'

    async def get_members(self, group_id: str) -> List[Dict[str, Any]]:
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT u.user_id, u.username, u.email
                FROM group_members gm
                JOIN users u ON gm.user_id = u.user_id
                WHERE gm.group_id = $1
                """,
                group_id
            )
            return [dict(row) for row in rows]

    async def get_member_count(self, group_id: str) -> int:
        async with self.pool.acquire() as conn:
            count = await conn.fetchval(
                "SELECT COUNT(*) FROM group_members WHERE group_id = $1",
                group_id
            )
            return count

class GroupInviteRepository:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def create_invite(self, group_id: str, from_user_id: str, to_user_id: str, invite_type: str) -> str:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "INSERT INTO group_invites (group_id, from_user_id, to_user_id, type) VALUES ($1, $2, $3, $4) RETURNING invite_id",
                group_id, from_user_id, to_user_id, invite_type
            )
            return str(row['invite_id'])

    async def get_invite_by_id(self, invite_id: str) -> Optional[Dict[str, Any]]:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow("SELECT * FROM group_invites WHERE invite_id = $1", invite_id)
            return dict(row) if row else None

    async def get_pending_invite(self, group_id: str, to_user_id: str, invite_type: str) -> Optional[Dict[str, Any]]:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT * FROM group_invites WHERE group_id = $1 AND to_user_id = $2 AND type = $3 AND status = 'pending'",
                group_id, to_user_id, invite_type
            )
            return dict(row) if row else None

    async def update_status(self, invite_id: str, status: str) -> bool:
        async with self.pool.acquire() as conn:
            result = await conn.execute(
                "UPDATE group_invites SET status = $1, updated_at = NOW() WHERE invite_id = $2",
                status, invite_id
            )
            return result.split()[1] != '0'

    async def get_invites_for_user(self, user_id: str, status: str = 'pending') -> List[Dict[str, Any]]:
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                "SELECT * FROM group_invites WHERE to_user_id = $1 AND status = $2",
                user_id, status
            )
            return [dict(row) for row in rows]

    async def delete_invites_for_group(self, group_id: str):
        async with self.pool.acquire() as conn:
            await conn.execute("DELETE FROM group_invites WHERE group_id = $1", group_id)

class GroupHabitRepository:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def create_habit(self, group_id: str, creator_user_id: str, title: str, description: str, target_days_per_week: int) -> str:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                "INSERT INTO group_habits (group_id, creator_user_id, title, description, target_days_per_week) VALUES ($1, $2, $3, $4, $5) RETURNING habit_id",
                group_id, creator_user_id, title, description, target_days_per_week
            )
            return str(row['habit_id'])

    async def get_habit_by_id(self, habit_id: str) -> Optional[Dict[str, Any]]:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow("SELECT * FROM group_habits WHERE habit_id = $1", habit_id)
            return dict(row) if row else None

    async def get_habits_by_group(self, group_id: str) -> List[Dict[str, Any]]:
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                "SELECT * FROM group_habits WHERE group_id = $1 ORDER BY created_at DESC",
                group_id
            )
            return [dict(row) for row in rows]

    async def update_habit(self, habit_id: str, title: str, description: str, target_days_per_week: int) -> bool:
        async with self.pool.acquire() as conn:
            result = await conn.execute(
                "UPDATE group_habits SET title = $1, description = $2, target_days_per_week = $3, updated_at = NOW() WHERE habit_id = $4",
                title, description, target_days_per_week, habit_id
            )
            return result.split()[1] != '0'

    async def delete_habit(self, habit_id: str) -> bool:
        async with self.pool.acquire() as conn:
            result = await conn.execute("DELETE FROM group_habits WHERE habit_id = $1", habit_id)
            return result.split()[1] != '0'

class GroupHabitCompletionRepository:
    def __init__(self, pool: Pool):
        self.pool = pool

    async def complete_habit(self, habit_id: str, user_id: str, completed_date: date) -> bool:
        async with self.pool.acquire() as conn:
            try:
                await conn.execute(
                    "INSERT INTO group_habit_completions (habit_id, user_id, completed_date) VALUES ($1, $2, $3)",
                    habit_id, user_id, completed_date
                )
                return True
            except:
                return False

    async def get_completions_for_habit(self, habit_id: str, user_id: str = None, start_date: date = None, end_date: date = None) -> List[Dict[str, Any]]:
        query = "SELECT * FROM group_habit_completions WHERE habit_id = $1"
        params = [habit_id]
        if user_id:
            query += " AND user_id = $2"
            params.append(user_id)
        if start_date and end_date:
            query += " AND completed_date BETWEEN $" + str(len(params)+1) + " AND $" + str(len(params)+2)
            params.extend([start_date, end_date])
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, *params)
            return [dict(row) for row in rows]

    async def delete_completions_for_user_in_group(self, group_id: str, user_id: str):
        async with self.pool.acquire() as conn:
            await conn.execute(
                """
                DELETE FROM group_habit_completions
                WHERE habit_id IN (SELECT habit_id FROM group_habits WHERE group_id = $1)
                AND user_id = $2
                """,
                group_id, user_id
            )