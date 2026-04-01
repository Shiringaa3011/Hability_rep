from typing import List, Dict, Any
from datetime import datetime, timedelta, timezone, date
from collections import defaultdict
from app.domain.repositories.repositories_group import GroupHabitRepository, GroupHabitCompletionRepository, GroupRepository

class GroupHabitService:
    def __init__(self, group_habit_repo: GroupHabitRepository, group_repo: GroupRepository, completion_repo: GroupHabitCompletionRepository):
        self.group_habit_repo = group_habit_repo
        self.group_repo = group_repo
        self.completion_repo = completion_repo

    async def create_habit(self, group_id: str, creator_user_id: str, title: str, description: str, target_days_per_week: int) -> str:
        members = await self.group_repo.get_members(group_id)
        if not any(str(m['user_id']) == creator_user_id for m in members):
            raise PermissionError("Not a member of the group")
        if not (1 <= target_days_per_week <= 7):
            raise ValueError("target_days_per_week must be between 1 and 7")
        habit_id = await self.group_habit_repo.create_habit(group_id, creator_user_id, title, description, target_days_per_week)
        return habit_id

    async def list_habits(self, group_id: str, user_id: str) -> List[Dict[str, Any]]:
        members = await self.group_repo.get_members(group_id)
        if not any(str(m['user_id']) == user_id for m in members):
            raise PermissionError("Not a member")
        return await self.group_habit_repo.get_habits_by_group(group_id)

    async def update_habit(self, habit_id: str, user_id: str, title: str, description: str, target_days_per_week: int):
        habit = await self.group_habit_repo.get_habit_by_id(habit_id)
        if not habit:
            raise ValueError("Habit not found")
        group = await self.group_repo.get_group_by_id(habit['group_id'])
        if str(habit['creator_user_id']) != user_id and str(group['admin_user_id']) != user_id:
            raise PermissionError("Only creator or admin can update habit")
        updated = await self.group_habit_repo.update_habit(habit_id, title, description, target_days_per_week)
        if not updated:
            raise RuntimeError("Failed to update habit")

    async def delete_habit(self, habit_id: str, user_id: str):
        habit = await self.group_habit_repo.get_habit_by_id(habit_id)
        if not habit:
            raise ValueError("Habit not found")
        group = await self.group_repo.get_group_by_id(habit['group_id'])
        if str(habit['creator_user_id']) != user_id and str(group['admin_user_id']) != user_id:
            raise PermissionError("Only creator or admin can delete habit")
        await self.group_habit_repo.delete_habit(habit_id)

    async def complete_habit(self, habit_id: str, user_id: str, completed_date: date = None) -> bool:
        if completed_date is None:
            completed_date = datetime.now(timezone.utc).date()
        habit = await self.group_habit_repo.get_habit_by_id(habit_id)
        if not habit:
            raise ValueError("Habit not found")
        group = await self.group_repo.get_group_by_id(habit['group_id'])
        members = await self.group_repo.get_members(group['group_id'])
        if not any(str(m['user_id']) == user_id for m in members):
            raise PermissionError("Not a member")
        return await self.completion_repo.complete_habit(habit_id, user_id, completed_date)

    async def get_habit_statistics(self, habit_id: str, user_id: str, days: int = 7) -> Dict[str, Any]:
        habit = await self.group_habit_repo.get_habit_by_id(habit_id)
        if not habit:
            raise ValueError("Habit not found")
        group = await self.group_repo.get_group_by_id(habit['group_id'])
        members = await self.group_repo.get_members(group['group_id'])
        if not any(str(m['user_id']) == user_id for m in members):
            raise PermissionError("Not a member")

        end_date = datetime.now(timezone.utc).date()
        start_date = end_date - timedelta(days=days-1)

        completions = await self.completion_repo.get_completions_for_habit(habit_id, start_date=start_date, end_date=end_date)
        user_completions = defaultdict(list)
        for c in completions:
            user_completions[str(c['user_id'])].append(c['completed_date'].isoformat())

        stats = []
        for m in members:
            uid = str(m['user_id'])
            comp_dates = user_completions.get(uid, [])
            total = 0
            daily = []
            current = start_date
            while current <= end_date:
                d_str = current.isoformat()
                completed = d_str in comp_dates
                if completed:
                    total += 1
                daily.append({"date": d_str, "completed": completed})
                current += timedelta(days=1)
            rate = (total / days) * 100 if days > 0 else 0
            stats.append({
                "user_id": uid,
                "username": m['username'],
                "total_completed": total,
                "completion_rate": round(rate, 2),
                "daily_stats": daily
            })
        return {
            "habit_id": str(habit['habit_id']),
            "title": habit['title'],
            "description": habit['description'],
            "target_days_per_week": habit['target_days_per_week'],
            "group_id": str(group['group_id']),
            "statistics": stats
        }