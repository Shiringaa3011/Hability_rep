import uuid

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum as SQLEnum,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    Time,
    TypeDecorator,
    UniqueConstraint,
    text,
)
from sqlalchemy.dialects.postgresql import UUID as PostgreSQLUUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base
from app.domain.models.achievement import AchievementType
from app.domain.models.group_achievement import GroupAchievementType
from app.domain.models.habit import HabitFrequency
from app.domain.models.stats import StatsPeriod


class GUID(TypeDecorator):
    impl = String
    cache_ok = True

    def load_dialect_impl(self, dialect):
        if dialect.name == "postgresql":
            return dialect.type_descriptor(PostgreSQLUUID(as_uuid=True))
        else:
            return dialect.type_descriptor(String(36))

    def process_bind_param(self, value, dialect):
        if value is None:
            return value
        elif dialect.name == "postgresql":
            return value
        else:
            if isinstance(value, uuid.UUID):
                return str(value)
            return value

    def process_result_value(self, value, dialect):
        if value is None:
            return value
        elif dialect.name == "postgresql":
            return value
        else:
            if isinstance(value, str):
                return uuid.UUID(value)
            return value


class UserModel(Base):
    __tablename__ = "users"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    username = Column(String(100), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False, default="")
    total_points = Column(Integer, nullable=False, default=0)
    current_level = Column(Integer, nullable=False, default=0)
    fcm_token = Column(String(255), nullable=True)
    created_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    habits = relationship(
        "HabitModel", back_populates="user", cascade="all, delete-orphan"
    )
    completions = relationship(
        "HabitCompletionModel", back_populates="user", cascade="all, delete-orphan"
    )
    achievements = relationship(
        "UserAchievementModel", back_populates="user", cascade="all, delete-orphan"
    )
    stats = relationship(
        "UserStatsModel", back_populates="user", cascade="all, delete-orphan"
    )
    created_groups = relationship(
        "GroupModel", back_populates="creator", cascade="all, delete-orphan"
    )
    group_memberships = relationship(
        "GroupMemberModel", back_populates="user", cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<User(id={self.id}, username={self.username}, level={self.current_level})>"


class HabitModel(Base):
    __tablename__ = "habits"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    group_id = Column(
        GUID,
        ForeignKey("groups.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    scheduled_time = Column(Time, nullable=True)
    frequency = Column(  # type: ignore[var-annotated]
        SQLEnum(HabitFrequency, values_callable=lambda x: [e.value for e in x]),
        nullable=False,
        default=HabitFrequency.DAILY,
    )
    reminder_enabled = Column(Boolean, nullable=False, default=False)
    reminder_time = Column(Time, nullable=True)
    difficulty = Column(Integer, nullable=False)  # 1-5
    target_days = Column(Integer, nullable=False, default=30)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    day_of_week = Column(Integer, nullable=True)

    user = relationship("UserModel", back_populates="habits")
    completions = relationship(
        "HabitCompletionModel", back_populates="habit", cascade="all, delete-orphan"
    )

    group = relationship("GroupModel", back_populates="habits")

    __table_args__ = (Index("ix_habits_user_active", "user_id", "is_active"),)

    def __repr__(self):
        return f"<Habit(id={self.id}, name={self.name}, difficulty={self.difficulty})>"


class HabitCompletionModel(Base):
    __tablename__ = "habit_completions"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    habit_id = Column(
        GUID,
        ForeignKey("habits.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    completed_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), index=True
    )
    points_earned = Column(Integer, nullable=False)
    current_streak = Column(Integer, nullable=False, default=1)

    habit = relationship("HabitModel", back_populates="completions")
    user = relationship("UserModel", back_populates="completions")

    __table_args__ = (
        Index("ix_completions_habit_date", "habit_id", "completed_at"),
        Index(
            "uq_completion_per_day",
            "habit_id",
            "user_id",
            func.date(text("completed_at")),
            unique=True,
        ),
    )

    def __repr__(self):
        return f"<HabitCompletion(id={self.id}, habit_id={self.habit_id}, points={self.points_earned})>"


class AchievementModel(Base):
    __tablename__ = "achievements"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    name = Column(String(200), nullable=False, unique=True)
    description = Column(Text, nullable=False)
    icon = Column(String(100), nullable=False)
    achievement_type = Column(  # type: ignore[var-annotated]
        SQLEnum(AchievementType, values_callable=lambda x: [e.value for e in x]),
        nullable=False,
        index=True,
    )
    condition_value = Column(Integer, nullable=False)
    reward_points = Column(Integer, nullable=False, default=0)
    is_active = Column(Boolean, nullable=False, default=True)

    user_achievements = relationship(
        "UserAchievementModel",
        back_populates="achievement",
        cascade="all, delete-orphan",
    )

    __table_args__ = (
        Index("ix_achievements_type_active", "achievement_type", "is_active"),
    )

    def __repr__(self):
        return f"<Achievement(id={self.id}, name={self.name}, type={self.achievement_type})>"


class UserAchievementModel(Base):
    __tablename__ = "user_achievements"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    achievement_id = Column(
        GUID,
        ForeignKey("achievements.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    earned_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    notified = Column(Boolean, nullable=False, default=False)

    user = relationship("UserModel", back_populates="achievements")
    achievement = relationship("AchievementModel", back_populates="user_achievements")

    __table_args__ = (
        UniqueConstraint("user_id", "achievement_id", name="uq_user_achievement"),
    )

    def __repr__(self):
        return f"<UserAchievement(id={self.id}, user_id={self.user_id}, achievement_id={self.achievement_id})>"


class GroupModel(Base):
    __tablename__ = "groups"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    created_by = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    created_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    is_active = Column(Boolean, nullable=False, default=True)

    creator = relationship("UserModel", back_populates="created_groups")
    members = relationship(
        "GroupMemberModel", back_populates="group", cascade="all, delete-orphan"
    )
    habits = relationship("HabitModel", back_populates="group")

    def __repr__(self):
        return f"<Group(id={self.id}, name={self.name})>"


class GroupMemberModel(Base):
    __tablename__ = "group_members"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    group_id = Column(
        GUID,
        ForeignKey("groups.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    joined_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    group = relationship("GroupModel", back_populates="members")
    user = relationship("UserModel", back_populates="group_memberships")

    __table_args__ = (
        UniqueConstraint("group_id", "user_id", name="uq_group_member"),
    )

    def __repr__(self):
        return f"<GroupMember(id={self.id}, group_id={self.group_id}, user_id={self.user_id})>"


class GroupInviteModel(Base):
    __tablename__ = "group_invites"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    group_id = Column(
        GUID,
        ForeignKey("groups.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    from_user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    to_user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    status = Column(String(20), nullable=False, default="pending", index=True)
    created_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    __table_args__ = (
        Index("ix_group_invites_group_to_status", "group_id", "to_user_id", "status"),
    )


class UserNotificationSettingsModel(Base):
    __tablename__ = "user_notification_settings"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
        index=True,
    )
    allow_notifications = Column(Boolean, nullable=False, default=True)
    sound_enabled = Column(Boolean, nullable=False, default=True)
    vibration_enabled = Column(Boolean, nullable=False, default=True)
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )


class NotificationModel(Base):
    __tablename__ = "notifications"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    title = Column(String(40), nullable=False)
    body = Column(String(120), nullable=False)
    read = Column(Boolean, nullable=False, default=False)
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        index=True,
    )
    kind = Column(String(30), nullable=False, default="info")
    group_id = Column(
        GUID,
        ForeignKey("groups.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )


class UserStatsModel(Base):
    __tablename__ = "user_stats"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    period = Column(  # type: ignore[var-annotated]
        SQLEnum(StatsPeriod, values_callable=lambda x: [e.value for e in x]),
        nullable=False,
        index=True,
    )
    total_completions = Column(Integer, nullable=False, default=0)
    completion_rate = Column(Float, nullable=False, default=0.0)
    current_streak = Column(Integer, nullable=False, default=0)
    max_streak = Column(Integer, nullable=False, default=0)
    total_points_period = Column(Integer, nullable=False, default=0)
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    user = relationship("UserModel", back_populates="stats")

    __table_args__ = (
        UniqueConstraint("user_id", "period", name="uq_user_stats_period"),
        Index("ix_user_stats_user_period", "user_id", "period"),
    )

    def __repr__(self):
        return (
            f"<UserStats(id={self.id}, user_id={self.user_id}, period={self.period})>"
        )


class GroupAchievementModel(Base):
    __tablename__ = "group_achievements"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    name = Column(String(200), nullable=False, unique=True)
    description = Column(Text, nullable=False)
    icon = Column(String(100), nullable=False)
    achievement_type = Column(  # type: ignore[var-annotated]
        SQLEnum(
            GroupAchievementType,
            values_callable=lambda x: [e.value for e in x],
        ),
        nullable=False,
        index=True,
    )
    condition_value = Column(Integer, nullable=False)
    reward_points = Column(Integer, nullable=False, default=0)
    is_active = Column(Boolean, nullable=False, default=True)

    earned = relationship(
        "EarnedGroupAchievementModel",
        back_populates="achievement",
        cascade="all, delete-orphan",
    )

    __table_args__ = (
        Index(
            "ix_group_achievements_type_active",
            "achievement_type",
            "is_active",
        ),
    )

    def __repr__(self):
        return f"<GroupAchievement(id={self.id}, name={self.name})>"


class EarnedGroupAchievementModel(Base):
    __tablename__ = "earned_group_achievements"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    group_id = Column(
        GUID,
        ForeignKey("groups.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    achievement_id = Column(
        GUID,
        ForeignKey("group_achievements.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    earned_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    notified = Column(Boolean, nullable=False, default=False)

    group = relationship("GroupModel")
    achievement = relationship(
        "GroupAchievementModel", back_populates="earned"
    )

    __table_args__ = (
        UniqueConstraint(
            "group_id",
            "achievement_id",
            name="uq_group_achievement_earned",
        ),
    )

class VerificationCodeModel(Base):
    __tablename__ = "verification_codes"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    email = Column(String(255), nullable=False, index=True)
    code = Column(String(6), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    used = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

class PendingNotificationModel(Base):
    __tablename__ = "pending_notifications"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(40), nullable=False)
    body = Column(String(120), nullable=False)
    kind = Column(String(30), nullable=False, default="habit_reminder")
    scheduled_for = Column(DateTime(timezone=True), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    delivered = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())