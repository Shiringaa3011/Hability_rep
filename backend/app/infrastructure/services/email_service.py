import smtplib
import random
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).parent.parent.parent.parent.parent / ".env"
load_dotenv(env_path)

SMTP_EMAIL = os.getenv("SMTP_EMAIL")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD")

async def send_verification_code(email: str) -> str:
    code = str(random.randint(100000, 999999))
    
    msg = MIMEMultipart()
    msg["Subject"] = "Habitly — код подтверждения"
    msg["From"] = f"Habitly <{SMTP_EMAIL}>"
    msg["To"] = email
    
    body = f"""Здравствуйте!
    
Ваш код подтверждения: {code}

Код действителен 10 минут.

Если вы не запрашивали код, просто проигнорируйте это письмо.

С уважением,
Команда Habitly"""
    
    msg.attach(MIMEText(body, "plain", "utf-8"))
    
    try:
        with smtplib.SMTP_SSL("smtp.yandex.ru", 465) as server:
            server.login(SMTP_EMAIL, SMTP_PASSWORD)
            server.send_message(msg)
        print(f"Code sent to {email}")
    except Exception as e:
        pass
        print(f"Failed to send email: {e}")
        print(f"Code for {email}: {code}")
    
    return code