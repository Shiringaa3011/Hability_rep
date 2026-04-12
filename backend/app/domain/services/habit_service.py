from typing import List, Dict, Any

class HabitService:
    def __init__(self, habit_repo):
        self.habit_repo = habit_repo


    async def create_habit(self, user_id: str, title: str, description: str, target_days_per_week: int) -> str:
        """Создаёт привычку и возвращает её ID."""
        if not (1 <= target_days_per_week <= 7):
            raise ValueError("target_days_per_week must be between 1 and 7")
        habit_id = await self.habit_repo.create_habit(user_id, title, description, target_days_per_week)
        return habit_id
    
    async def list_habits(self, user_id: str) -> List[Dict[str, Any]]:
        """Возвращает список привычек пользователя."""
        return await self.habit_repo.get_habits_by_user(user_id)

    async def get_habit(self, user_id: str, habit_id: str) -> Dict[str, Any]:
        """Возвращает привычку, если она принадлежит пользователю."""
        habit = await self.habit_repo.get_habit_by_id(habit_id)
        if not habit:
            raise ValueError("Habit not found")
        if str(habit['user_id']) != user_id:
            raise PermissionError("Access denied to this habit")
        return habit

    async def update_habit(self, user_id: str, habit_id: str, title: str, description: str, target_days_per_week: int) -> None:
        """Обновляет привычку после проверки владельца."""
        habit = await self.habit_repo.get_habit_by_id(habit_id)
        if not habit:
            raise ValueError("Habit not found")
        if str(habit['user_id']) != user_id:
            raise PermissionError("Access denied to this habit")
        
        updated = await self.habit_repo.update_habit(habit_id, title, description, target_days_per_week)
        if not updated:
            raise RuntimeError("Failed to update habit")

    async def delete_habit(self, user_id: str, habit_id: str) -> None:
        """Удаляет привычку после проверки владельца."""
        habit = await self.habit_repo.get_habit_by_id(habit_id)
        if not habit:
            raise ValueError("Habit not found")
        if str(habit['user_id']) != user_id:
            raise PermissionError("Access denied to this habit")
        
        deleted = await self.habit_repo.delete_habit(habit_id)
        if not deleted:
            raise RuntimeError("Failed to delete habit")