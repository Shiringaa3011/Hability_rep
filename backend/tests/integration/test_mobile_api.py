import pytest

from tests.fixtures.database_fixtures import test_user


@pytest.mark.asyncio
async def test_create_and_list_group(client, test_user):
    payload = {
        "user_id": str(test_user.id),
        "name": "QA Group",
        "description": "integration",
    }
    created = await client.post("/api/v1/groups", json=payload)
    assert created.status_code == 201
    group_id = created.json()["id"]

    listed = await client.get(f"/api/v1/groups/user/{test_user.id}")
    assert listed.status_code == 200
    assert any(g["id"] == group_id for g in listed.json())


@pytest.mark.asyncio
async def test_create_habit_and_day_list(client, test_user):
    payload = {
        "user_id": str(test_user.id),
        "title": "API Habit",
        "description": "desc",
        "frequency": "daily",
        "reminders_enabled": True,
    }
    created = await client.post("/api/v1/habits", json=payload)
    assert created.status_code == 201
    habit_id = created.json()["id"]

    day = "2026-05-02"
    listed = await client.get(f"/api/v1/habits/user/{test_user.id}/day?day={day}")
    assert listed.status_code == 200
    assert any(h["id"] == habit_id for h in listed.json()["habits"])

    toggle = await client.post(
        f"/api/v1/habits/{habit_id}/completion",
        json={"day": day, "completed": True},
    )
    assert toggle.status_code == 204


@pytest.mark.asyncio
async def test_notification_history_and_settings(client, test_user):
    sent = await client.post(
        "/api/v1/notifications/send",
        json={
            "user_id": str(test_user.id),
            "title": "Hello",
            "body": "World",
            "kind": "info",
        },
    )
    assert sent.status_code == 201

    history = await client.get(f"/api/v1/notifications/history/{test_user.id}")
    assert history.status_code == 200
    items = history.json()["items"]
    assert len(items) >= 1

    settings = await client.put(
        "/api/v1/notifications/settings",
        json={
            "user_id": str(test_user.id),
            "allow_notifications": True,
            "sound_enabled": False,
            "vibration_enabled": True,
        },
    )
    assert settings.status_code == 200
    assert settings.json()["sound_enabled"] is False


@pytest.mark.asyncio
async def test_group_invite_flow_and_register(client, test_user):
    reg = await client.post(
        "/api/v1/users/register",
        json={"email": "invitee@example.com", "password": "secret123"},
    )
    assert reg.status_code == 201
    invitee_id = reg.json()["user_id"]
    invitee_username = reg.json()["username"]

    group = await client.post(
        "/api/v1/groups",
        json={
            "user_id": str(test_user.id),
            "name": "Invite Group",
            "description": "flow",
        },
    )
    assert group.status_code == 201
    group_id = group.json()["id"]

    invite = await client.post(
        "/api/v1/groups/invites",
        json={
            "group_id": group_id,
            "from_user_id": str(test_user.id),
            "to_username": invitee_username,
        },
    )
    assert invite.status_code == 201
    invite_id = invite.json()["id"]

    pending = await client.get(f"/api/v1/groups/invites/pending/{invitee_id}")
    assert pending.status_code == 200
    assert any(i["id"] == invite_id for i in pending.json())

    accept = await client.post(
        f"/api/v1/groups/invites/{invite_id}/decision",
        json={"user_id": invitee_id, "accept": True},
    )
    assert accept.status_code == 204
