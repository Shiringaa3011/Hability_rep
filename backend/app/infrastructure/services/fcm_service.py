import firebase_admin
from firebase_admin import credentials, messaging
from pathlib import Path

_initialized = False

def _init_firebase():
    global _initialized
    if not _initialized:
        cred_path = Path(__file__).parent.parent.parent / "core" / "firebase_credentials.json"
        cred = credentials.Certificate(str(cred_path))
        firebase_admin.initialize_app(cred)
        _initialized = True

async def send_push_notification(
    device_token: str,
    title: str,
    body: str,
) -> bool:
    """Отправить push-уведомление на устройство"""
    _init_firebase()
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            android=messaging.AndroidConfig(
                notification=messaging.AndroidNotification(
                    icon='ic_notification',
                    color='#418D50',
                ),
            ),
            token=device_token,
        )
        response = messaging.send(message)
        print(f"Push sent: {response}")
        return True
    except Exception as e:
        print(f"Push failed: {e}")
        return False