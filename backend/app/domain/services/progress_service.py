from datetime import datetime, timedelta, date, timezone
from typing import List, Dict, Any
from app.domain.repositories.repositories import HabitRepository, CompletionRepository

class ProgressService:
    def __init__(self, habit_repo: HabitRepository, completion_repo: CompletionRepository):
        self.habit_repo = habit_repo
        self.completion_repo = completion_repo

    async def complete_habit(self, user_id: str, habit_id: str, completed_date: date = None) -> bool:
        """
        Отмечает выполнение привычки.
        Если completed_date не указан, используется сегодняшняя дата (UTC).
        Возвращает True, если запись создана, False если уже была отмечена.
        """
        if completed_date is None:
            completed_date = datetime.now(timezone.utc).date()
        
        # Проверяем, принадлежит ли привычка пользователю
        habit = await self.habit_repo.get_habit_by_id(habit_id)
        if not habit:
            raise ValueError("Habit not found")
        if str(habit['user_id']) != user_id:
            raise PermissionError("Access denied")
        
        # Сохраняем выполнение
        created = await self.completion_repo.complete_habit(habit_id, completed_date)
        return created

    async def get_statistics(self, user_id: str, days: int = 7) -> List[Dict[str, Any]]:
        """
        Возвращает статистику по всем привычкам пользователя за последние `days` дней.
        """
        # 1. Получаем все привычки пользователя
        habits = await self.habit_repo.get_habits_by_user(user_id)
        if not habits:
            return []

        # 2. Определяем диапазон дат (последние `days` дней включительно)
        end_date = datetime.now(timezone.utc).date()
        start_date = end_date - timedelta(days=days-1)

        # 3. Получаем все выполнения за этот период (словарь habit_id -> list дат)
        completions_map = await self.completion_repo.get_all_completions_for_user(
            user_id, start_date, end_date
        )

        # 4. Формируем статистику для каждой привычки
        result = []
        for habit in habits:
            # Проверяем, что привычка принадлежит пользователю
            if str(habit['user_id']) != user_id:
                continue

            habit_id = str(habit['habit_id'])
            completions = completions_map.get(habit_id, [])

            daily_stats = []
            total_completed = 0
            current = start_date
            while current <= end_date:
                date_str = current.isoformat()
                completed = date_str in completions
                if completed:
                    total_completed += 1
                daily_stats.append({"date": date_str, "completed": completed})
                current += timedelta(days=1)

            completion_rate = (total_completed / days) * 100.0 if days > 0 else 0.0

            result.append({
                "habit_id": habit_id,
                "habit_title": habit['title'],
                "total_completed": total_completed,
                "completion_rate": round(completion_rate, 2),
                "daily_stats": daily_stats
            })

        return result