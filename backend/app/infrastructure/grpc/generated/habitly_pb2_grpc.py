"""Client and server classes corresponding to protobuf-defined services."""
import grpc
import warnings

import habitly_pb2 as habitly__pb2

GRPC_GENERATED_VERSION = '1.80.0'
GRPC_VERSION = grpc.__version__
_version_not_supported = False

try:
    from grpc._utilities import first_version_is_lower
    _version_not_supported = first_version_is_lower(GRPC_VERSION, GRPC_GENERATED_VERSION)
except ImportError:
    _version_not_supported = True

if _version_not_supported:
    raise RuntimeError(
        f'The grpc package installed is at version {GRPC_VERSION},'
        + ' but the generated code in habitly_pb2_grpc.py depends on'
        + f' grpcio>={GRPC_GENERATED_VERSION}.'
        + f' Please upgrade your grpc module to grpcio>={GRPC_GENERATED_VERSION}'
        + f' or downgrade your generated code using grpcio-tools<={GRPC_VERSION}.'
    )


class HabitlyServiceStub(object):
    """---- СЕРВИС (все RPC-методы) ----
    """

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.Register = channel.unary_unary(
                '/habitly.v1.HabitlyService/Register',
                request_serializer=habitly__pb2.RegisterRequest.SerializeToString,
                response_deserializer=habitly__pb2.RegisterResponse.FromString,
                _registered_method=True)
        self.Login = channel.unary_unary(
                '/habitly.v1.HabitlyService/Login',
                request_serializer=habitly__pb2.LoginRequest.SerializeToString,
                response_deserializer=habitly__pb2.LoginResponse.FromString,
                _registered_method=True)
        self.Logout = channel.unary_unary(
                '/habitly.v1.HabitlyService/Logout',
                request_serializer=habitly__pb2.LogoutRequest.SerializeToString,
                response_deserializer=habitly__pb2.LogoutResponse.FromString,
                _registered_method=True)
        self.CreateHabit = channel.unary_unary(
                '/habitly.v1.HabitlyService/CreateHabit',
                request_serializer=habitly__pb2.CreateHabitRequest.SerializeToString,
                response_deserializer=habitly__pb2.Habit.FromString,
                _registered_method=True)
        self.ListHabits = channel.unary_unary(
                '/habitly.v1.HabitlyService/ListHabits',
                request_serializer=habitly__pb2.ListHabitsRequest.SerializeToString,
                response_deserializer=habitly__pb2.ListHabitsResponse.FromString,
                _registered_method=True)
        self.GetHabit = channel.unary_unary(
                '/habitly.v1.HabitlyService/GetHabit',
                request_serializer=habitly__pb2.GetHabitRequest.SerializeToString,
                response_deserializer=habitly__pb2.Habit.FromString,
                _registered_method=True)
        self.UpdateHabit = channel.unary_unary(
                '/habitly.v1.HabitlyService/UpdateHabit',
                request_serializer=habitly__pb2.UpdateHabitRequest.SerializeToString,
                response_deserializer=habitly__pb2.Habit.FromString,
                _registered_method=True)
        self.DeleteHabit = channel.unary_unary(
                '/habitly.v1.HabitlyService/DeleteHabit',
                request_serializer=habitly__pb2.DeleteHabitRequest.SerializeToString,
                response_deserializer=habitly__pb2.DeleteHabitResponse.FromString,
                _registered_method=True)
        self.CompleteHabit = channel.unary_unary(
                '/habitly.v1.HabitlyService/CompleteHabit',
                request_serializer=habitly__pb2.CompleteHabitRequest.SerializeToString,
                response_deserializer=habitly__pb2.CompleteHabitResponse.FromString,
                _registered_method=True)
        self.GetStatistics = channel.unary_unary(
                '/habitly.v1.HabitlyService/GetStatistics',
                request_serializer=habitly__pb2.GetStatisticsRequest.SerializeToString,
                response_deserializer=habitly__pb2.GetStatisticsResponse.FromString,
                _registered_method=True)


class HabitlyServiceServicer(object):
    """---- СЕРВИС (все RPC-методы) ----
    """

    def Register(self, request, context):
        """Регистрация нового пользователя
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def Login(self, request, context):
        """Аутентификация (логин)
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def Logout(self, request, context):
        """Выход (инвалидация токена)
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def CreateHabit(self, request, context):
        """Создание привычки
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def ListHabits(self, request, context):
        """Получение списка всех привычек пользователя
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def GetHabit(self, request, context):
        """Получение информации об одной привычке по ID
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def UpdateHabit(self, request, context):
        """Обновление привычки (название, описание, цель)
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def DeleteHabit(self, request, context):
        """Удаление привычки
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def CompleteHabit(self, request, context):
        """Отметка выполнения привычки за сегодня (или конкретную дату)
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def GetStatistics(self, request, context):
        """Получение статистики выполнения за последние 7 дней
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_HabitlyServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'Register': grpc.unary_unary_rpc_method_handler(
                    servicer.Register,
                    request_deserializer=habitly__pb2.RegisterRequest.FromString,
                    response_serializer=habitly__pb2.RegisterResponse.SerializeToString,
            ),
            'Login': grpc.unary_unary_rpc_method_handler(
                    servicer.Login,
                    request_deserializer=habitly__pb2.LoginRequest.FromString,
                    response_serializer=habitly__pb2.LoginResponse.SerializeToString,
            ),
            'Logout': grpc.unary_unary_rpc_method_handler(
                    servicer.Logout,
                    request_deserializer=habitly__pb2.LogoutRequest.FromString,
                    response_serializer=habitly__pb2.LogoutResponse.SerializeToString,
            ),
            'CreateHabit': grpc.unary_unary_rpc_method_handler(
                    servicer.CreateHabit,
                    request_deserializer=habitly__pb2.CreateHabitRequest.FromString,
                    response_serializer=habitly__pb2.Habit.SerializeToString,
            ),
            'ListHabits': grpc.unary_unary_rpc_method_handler(
                    servicer.ListHabits,
                    request_deserializer=habitly__pb2.ListHabitsRequest.FromString,
                    response_serializer=habitly__pb2.ListHabitsResponse.SerializeToString,
            ),
            'GetHabit': grpc.unary_unary_rpc_method_handler(
                    servicer.GetHabit,
                    request_deserializer=habitly__pb2.GetHabitRequest.FromString,
                    response_serializer=habitly__pb2.Habit.SerializeToString,
            ),
            'UpdateHabit': grpc.unary_unary_rpc_method_handler(
                    servicer.UpdateHabit,
                    request_deserializer=habitly__pb2.UpdateHabitRequest.FromString,
                    response_serializer=habitly__pb2.Habit.SerializeToString,
            ),
            'DeleteHabit': grpc.unary_unary_rpc_method_handler(
                    servicer.DeleteHabit,
                    request_deserializer=habitly__pb2.DeleteHabitRequest.FromString,
                    response_serializer=habitly__pb2.DeleteHabitResponse.SerializeToString,
            ),
            'CompleteHabit': grpc.unary_unary_rpc_method_handler(
                    servicer.CompleteHabit,
                    request_deserializer=habitly__pb2.CompleteHabitRequest.FromString,
                    response_serializer=habitly__pb2.CompleteHabitResponse.SerializeToString,
            ),
            'GetStatistics': grpc.unary_unary_rpc_method_handler(
                    servicer.GetStatistics,
                    request_deserializer=habitly__pb2.GetStatisticsRequest.FromString,
                    response_serializer=habitly__pb2.GetStatisticsResponse.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'habitly.v1.HabitlyService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))
    server.add_registered_method_handlers('habitly.v1.HabitlyService', rpc_method_handlers)


class HabitlyService(object):
    """---- СЕРВИС (все RPC-методы) ----
    """

    @staticmethod
    def Register(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/Register',
            habitly__pb2.RegisterRequest.SerializeToString,
            habitly__pb2.RegisterResponse.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def Login(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/Login',
            habitly__pb2.LoginRequest.SerializeToString,
            habitly__pb2.LoginResponse.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def Logout(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/Logout',
            habitly__pb2.LogoutRequest.SerializeToString,
            habitly__pb2.LogoutResponse.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def CreateHabit(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/CreateHabit',
            habitly__pb2.CreateHabitRequest.SerializeToString,
            habitly__pb2.Habit.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def ListHabits(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/ListHabits',
            habitly__pb2.ListHabitsRequest.SerializeToString,
            habitly__pb2.ListHabitsResponse.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def GetHabit(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/GetHabit',
            habitly__pb2.GetHabitRequest.SerializeToString,
            habitly__pb2.Habit.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def UpdateHabit(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/UpdateHabit',
            habitly__pb2.UpdateHabitRequest.SerializeToString,
            habitly__pb2.Habit.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def DeleteHabit(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/DeleteHabit',
            habitly__pb2.DeleteHabitRequest.SerializeToString,
            habitly__pb2.DeleteHabitResponse.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def CompleteHabit(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/CompleteHabit',
            habitly__pb2.CompleteHabitRequest.SerializeToString,
            habitly__pb2.CompleteHabitResponse.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def GetStatistics(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/habitly.v1.HabitlyService/GetStatistics',
            habitly__pb2.GetStatisticsRequest.SerializeToString,
            habitly__pb2.GetStatisticsResponse.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)
