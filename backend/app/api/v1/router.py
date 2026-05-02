from fastapi import APIRouter

from app.api.v1.endpoints import (
    achievements,
    gamification,
    group_achievements,
    groups,
    habits,
    notifications,
    stats,
    users,
    auth,
)

api_router = APIRouter()

api_router.include_router(
    gamification.router, prefix="/gamification", tags=["gamification"]
)

api_router.include_router(stats.router, prefix="/stats", tags=["statistics"])

api_router.include_router(
    achievements.router, prefix="/achievements", tags=["achievements"]
)

api_router.include_router(
    group_achievements.router,
    prefix="/achievements/group",
    tags=["group-achievements"],
)

api_router.include_router(groups.router, prefix="/groups", tags=["groups"])
api_router.include_router(habits.router, prefix="/habits", tags=["habits"])
api_router.include_router(
    notifications.router,
    prefix="/notifications",
    tags=["notifications"],
)
api_router.include_router(users.router, prefix="/users", tags=["users"])

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
