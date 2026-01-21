"""Test configuration and fixtures."""

from typing import AsyncGenerator

import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.database import Base, get_db
from app.infrastructure.database.models import (
    AchievementModel,
    GroupMemberModel,
    GroupModel,
    HabitCompletionModel,
    HabitModel,
    UserAchievementModel,
    UserModel,
    UserStatsModel,
)
from main import app

# Test database URL - using SQLite for fast in-memory tests
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"


@pytest_asyncio.fixture(scope="function")
async def test_engine():
    """Create test database engine."""
    engine = create_async_engine(
        TEST_DATABASE_URL,
        echo=False,
        future=True,
    )

    # Create all tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    # Drop all tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()


@pytest_asyncio.fixture(scope="function")
async def db_session(test_engine) -> AsyncGenerator[AsyncSession, None]:
    """Create test database session."""
    # Create session factory
    async_session_maker = async_sessionmaker(
        test_engine,
        class_=AsyncSession,
        expire_on_commit=False,
        autocommit=False,
        autoflush=False,
    )

    async with async_session_maker() as session:
        yield session
        await session.rollback()
        await session.close()


@pytest_asyncio.fixture(scope="function")
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """Create test HTTP client with overridden database dependency."""

    async def override_get_db() -> AsyncGenerator[AsyncSession, None]:
        """Override get_db dependency to use test database."""
        yield db_session

    # Override the dependency
    app.dependency_overrides[get_db] = override_get_db

    async with AsyncClient(app=app, base_url="http://test") as test_client:
        yield test_client

    # Clear overrides
    app.dependency_overrides.clear()
