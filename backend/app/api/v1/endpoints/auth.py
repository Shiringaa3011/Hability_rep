from datetime import datetime, timedelta, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.infrastructure.database.models import UserModel, VerificationCodeModel
from app.infrastructure.services.email_service import send_verification_code
from app.schemas.mobile import SendCodeRequest, VerifyCodeRequest
from app.schemas.mobile import LoginRequest

router = APIRouter()


@router.post("/send-code", status_code=status.HTTP_204_NO_CONTENT)
async def send_code(request: SendCodeRequest, db: AsyncSession = Depends(get_db)):
    """Отправить код подтверждения на почту"""
    user_stmt = select(UserModel).where(UserModel.email == request.email)
    user = (await db.execute(user_stmt)).scalar_one_or_none()
    if not user:
        return
    
    code = await send_verification_code(request.email)
    
    verification = VerificationCodeModel(
        email=request.email,
        code=code,
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=10),
    )
    db.add(verification)
    await db.flush()


@router.post("/verify-code")
async def verify_code(request: VerifyCodeRequest, db: AsyncSession = Depends(get_db)):
    """Проверить код и вернуть данные пользователя"""
    code_stmt = select(VerificationCodeModel).where(
        VerificationCodeModel.email == request.email,
        VerificationCodeModel.code == request.code,
        VerificationCodeModel.used == False,
        VerificationCodeModel.expires_at > datetime.now(timezone.utc),
    ).order_by(VerificationCodeModel.created_at.desc())
    verification = (await db.execute(code_stmt)).scalar_one_or_none()
    
    if not verification:
        raise HTTPException(status_code=400, detail="Неверный или истёкший код")
    
    verification.used = True
    
    user_stmt = select(UserModel).where(UserModel.email == request.email)
    user = (await db.execute(user_stmt)).scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    
    await db.flush()
    
    return {
        "user_id": str(user.id),
        "username": user.username,
        "email": user.email,
    }


@router.post("/login")
async def login(request: LoginRequest, db: AsyncSession = Depends(get_db)):
    """Вход в аккаунт"""
    user_stmt = select(UserModel).where(UserModel.email == request.email.strip())
    user = (await db.execute(user_stmt)).scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=401, detail="Неверный email или пароль")
    
    if user.password_hash != request.password:
        raise HTTPException(status_code=401, detail="Неверный email или пароль")
    
    return {
        "user_id": str(user.id),
        "username": user.username,
        "email": user.email,
    }