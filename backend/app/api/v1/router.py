from fastapi import APIRouter

from app.api.v1.endpoints import achievements, gamification, stats

api_router = APIRouter()

api_router.include_router(
    gamification.router, prefix="/gamification", tags=["gamification"]
)

api_router.include_router(stats.router, prefix="/stats", tags=["statistics"])

api_router.include_router(
    achievements.router, prefix="/achievements", tags=["achievements"]
)
