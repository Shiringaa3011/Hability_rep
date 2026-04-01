from typing import List, Dict, Any
from app.domain.repositories.repositories_group import GroupRepository, GroupInviteRepository
from app.domain.repositories.repositories import UserRepository
import os

class GroupService:
    def __init__(self, group_repo: GroupRepository, invite_repo: GroupInviteRepository, user_repo: UserRepository):
        self.group_repo = group_repo
        self.invite_repo = invite_repo
        self.user_repo = user_repo
        self.max_members = int(os.getenv("GROUP_MAX_MEMBERS", "10"))

    async def create_group(self, admin_user_id: str, name: str) -> str:
        group_id = await self.group_repo.create_group(name, admin_user_id, self.max_members)
        await self.group_repo.add_member(group_id, admin_user_id)
        return group_id

    async def invite_user(self, group_id: str, from_user_id: str, to_username: str):
        group = await self.group_repo.get_group_by_id(group_id)
        if not group:
            raise ValueError("Group not found")
        if str(group['admin_user_id']) != from_user_id:
            raise PermissionError("Only admin can invite users")
        user = await self.user_repo.get_user_by_username(to_username)
        if not user:
            raise ValueError("User not found")
        to_user_id = str(user['user_id'])
        members = await self.group_repo.get_members(group_id)
        if any(str(m['user_id']) == to_user_id for m in members):
            raise ValueError("User already in group")
        count = await self.group_repo.get_member_count(group_id)
        if count >= group['max_members']:
            raise ValueError("Group is full")
        existing = await self.invite_repo.get_pending_invite(group_id, to_user_id, 'invite')
        if existing:
            raise ValueError("Invite already pending")
        await self.invite_repo.create_invite(group_id, from_user_id, to_user_id, 'invite')

    async def accept_invite(self, invite_id: str, user_id: str):
        invite = await self.invite_repo.get_invite_by_id(invite_id)
        if not invite or str(invite['to_user_id']) != user_id:
            raise ValueError("Invalid invite")
        if invite['status'] != 'pending':
            raise ValueError("Invite already processed")
        group = await self.group_repo.get_group_by_id(invite['group_id'])
        count = await self.group_repo.get_member_count(invite['group_id'])
        if count >= group['max_members']:
            raise ValueError("Group is full")
        await self.group_repo.add_member(invite['group_id'], user_id)
        await self.invite_repo.update_status(invite_id, 'accepted')

    async def decline_invite(self, invite_id: str, user_id: str):
        invite = await self.invite_repo.get_invite_by_id(invite_id)
        if not invite or str(invite['to_user_id']) != user_id:
            raise ValueError("Invalid invite")
        if invite['status'] != 'pending':
            raise ValueError("Invite already processed")
        await self.invite_repo.update_status(invite_id, 'declined')

    async def request_join(self, group_id: str, user_id: str):
        group = await self.group_repo.get_group_by_id(group_id)
        if not group:
            raise ValueError("Group not found")
        members = await self.group_repo.get_members(group_id)
        if any(str(m['user_id']) == user_id for m in members):
            raise ValueError("Already a member")
        count = await self.group_repo.get_member_count(group_id)
        if count >= group['max_members']:
            raise ValueError("Group is full")
        existing = await self.invite_repo.get_pending_invite(group_id, user_id, 'request')
        if existing:
            raise ValueError("Request already pending")
        await self.invite_repo.create_invite(group_id, user_id, str(group['admin_user_id']), 'request')

    async def approve_join_request(self, invite_id: str, admin_user_id: str):
        invite = await self.invite_repo.get_invite_by_id(invite_id)
        if not invite or invite['type'] != 'request':
            raise ValueError("Invalid request")
        group = await self.group_repo.get_group_by_id(invite['group_id'])
        if str(group['admin_user_id']) != admin_user_id:
            raise PermissionError("Only admin can approve requests")
        if invite['status'] != 'pending':
            raise ValueError("Request already processed")
        count = await self.group_repo.get_member_count(invite['group_id'])
        if count >= group['max_members']:
            raise ValueError("Group is full")
        await self.group_repo.add_member(invite['group_id'], invite['from_user_id'])
        await self.invite_repo.update_status(invite_id, 'accepted')

    async def leave_group(self, group_id: str, user_id: str):
        group = await self.group_repo.get_group_by_id(group_id)
        if not group:
            raise ValueError("Group not found")
        if str(group['admin_user_id']) == user_id:
            raise PermissionError("Admin cannot leave, only delete group")
        removed = await self.group_repo.remove_member(group_id, user_id)
        if not removed:
            raise ValueError("User not in group")
        from app.domain.repositories.repositories_group import GroupHabitCompletionRepository
        completion_repo = GroupHabitCompletionRepository(self.group_repo.pool)
        await completion_repo.delete_completions_for_user_in_group(group_id, user_id)

    async def delete_group(self, group_id: str, admin_user_id: str):
        group = await self.group_repo.get_group_by_id(group_id)
        if not group:
            raise ValueError("Group not found")
        if str(group['admin_user_id']) != admin_user_id:
            raise PermissionError("Only admin can delete group")
        await self.group_repo.delete_group(group_id)
        await self.invite_repo.delete_invites_for_group(group_id)

    async def get_group_info(self, group_id: str, user_id: str) -> Dict[str, Any]:
        group = await self.group_repo.get_group_by_id(group_id)
        if not group:
            raise ValueError("Group not found")
        members = await self.group_repo.get_members(group_id)
        if not any(str(m['user_id']) == user_id for m in members):
            raise PermissionError("Not a member")
        return {
            "group_id": str(group['group_id']),
            "name": group['name'],
            "admin_user_id": str(group['admin_user_id']),
            "max_members": group['max_members'],
            "created_at": group['created_at'].isoformat(),
            "members": [{"user_id": str(m['user_id']), "username": m['username']} for m in members]
        }

    async def list_user_groups(self, user_id: str) -> List[Dict[str, Any]]:
        return await self.group_repo.get_groups_by_user(user_id)

    async def get_pending_invites(self, user_id: str) -> List[Dict[str, Any]]:
        invites = await self.invite_repo.get_invites_for_user(user_id, 'pending')
        result = []
        for inv in invites:
            group = await self.group_repo.get_group_by_id(inv['group_id'])
            from_user = await self.user_repo.get_user_by_id(inv['from_user_id'])
            result.append({
                "invite_id": str(inv['invite_id']),
                "group_id": str(inv['group_id']),
                "group_name": group['name'] if group else "",
                "from_username": from_user['username'] if from_user else "",
                "type": inv['type'],
                "status": inv['status']
            })
        return result