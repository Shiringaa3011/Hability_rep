from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.infrastructure.database.models import UserModel
from app.schemas.mobile import RegisterRequest, RegisterResponse

router = APIRouter()


@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
async def register_user(request: RegisterRequest, db: AsyncSession = Depends(get_db)):
    existing = (
        await db.execute(select(UserModel).where(UserModel.email == request.email.strip()))
    ).scalar_one_or_none()
    if existing is not None:
        raise HTTPException(status_code=400, detail="Email already registered")

    username = request.username.strip() if request.username else request.email.split("@")[0]
    if len(username) < 3:
        username = f"user_{uuid4().hex[:8]}"

    # TODO(security): заменить на нормальный хеш пароля (bcrypt/argon2) + auth flow.
    user = UserModel(
        username=username,
        email=request.email.strip().lower(),
        password_hash=request.password,
        total_points=0,
        current_level=0,
    )
    db.add(user)
    await db.flush()
    await db.refresh(user)
    return RegisterResponse(user_id=user.id, username=user.username, email=user.email)
