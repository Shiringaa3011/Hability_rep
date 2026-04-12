import bcrypt
import jwt
import os
from datetime import datetime, timedelta, timezone
from typing import Tuple
from app.domain.repositories.repositories import UserRepository
from app.infrastructure.security.token_storage import TokenStorage

JWT_SECRET = os.getenv("JWT_SECRET_KEY")
JWT_ALGORITHM = "HS256"
JWT_EXPIRES_HOURS = 24

class UserService:
    def __init__(self, user_repo: UserRepository, token_storage: TokenStorage):
        self.user_repo = user_repo
        self.token_storage = token_storage

    async def register(self, username: str, email: str, password: str) -> str:
        """
        Регистрация нового пользователя.
        Возвращает user_id (строка).
        Выбрасывает исключения при конфликте (уже существует).
        """
        existing_by_username = await self.user_repo.get_user_by_username(username)
        if existing_by_username:
            raise ValueError("Username already exists")
        
        existing_by_email = await self.user_repo.get_user_by_email(email)
        if existing_by_email:
            raise ValueError("Email already exists")
        
        password_hash = self._hash_password(password)
        
        user_id = await self.user_repo.create_user(username, email, password_hash)
        return user_id

    async def login(self, email: str, password: str) -> Tuple[str, str]:
        """
        Аутентификация пользователя.
        Возвращает (token, user_id).
        Выбрасывает исключение при неверных учётных данных.
        """
        user = await self.user_repo.get_user_by_email(email)
        if not user:
            raise ValueError("Invalid credentials")
        
        if not self._check_password(password, user['password_hash']):
            raise ValueError("Invalid credentials")
        
        user_id = user['user_id']
        token = self._generate_jwt(user_id)
        
        await self.token_storage.save_token(token, str(user_id), ttl_seconds=JWT_EXPIRES_HOURS * 3600)

        return token, user_id

    async def logout(self, token: str) -> None:
        """Удаляет токен из Redis (выход из системы)."""
        await self.token_storage.delete_token(token)

    # --- Вспомогательные методы ---
    
    def _hash_password(self, password: str) -> str:
        """Хеширует пароль с помощью bcrypt."""
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
        return hashed.decode('utf-8')
    
    def _check_password(self, password: str, hashed: str) -> bool:
        """Проверяет пароль на соответствие хешу."""
        return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))
    
    def _generate_jwt(self, user_id: str) -> str:
        """Генерирует JWT токен с user_id и временем истечения."""
        payload = {
            "sub": str(user_id),
            "exp":  datetime.now(timezone.utc) + timedelta(hours=JWT_EXPIRES_HOURS)
        }
        token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)
        return token

    @staticmethod
    def decode_jwt(token: str) -> str:
        """
        Декодирует JWT и возвращает user_id.
        Выбрасывает исключение при неверной подписи или просрочке.
        """
        try:
            payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
            return payload["sub"]
        except jwt.InvalidTokenError as e:
            raise ValueError("Invalid or expired token") from e