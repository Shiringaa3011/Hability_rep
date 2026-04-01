from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import runtime_version as _runtime_version
from google.protobuf import symbol_database as _symbol_database
from google.protobuf.internal import builder as _builder
_runtime_version.ValidateProtobufRuntimeVersion(
    _runtime_version.Domain.PUBLIC,
    6,
    31,
    1,
    '',
    'habitly.proto'
)
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


from google.protobuf import timestamp_pb2 as google_dot_protobuf_dot_timestamp__pb2


DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\rhabitly.proto\x12\nhabitly.v1\x1a\x1fgoogle/protobuf/timestamp.proto\"D\n\x0fRegisterRequest\x12\x10\n\x08username\x18\x01 \x01(\t\x12\r\n\x05\x65mail\x18\x02 \x01(\t\x12\x10\n\x08password\x18\x03 \x01(\t\"E\n\x10RegisterResponse\x12\x0f\n\x07success\x18\x01 \x01(\x08\x12\x0f\n\x07user_id\x18\x02 \x01(\t\x12\x0f\n\x07message\x18\x03 \x01(\t\"/\n\x0cLoginRequest\x12\r\n\x05\x65mail\x18\x01 \x01(\t\x12\x10\n\x08password\x18\x02 \x01(\t\"Q\n\rLoginResponse\x12\x0f\n\x07success\x18\x01 \x01(\x08\x12\r\n\x05token\x18\x02 \x01(\t\x12\x0f\n\x07user_id\x18\x03 \x01(\t\x12\x0f\n\x07message\x18\x04 \x01(\t\"\x1e\n\rLogoutRequest\x12\r\n\x05token\x18\x01 \x01(\t\"!\n\x0eLogoutResponse\x12\x0f\n\x07success\x18\x01 \x01(\x08\"\xcc\x01\n\x05Habit\x12\x10\n\x08habit_id\x18\x01 \x01(\t\x12\x0f\n\x07user_id\x18\x02 \x01(\t\x12\r\n\x05title\x18\x03 \x01(\t\x12\x13\n\x0b\x64\x65scription\x18\x04 \x01(\t\x12\x1c\n\x14target_days_per_week\x18\x05 \x01(\x05\x12.\n\ncreated_at\x18\x06 \x01(\x0b\x32\x1a.google.protobuf.Timestamp\x12.\n\nupdated_at\x18\x07 \x01(\x0b\x32\x1a.google.protobuf.Timestamp\"V\n\x12\x43reateHabitRequest\x12\r\n\x05title\x18\x01 \x01(\t\x12\x13\n\x0b\x64\x65scription\x18\x02 \x01(\t\x12\x1c\n\x14target_days_per_week\x18\x03 \x01(\x05\"\x13\n\x11ListHabitsRequest\"7\n\x12ListHabitsResponse\x12!\n\x06habits\x18\x01 \x03(\x0b\x32\x11.habitly.v1.Habit\"#\n\x0fGetHabitRequest\x12\x10\n\x08habit_id\x18\x01 \x01(\t\"h\n\x12UpdateHabitRequest\x12\x10\n\x08habit_id\x18\x01 \x01(\t\x12\r\n\x05title\x18\x02 \x01(\t\x12\x13\n\x0b\x64\x65scription\x18\x03 \x01(\t\x12\x1c\n\x14target_days_per_week\x18\x04 \x01(\x05\"&\n\x12\x44\x65leteHabitRequest\x12\x10\n\x08habit_id\x18\x01 \x01(\t\"&\n\x13\x44\x65leteHabitResponse\x12\x0f\n\x07success\x18\x01 \x01(\x08\"(\n\x14\x43ompleteHabitRequest\x12\x10\n\x08habit_id\x18\x01 \x01(\t\"9\n\x15\x43ompleteHabitResponse\x12\x0f\n\x07success\x18\x01 \x01(\x08\x12\x0f\n\x07message\x18\x02 \x01(\t\"(\n\x14GetStatisticsRequest\x12\x10\n\x08habit_id\x18\x01 \x01(\t\",\n\tDailyStat\x12\x0c\n\x04\x64\x61te\x18\x01 \x01(\t\x12\x11\n\tcompleted\x18\x02 \x01(\x08\"\x96\x01\n\x0fHabitStatistics\x12\x10\n\x08habit_id\x18\x01 \x01(\t\x12\x13\n\x0bhabit_title\x18\x02 \x01(\t\x12\x17\n\x0ftotal_completed\x18\x03 \x01(\x05\x12\x17\n\x0f\x63ompletion_rate\x18\x04 \x01(\x01\x12*\n\x0b\x64\x61ily_stats\x18\x05 \x03(\x0b\x32\x15.habitly.v1.DailyStat\"C\n\x15GetStatisticsResponse\x12*\n\x05stats\x18\x01 \x03(\x0b\x32\x1b.habitly.v1.HabitStatistics2\xdf\x05\n\x0eHabitlyService\x12\x45\n\x08Register\x12\x1b.habitly.v1.RegisterRequest\x1a\x1c.habitly.v1.RegisterResponse\x12<\n\x05Login\x12\x18.habitly.v1.LoginRequest\x1a\x19.habitly.v1.LoginResponse\x12?\n\x06Logout\x12\x19.habitly.v1.LogoutRequest\x1a\x1a.habitly.v1.LogoutResponse\x12@\n\x0b\x43reateHabit\x12\x1e.habitly.v1.CreateHabitRequest\x1a\x11.habitly.v1.Habit\x12K\n\nListHabits\x12\x1d.habitly.v1.ListHabitsRequest\x1a\x1e.habitly.v1.ListHabitsResponse\x12:\n\x08GetHabit\x12\x1b.habitly.v1.GetHabitRequest\x1a\x11.habitly.v1.Habit\x12@\n\x0bUpdateHabit\x12\x1e.habitly.v1.UpdateHabitRequest\x1a\x11.habitly.v1.Habit\x12N\n\x0b\x44\x65leteHabit\x12\x1e.habitly.v1.DeleteHabitRequest\x1a\x1f.habitly.v1.DeleteHabitResponse\x12T\n\rCompleteHabit\x12 .habitly.v1.CompleteHabitRequest\x1a!.habitly.v1.CompleteHabitResponse\x12T\n\rGetStatistics\x12 .habitly.v1.GetStatisticsRequest\x1a!.habitly.v1.GetStatisticsResponseB\x03\x90\x01\x01\x62\x06proto3')

_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'habitly_pb2', _globals)
if not _descriptor._USE_C_DESCRIPTORS:
  _globals['DESCRIPTOR']._loaded_options = None
  _globals['DESCRIPTOR']._serialized_options = b'\220\001\001'
  _globals['_REGISTERREQUEST']._serialized_start=62
  _globals['_REGISTERREQUEST']._serialized_end=130
  _globals['_REGISTERRESPONSE']._serialized_start=132
  _globals['_REGISTERRESPONSE']._serialized_end=201
  _globals['_LOGINREQUEST']._serialized_start=203
  _globals['_LOGINREQUEST']._serialized_end=250
  _globals['_LOGINRESPONSE']._serialized_start=252
  _globals['_LOGINRESPONSE']._serialized_end=333
  _globals['_LOGOUTREQUEST']._serialized_start=335
  _globals['_LOGOUTREQUEST']._serialized_end=365
  _globals['_LOGOUTRESPONSE']._serialized_start=367
  _globals['_LOGOUTRESPONSE']._serialized_end=400
  _globals['_HABIT']._serialized_start=403
  _globals['_HABIT']._serialized_end=607
  _globals['_CREATEHABITREQUEST']._serialized_start=609
  _globals['_CREATEHABITREQUEST']._serialized_end=695
  _globals['_LISTHABITSREQUEST']._serialized_start=697
  _globals['_LISTHABITSREQUEST']._serialized_end=716
  _globals['_LISTHABITSRESPONSE']._serialized_start=718
  _globals['_LISTHABITSRESPONSE']._serialized_end=773
  _globals['_GETHABITREQUEST']._serialized_start=775
  _globals['_GETHABITREQUEST']._serialized_end=810
  _globals['_UPDATEHABITREQUEST']._serialized_start=812
  _globals['_UPDATEHABITREQUEST']._serialized_end=916
  _globals['_DELETEHABITREQUEST']._serialized_start=918
  _globals['_DELETEHABITREQUEST']._serialized_end=956
  _globals['_DELETEHABITRESPONSE']._serialized_start=958
  _globals['_DELETEHABITRESPONSE']._serialized_end=996
  _globals['_COMPLETEHABITREQUEST']._serialized_start=998
  _globals['_COMPLETEHABITREQUEST']._serialized_end=1038
  _globals['_COMPLETEHABITRESPONSE']._serialized_start=1040
  _globals['_COMPLETEHABITRESPONSE']._serialized_end=1097
  _globals['_GETSTATISTICSREQUEST']._serialized_start=1099
  _globals['_GETSTATISTICSREQUEST']._serialized_end=1139
  _globals['_DAILYSTAT']._serialized_start=1141
  _globals['_DAILYSTAT']._serialized_end=1185
  _globals['_HABITSTATISTICS']._serialized_start=1188
  _globals['_HABITSTATISTICS']._serialized_end=1338
  _globals['_GETSTATISTICSRESPONSE']._serialized_start=1340
  _globals['_GETSTATISTICSRESPONSE']._serialized_end=1407
  _globals['_HABITLYSERVICE']._serialized_start=1410
  _globals['_HABITLYSERVICE']._serialized_end=2145
_builder.BuildServices(DESCRIPTOR, 'habitly_pb2', _globals)
# @@protoc_insertion_point(module_scope)
