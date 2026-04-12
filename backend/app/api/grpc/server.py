import grpc
import habitly_pb2
import habitly_pb2_grpc
from app.domain.services.user_service import UserService
from app.domain.services.habit_service import HabitService
from app.domain.services.progress_service import ProgressService
from app.domain.services.group_service import GroupService
from app.domain.services.group_habit_service import GroupHabitService


class HabitlyServicer(habitly_pb2_grpc.HabitlyServiceServicer):
    """
    gRPC сервис, реализующий все методы из habitly.proto.
    """

    def __init__(
        self,
        user_service: UserService,
        habit_service: HabitService,
        progress_service: ProgressService,
        group_service: GroupService,
        group_habit_service: GroupHabitService,
    ):
        self.user_service = user_service
        self.habit_service = habit_service
        self.progress_service = progress_service
        self.group_service = group_service
        self.group_habit_service = group_habit_service

    # Вспомогательные методы для работы с токеном

    def _extract_token_from_metadata(self, context) -> str:
        """Извлекает Bearer токен из метаданных gRPC."""
        metadata = dict(context.invocation_metadata())
        token = metadata.get("authorization", "")
        if token.startswith("Bearer "):
            token = token[7:]
        return token

    def _get_user_id_from_token(self, token: str) -> str:
        """Декодирует JWT и возвращает user_id. Выбрасывает ValueError."""
        return self.user_service.decode_jwt(token)

    # Методы пользователей

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
            return habitly_pb2.LoginResponse(success=False, message=str(e))

    async def Logout(self, request, context):
        try:
            await self.user_service.logout(request.token)
            return habitly_pb2.LogoutResponse(success=True)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.LogoutResponse(success=False)

    # Методы для личных привычек

    async def CreateHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.Habit()
        try:
            user_id = self._get_user_id_from_token(token)
            habit_id = await self.habit_service.create_habit(
                user_id, request.title, request.description, request.target_days_per_week
            )
            return habitly_pb2.Habit(
                habit_id=habit_id,
                user_id=user_id,
                title=request.title,
                description=request.description,
                target_days_per_week=request.target_days_per_week,
            )
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            return habitly_pb2.Habit()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.Habit()

    async def ListHabits(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.ListHabitsResponse()
        try:
            user_id = self._get_user_id_from_token(token)
            habits = await self.habit_service.list_habits(user_id)
            habits_pb = [
                habitly_pb2.Habit(
                    habit_id=h['habit_id'],
                    user_id=h['user_id'],
                    title=h['title'],
                    description=h.get('description', ''),
                    target_days_per_week=h.get('target_days_per_week', 1),
                )
                for h in habits
            ]
            return habitly_pb2.ListHabitsResponse(habits=habits_pb)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.ListHabitsResponse()

    async def GetHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.Habit()
        try:
            user_id = self._get_user_id_from_token(token)
            habit = await self.habit_service.get_habit(user_id, request.habit_id)
            return habitly_pb2.Habit(
                habit_id=habit['habit_id'],
                user_id=habit['user_id'],
                title=habit['title'],
                description=habit.get('description', ''),
                target_days_per_week=habit.get('target_days_per_week', 1),
            )
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.Habit()
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.Habit()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.Habit()

    async def UpdateHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.Habit()
        try:
            user_id = self._get_user_id_from_token(token)
            await self.habit_service.update_habit(
                user_id, request.habit_id, request.title, request.description, request.target_days_per_week
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
            return habitly_pb2.Habit()
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.Habit()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.Habit()

    async def DeleteHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.DeleteHabitResponse(success=False)
        try:
            user_id = self._get_user_id_from_token(token)
            await self.habit_service.delete_habit(user_id, request.habit_id)
            return habitly_pb2.DeleteHabitResponse(success=True)
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.DeleteHabitResponse(success=False)
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.DeleteHabitResponse(success=False)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.DeleteHabitResponse(success=False)

    async def CompleteHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.CompleteHabitResponse(success=False, message="Missing token")
        try:
            user_id = self._get_user_id_from_token(token)
            created = await self.progress_service.complete_habit(user_id, request.habit_id)
            if created:
                return habitly_pb2.CompleteHabitResponse(success=True, message="Completed")
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

    async def GetStatistics(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.GetStatisticsResponse()
        try:
            user_id = self._get_user_id_from_token(token)
            stats_data = await self.progress_service.get_statistics(user_id, days=7)
            stats_pb = []
            for stat in stats_data:
                daily_stats_pb = [
                    habitly_pb2.DailyStat(date=daily['date'], completed=daily['completed'])
                    for daily in stat['daily_stats']
                ]
                stats_pb.append(
                    habitly_pb2.HabitStatistics(
                        habit_id=stat['habit_id'],
                        habit_title=stat['habit_title'],
                        total_completed=stat['total_completed'],
                        completion_rate=stat['completion_rate'],
                        daily_stats=daily_stats_pb,
                    )
                )
            return habitly_pb2.GetStatisticsResponse(stats=stats_pb)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.GetStatisticsResponse()

    # Групповые методы

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

    async def DeclineInvite(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.DeclineInviteResponse(success=False)
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_service.decline_invite(request.invite_id, user_id)
            return habitly_pb2.DeclineInviteResponse(success=True)
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            return habitly_pb2.DeclineInviteResponse(success=False)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.DeclineInviteResponse(success=False)

    async def RequestJoinGroup(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.RequestJoinGroupResponse(success=False, message="Missing token")
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_service.request_join(request.group_id, user_id)
            return habitly_pb2.RequestJoinGroupResponse(success=True, message="Request sent")
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            return habitly_pb2.RequestJoinGroupResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.RequestJoinGroupResponse(success=False, message=str(e))

    async def ApproveJoinRequest(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.ApproveJoinRequestResponse(success=False, message="Missing token")
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_service.approve_join_request(request.invite_id, user_id)
            return habitly_pb2.ApproveJoinRequestResponse(success=True, message="Request approved")
        except ValueError as e:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            return habitly_pb2.ApproveJoinRequestResponse(success=False, message=str(e))
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.ApproveJoinRequestResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.ApproveJoinRequestResponse(success=False, message=str(e))

    async def LeaveGroup(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.LeaveGroupResponse(success=False, message="Missing token")
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_service.leave_group(request.group_id, user_id)
            return habitly_pb2.LeaveGroupResponse(success=True, message="Left group")
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.LeaveGroupResponse(success=False, message=str(e))
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.LeaveGroupResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.LeaveGroupResponse(success=False, message=str(e))

    async def DeleteGroup(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.DeleteGroupResponse(success=False)
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_service.delete_group(request.group_id, user_id)
            return habitly_pb2.DeleteGroupResponse(success=True)
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.DeleteGroupResponse(success=False)
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.DeleteGroupResponse(success=False)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.DeleteGroupResponse(success=False)

    async def GetGroupInfo(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.GetGroupInfoResponse()
        try:
            user_id = self._get_user_id_from_token(token)
            info = await self.group_service.get_group_info(request.group_id, user_id)
            members_pb = [
                habitly_pb2.GroupMember(user_id=m['user_id'], username=m['username'])
                for m in info['members']
            ]
            group_pb = habitly_pb2.Group(
                group_id=info['group_id'],
                name=info['name'],
                admin_user_id=info['admin_user_id'],
                max_members=info['max_members'],
                created_at=info['created_at'],
                members=members_pb,
            )
            return habitly_pb2.GetGroupInfoResponse(group=group_pb)
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.GetGroupInfoResponse()
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.GetGroupInfoResponse()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.GetGroupInfoResponse()

    async def ListUserGroups(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.ListUserGroupsResponse()
        try:
            user_id = self._get_user_id_from_token(token)
            groups = await self.group_service.list_user_groups(user_id)
            groups_pb = []
            for g in groups:
                members = await self.group_service.group_repo.get_members(g['group_id'])
                members_pb = [
                    habitly_pb2.GroupMember(user_id=str(m['user_id']), username=m['username'])
                    for m in members
                ]
                groups_pb.append(
                    habitly_pb2.Group(
                        group_id=str(g['group_id']),
                        name=g['name'],
                        admin_user_id=str(g['admin_user_id']),
                        max_members=g['max_members'],
                        created_at=g['created_at'].isoformat(),
                        members=members_pb,
                    )
                )
            return habitly_pb2.ListUserGroupsResponse(groups=groups_pb)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.ListUserGroupsResponse()

    async def GetPendingInvites(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.GetPendingInvitesResponse()
        try:
            user_id = self._get_user_id_from_token(token)
            invites = await self.group_service.get_pending_invites(user_id)
            invites_pb = [
                habitly_pb2.GroupInvite(
                    invite_id=inv['invite_id'],
                    group_id=inv['group_id'],
                    group_name=inv['group_name'],
                    from_username=inv['from_username'],
                    type=inv['type'],
                    status=inv['status'],
                )
                for inv in invites
            ]
            return habitly_pb2.GetPendingInvitesResponse(invites=invites_pb)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.GetPendingInvitesResponse()

    # Групповые привычки

    async def CreateGroupHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.CreateGroupHabitResponse(habit_id="")
        try:
            user_id = self._get_user_id_from_token(token)
            habit_id = await self.group_habit_service.create_habit(
                request.group_id,
                user_id,
                request.title,
                request.description,
                request.target_days_per_week,
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

    async def ListGroupHabits(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.ListGroupHabitsResponse()
        try:
            user_id = self._get_user_id_from_token(token)
            habits = await self.group_habit_service.list_habits(request.group_id, user_id)
            habits_pb = [
                habitly_pb2.GroupHabit(
                    habit_id=str(h['habit_id']),
                    group_id=str(h['group_id']),
                    creator_user_id=str(h['creator_user_id']),
                    title=h['title'],
                    description=h.get('description', ''),
                    target_days_per_week=h['target_days_per_week'],
                    created_at=h['created_at'].isoformat(),
                )
                for h in habits
            ]
            return habitly_pb2.ListGroupHabitsResponse(habits=habits_pb)
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.ListGroupHabitsResponse()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.ListGroupHabitsResponse()

    async def UpdateGroupHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.UpdateGroupHabitResponse(success=False)
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_habit_service.update_habit(
                request.habit_id,
                user_id,
                request.title,
                request.description,
                request.target_days_per_week,
            )
            return habitly_pb2.UpdateGroupHabitResponse(success=True)
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.UpdateGroupHabitResponse(success=False)
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.UpdateGroupHabitResponse(success=False)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.UpdateGroupHabitResponse(success=False)

    async def DeleteGroupHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.DeleteGroupHabitResponse(success=False)
        try:
            user_id = self._get_user_id_from_token(token)
            await self.group_habit_service.delete_habit(request.habit_id, user_id)
            return habitly_pb2.DeleteGroupHabitResponse(success=True)
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.DeleteGroupHabitResponse(success=False)
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.DeleteGroupHabitResponse(success=False)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.DeleteGroupHabitResponse(success=False)

    async def CompleteGroupHabit(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.CompleteGroupHabitResponse(success=False, message="Missing token")
        try:
            user_id = self._get_user_id_from_token(token)
            created = await self.group_habit_service.complete_habit(request.habit_id, user_id)
            if created:
                return habitly_pb2.CompleteGroupHabitResponse(success=True, message="Completed")
            else:
                return habitly_pb2.CompleteGroupHabitResponse(success=False, message="Already completed today")
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.CompleteGroupHabitResponse(success=False, message=str(e))
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.CompleteGroupHabitResponse(success=False, message=str(e))
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.CompleteGroupHabitResponse(success=False, message="Internal error")

    async def GetGroupHabitStatistics(self, request, context):
        token = self._extract_token_from_metadata(context)
        if not token:
            context.set_code(grpc.StatusCode.UNAUTHENTICATED)
            return habitly_pb2.GetGroupHabitStatisticsResponse()
        try:
            user_id = self._get_user_id_from_token(token)
            days = request.days if request.days else 7
            stats = await self.group_habit_service.get_habit_statistics(request.habit_id, user_id, days)
            statistics_pb = []
            for stat in stats['statistics']:
                daily_stats_pb = [
                    habitly_pb2.DailyStat(date=daily['date'], completed=daily['completed'])
                    for daily in stat['daily_stats']
                ]
                statistics_pb.append(
                    habitly_pb2.GroupHabitUserStat(
                        user_id=stat['user_id'],
                        username=stat['username'],
                        total_completed=stat['total_completed'],
                        completion_rate=stat['completion_rate'],
                        daily_stats=daily_stats_pb,
                    )
                )
            return habitly_pb2.GetGroupHabitStatisticsResponse(
                habit_id=stats['habit_id'],
                title=stats['title'],
                description=stats['description'],
                target_days_per_week=stats['target_days_per_week'],
                group_id=stats['group_id'],
                statistics=statistics_pb,
            )
        except ValueError as e:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            return habitly_pb2.GetGroupHabitStatisticsResponse()
        except PermissionError as e:
            context.set_code(grpc.StatusCode.PERMISSION_DENIED)
            return habitly_pb2.GetGroupHabitStatisticsResponse()
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            return habitly_pb2.GetGroupHabitStatisticsResponse()