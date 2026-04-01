import asyncio
import grpc
import sys
import os
from dotenv import load_dotenv

load_dotenv()

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../generated')))

import habitly_pb2
import habitly_pb2_grpc

from app.infrastructure.database.db import init_db_pool, close_db_pool, create_tables
from app.infrastructure.database.redis_client import init_redis, close_redis
from app.domain.repositories.repositories import UserRepository, HabitRepository, CompletionRepository
from app.infrastructure.security.token_storage import TokenStorage
from app.domain.services.user_service import UserService
from app.domain.services.habit_service import HabitService
from app.domain.services.progress_service import ProgressService
from app.domain.repositories.repositories_group import GroupRepository, GroupInviteRepository, GroupHabitRepository, GroupHabitCompletionRepository
from app.domain.services.group_service import GroupService
from app.domain.services.group_habit_service import GroupHabitService

class HabitlyServicer(habitly_pb2_grpc.HabitlyServiceServicer):
    """
    gRPC сервис, реализующий методы из habitly.proto.
    Использует сервисный слой для бизнес-логики.
    """

    def __init__(self, user_service: UserService, habit_service: HabitService, progress_service: ProgressService):
        self.user_service = user_service
        self.habit_service = habit_service
        self.progress_service = progress_service

    def _get_user_id_from_token(self, token: str) -> str:
        """Извлекает user_id из JWT токена. Выбрасывает ValueError при ошибке."""
        return UserService.decode_jwt(token)

    def _extract_token_from_metadata(self, context) -> str:
        """Извлекает Bearer токен из метаданных gRPC."""
        metadata = dict(context.invocation_metadata())
        token = metadata.get("authorization", "")
        if token.startswith("Bearer "):
            token = token[7:]
        return token

    async def Register(self, request, context):
        try:
            user_id = await self.user_service.register(
                request.username, request.email, request.password
            )
            return habitly_pb2.RegisterResponse(
                success=True,
                user_id=user_id,
                message="Registration successful"
            )
        except ValueError as e:
            context.set_code(grpc.StatusCode.ALREADY_EXISTS)
            context.set_details(str(e))
            return habitly_pb2.RegisterResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details("Internal server error")
            return habitly_pb2.RegisterResponse(success=False, message=str(e))

    async def Login(self, request, context):
        try:
            token, user_id = await self.user_service.login(request.email, request.password)
            return habitly_pb2.LoginResponse(
                success=True,
                token=token,
                user_id=user_id,
                message="Login successful"
            )
        except ValueError as e:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details(str(e))
            return habitly_pb2.LoginResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details("Internal server error")
            return habitly_pb2.LoginResponse(success=False, message=str(e))

    async def Logout(self, request, context):
        try:
            await self.user_service.logout(request.token)
            return habitly_pb2.LogoutResponse(success=True)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.LogoutResponse(success=False)

    async def CreateHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details("Missing token")
            return habitly_pb2.Habit()

        try:
            user_id = self._get_user_id_from_token(token)
        except ValueError as e:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details(str(e))
            return habitly_pb2.Habit()

        try:
            habit_id = await self.habit_service.create_habit(
                user_id,
                request.title,
                request.description,
                request.target_days_per_week
            )
            return habitly_pb2.Habit(
                habit_id=habit_id,
                user_id=user_id,
                title=request.title,
                description=request.description,
                target_days_per_week=request.target_days_per_week
            )
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            context.set_details(str(e))
            return habitly_pb2.Habit()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details("Internal server error")
            return habitly_pb2.Habit()

    async def ListHabits(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details("Missing token")
            return habitly_pb2.ListHabitsResponse()

        try:
            user_id = self._get_user_id_from_token(token)
        except ValueError as e:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details(str(e))
            return habitly_pb2.ListHabitsResponse()

        try:
            habits_data = await self.habit_service.list_habits(user_id)
            habits_pb = []
            for h in habits_data:
                habits_pb.append(habitly_pb2.Habit(
                    habit_id=h['habit_id'],
                    user_id=h['user_id'],
                    title=h['title'],
                    description=h.get('description', ''),
                    target_days_per_week=h.get('target_days_per_week', 1),
                ))
            return habitly_pb2.ListHabitsResponse(habits=habits_pb)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details("Internal server error")
            return habitly_pb2.ListHabitsResponse()

    async def GetHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details("Missing token")
            return habitly_pb2.Habit()

        try:
            user_id = self._get_user_id_from_token(token)
        except ValueError as e:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details(str(e))
            return habitly_pb2.Habit()

        try:
            habit_data = await self.habit_service.get_habit(user_id, request.habit_id)
            return habitly_pb2.Habit(
                habit_id=habit_data['habit_id'],
                user_id=habit_data['user_id'],
                title=habit_data['title'],
                description=habit_data.get('description', ''),
                target_days_per_week=habit_data.get('target_days_per_week', 1),
            )
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            context.set_details(str(e))
            return habitly_pb2.Habit()
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            context.set_details(str(e))
            return habitly_pb2.Habit()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details("Internal server error")
            return habitly_pb2.Habit()

    async def UpdateHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details("Missing token")
            return habitly_pb2.Habit()

        try:
            user_id = self._get_user_id_from_token(token)
        except ValueError as e:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details(str(e))
            return habitly_pb2.Habit()

        try:
            await self.habit_service.update_habit(
                user_id,
                request.habit_id,
                request.title,
                request.description,
                request.target_days_per_week
            )
            return habitly_pb2.Habit(
                habit_id=request.habit_id,
                user_id=user_id,
                title=request.title,
                description=request.description,
                target_days_per_week=request.target_days_per_week,
            )
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            context.set_details(str(e))
            return habitly_pb2.Habit()
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            context.set_details(str(e))
            return habitly_pb2.Habit()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details("Internal server error")
            return habitly_pb2.Habit()

    async def DeleteHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details("Missing token")
            return habitly_pb2.DeleteHabitResponse(success=False)

        try:
            user_id = self._get_user_id_from_token(token)
        except ValueError as e:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details(str(e))
            return habitly_pb2.DeleteHabitResponse(success=False)

        try:
            await self.habit_service.delete_habit(user_id, request.habit_id)
            return habitly_pb2.DeleteHabitResponse(success=True)
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            context.set_details(str(e))
            return habitly_pb2.DeleteHabitResponse(success=False)
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            context.set_details(str(e))
            return habitly_pb2.DeleteHabitResponse(success=False)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details("Internal server error")
            return habitly_pb2.DeleteHabitResponse(success=False)

    # ---- Методы для выполнения привычек ----
    async def CompleteHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.CompleteHabitResponse(success=False, message="Missing token")

        try:
            user_id = self._get_user_id_from_token(token)
        except ValueError as e:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.CompleteHabitResponse(success=False, message=str(e))

        try:
            created = await self.progress_service.complete_habit(user_id, request.habit_id)
            if created:
                return habitly_pb2.CompleteHabitResponse(success=True, message="Habit completed")
            else:
                return habitly_pb2.CompleteHabitResponse(success=False, message="Already completed today")
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.CompleteHabitResponse(success=False, message=str(e))
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.CompleteHabitResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.CompleteHabitResponse(success=False, message="Internal error")

    # ---- Метод для получения статистики ----
    async def GetStatistics(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details("Missing token")
            return habitly_pb2.GetStatisticsResponse()

        try:
            user_id = self._get_user_id_from_token(token)
        except ValueError as e:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            context.set_details(str(e))
            return habitly_pb2.GetStatisticsResponse()

        try:
            stats_data = await self.progress_service.get_statistics(user_id, days=7)
            stats_pb = []
            for stat in stats_data:
                daily_stats_pb = []
                for daily in stat['daily_stats']:
                    daily_stats_pb.append(habitly_pb2.DailyStat(
                        date=daily['date'],
                        completed=daily['completed']
                    ))
                stats_pb.append(habitly_pb2.HabitStatistics(
                    habit_id=stat['habit_id'],
                    habit_title=stat['habit_title'],
                    total_completed=stat['total_completed'],
                    completion_rate=stat['completion_rate'],
                    daily_stats=daily_stats_pb
                ))
            return habitly_pb2.GetStatisticsResponse(stats=stats_pb)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details("Internal server error")
            return habitly_pb2.GetStatisticsResponse()
        
    # ----- Методы групп -----
    async def CreateGroup(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.CreateGroupResponse(success=False, message="Missing token")
        try:
            user_id = self._get_user_id_from_token(token)
            group_id = await self.group_service.create_group(user_id, request.name)
            return habitly_pb2.CreateGroupResponse(success=True, group_id=group_id)
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            return habitly_pb2.CreateGroupResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.CreateGroupResponse(success=False, message=str(e))

    async def InviteUser(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.InviteUserResponse(success=False, message="Missing token")
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_service.invite_user(request.group_id, user_id, request.username)
            return habitly_pb2.InviteUserResponse(success=True, message="Invite sent")
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            return habitly_pb2.InviteUserResponse(success=False, message=str(e))
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.InviteUserResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.InviteUserResponse(success=False, message=str(e))

    async def AcceptInvite(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.AcceptInviteResponse(success=False, message="Missing token")
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_service.accept_invite(request.invite_id, user_id)
            return habitly_pb2.AcceptInviteResponse(success=True, message="Invite accepted")
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            return habitly_pb2.AcceptInviteResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.AcceptInviteResponse(success=False, message=str(e))



    async def CreateGroupHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.CreateGroupHabitResponse(habit_id="")
        try:
            user_id = self._get_user_id_from_token(token)
            habit_id = await self.group_habit_service.create_habit(
                request.group_id, user_id, request.title, request.description, request.target_days_per_week
            )
            return habitly_pb2.CreateGroupHabitResponse(habit_id=habit_id)
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            return habitly_pb2.CreateGroupHabitResponse(habit_id="")
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.CreateGroupHabitResponse(habit_id="")
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.CreateGroupHabitResponse(habit_id="")

async def serve():
    """Инициализация и запуск gRPC сервера."""
    await init_db_pool()
    await create_tables()

    await init_redis()

    from app.infrastructure.database.db import pool
    user_repo = UserRepository(pool)
    habit_repo = HabitRepository(pool)
    completion_repo = CompletionRepository(pool)

    group_repo = GroupRepository(pool)
    group_invite_repo = GroupInviteRepository(pool)
    group_habit_repo = GroupHabitRepository(pool)
    group_habit_completion_repo = GroupHabitCompletionRepository(pool)

    group_service = GroupService(group_repo, group_invite_repo, user_repo)
    group_habit_service = GroupHabitService(group_habit_repo, group_repo, group_habit_completion_repo)

    token_storage = TokenStorage(redis_client)

    user_service = UserService(user_repo, token_storage)
    habit_service = HabitService(habit_repo)
    progress_service = ProgressService(habit_repo, completion_repo)

    server = grpc.aio.server()
    servicer = HabitlyServicer(user_service, habit_service, progress_service, group_service, group_habit_service)
    habitly_pb2_grpc.add_HabitlyServiceServicer_to_server(servicer, server)

    port = os.getenv("GRPC_PORT", "50052")
    server.add_insecure_port(f"0.0.0.0:{port}")
    print(f"Сервер запущен на порту {port}")

    await server.start()
    try:
        await server.wait_for_termination()
    except asyncio.CancelledError:
        print("Получен сигнал остановки сервера")
    finally:
        await close_db_pool()
        await close_redis()
        await server.stop(grace=5)
        print("Сервер остановлен")

if __name__ == "__main__":
    asyncio.run(serve())