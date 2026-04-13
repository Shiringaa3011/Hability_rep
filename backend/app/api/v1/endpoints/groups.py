from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.infrastructure.database.models import (
    EarnedGroupAchievementModel,
    GroupAchievementModel,
    GroupInviteModel,
    GroupMemberModel,
    GroupModel,
    HabitCompletionModel,
    NotificationModel,
    UserModel,
)
from app.schemas.mobile import (
    GroupCreateRequest,
    GroupDetailResponse,
    GroupInviteCreateRequest,
    GroupInviteDecisionRequest,
    GroupInviteResponse,
    GroupMemberResponse,
    GroupResponse,
)

router = APIRouter()


@router.get("/user/{user_id}", response_model=list[GroupResponse])
async def get_user_groups(user_id: UUID, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(GroupModel)
        .join(GroupMemberModel, GroupMemberModel.group_id == GroupModel.id)
        .where(GroupMemberModel.user_id == user_id, GroupModel.is_active == True)  # noqa: E712
        .order_by(GroupModel.created_at.desc())
    )
    rows = await db.execute(stmt)
    return [
        GroupResponse(
            id=g.id,
            name=g.name,
            description=g.description,
            created_by=g.created_by,
            created_at=g.created_at,
            is_active=g.is_active,
        )
        for g in rows.scalars().all()
    ]


@router.post("", response_model=GroupResponse, status_code=status.HTTP_201_CREATED)
async def create_group(request: GroupCreateRequest, db: AsyncSession = Depends(get_db)):
    user = await db.get(UserModel, request.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    group = GroupModel(
        name=request.name.strip(),
        description=request.description.strip() if request.description else None,
        created_by=request.user_id,
    )
    db.add(group)
    await db.flush()

    member = GroupMemberModel(group_id=group.id, user_id=request.user_id)
    db.add(member)
    db.add(
        NotificationModel(
            user_id=request.user_id,
            title="Группа создана",
            body=f"Вы создали группу «{group.name}».",
            kind="group_created",
            group_id=group.id,
        )
    )
    await db.flush()
    await db.refresh(group)
    return GroupResponse(
        id=group.id,
        name=group.name,
        description=group.description,
        created_by=group.created_by,
        created_at=group.created_at,
        is_active=group.is_active,
    )


@router.get("/{group_id}", response_model=GroupDetailResponse)
async def get_group_detail(
    group_id: UUID,
    current_user_id: UUID = Query(...),
    db: AsyncSession = Depends(get_db),
):
    group = await db.get(GroupModel, group_id)
    if not group or not group.is_active:
        raise HTTPException(status_code=404, detail="Group not found")

    membership_stmt = select(GroupMemberModel).where(
        GroupMemberModel.group_id == group_id,
        GroupMemberModel.user_id == current_user_id,
    )
    membership = (await db.execute(membership_stmt)).scalar_one_or_none()
    if membership is None:
        raise HTTPException(status_code=403, detail="Not a group member")

    members_stmt = (
        select(GroupMemberModel, UserModel.username)
        .join(UserModel, UserModel.id == GroupMemberModel.user_id)
        .where(GroupMemberModel.group_id == group_id)
    )
    rows = (await db.execute(members_stmt)).all()
    members: list[GroupMemberResponse] = []
    for member, username in rows:
        points_stmt = select(func.coalesce(func.sum(HabitCompletionModel.points_earned), 0)).where(
            HabitCompletionModel.user_id == member.user_id
        )
        reactions_stmt = select(func.count(NotificationModel.id)).where(
            NotificationModel.user_id == member.user_id,
            NotificationModel.kind == "leader_reaction",
            NotificationModel.group_id == group_id,
        )
        points = int((await db.execute(points_stmt)).scalar_one() or 0)
        reactions = int((await db.execute(reactions_stmt)).scalar_one() or 0)
        members.append(
            GroupMemberResponse(
                id=member.id,
                user_id=member.user_id,
                username=username,
                points=points,
                reactions=reactions,
                joined_at=member.joined_at,
            )
        )
    members.sort(key=lambda m: m.points, reverse=True)

    ach_stmt = (
        select(GroupAchievementModel.name)
        .join(
            EarnedGroupAchievementModel,
            EarnedGroupAchievementModel.achievement_id == GroupAchievementModel.id,
        )
        .where(EarnedGroupAchievementModel.group_id == group_id)
        .order_by(EarnedGroupAchievementModel.earned_at.desc())
        .limit(10)
    )
    ach_rows = await db.execute(ach_stmt)
    achievement_names = [name for name in ach_rows.scalars().all()]

    return GroupDetailResponse(
        group=GroupResponse(
            id=group.id,
            name=group.name,
            description=group.description,
            created_by=group.created_by,
            created_at=group.created_at,
            is_active=group.is_active,
        ),
        members=members,
        group_achievements=achievement_names,
    )


@router.post("/{group_id}/leave", status_code=status.HTTP_204_NO_CONTENT)
async def leave_group(
    group_id: UUID,
    user_id: UUID = Query(...),
    db: AsyncSession = Depends(get_db),
):
    group = await db.get(GroupModel, group_id)
    if not group or not group.is_active:
        raise HTTPException(status_code=404, detail="Group not found")
    if group.created_by == user_id:
        raise HTTPException(status_code=400, detail="Group creator cannot leave")

    member_stmt = select(GroupMemberModel).where(
        GroupMemberModel.group_id == group_id,
        GroupMemberModel.user_id == user_id,
    )
    member = (await db.execute(member_stmt)).scalar_one_or_none()
    if member is None:
        raise HTTPException(status_code=404, detail="Member not found")
    await db.delete(member)


@router.delete("/{group_id}/members/{member_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_member(group_id: UUID, member_id: UUID, db: AsyncSession = Depends(get_db)):
    group = await db.get(GroupModel, group_id)
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    member = await db.get(GroupMemberModel, member_id)
    if member is None or member.group_id != group_id:
        raise HTTPException(status_code=404, detail="Member not found")
    if member.user_id == group.created_by:
        raise HTTPException(status_code=400, detail="Cannot remove creator")

    await db.delete(member)


@router.post("/{group_id}/reaction", status_code=status.HTTP_204_NO_CONTENT)
async def react_to_leader(
    group_id: UUID,
    from_user_id: UUID = Query(...),
    to_user_id: UUID = Query(...),
    db: AsyncSession = Depends(get_db),
):
    leader_note = NotificationModel(
        user_id=to_user_id,
        title="Поддержка лидера",
        body="Участник группы отправил вам реакцию за лидерство.",
        kind="leader_reaction",
        group_id=group_id,
    )
    db.add(leader_note)


@router.post("/invites", response_model=GroupInviteResponse, status_code=status.HTTP_201_CREATED)
async def create_invite(
    request: GroupInviteCreateRequest,
    db: AsyncSession = Depends(get_db),
):
    group = await db.get(GroupModel, request.group_id)
    if not group or not group.is_active:
        raise HTTPException(status_code=404, detail="Group not found")
    if group.created_by != request.from_user_id:
        raise HTTPException(status_code=403, detail="Only group creator can invite")

    user_stmt = select(UserModel).where(UserModel.username == request.to_username)
    invited_user = (await db.execute(user_stmt)).scalar_one_or_none()
    if invited_user is None:
        raise HTTPException(status_code=404, detail="Invited user not found")

    member_stmt = select(GroupMemberModel).where(
        GroupMemberModel.group_id == request.group_id,
        GroupMemberModel.user_id == invited_user.id,
    )
    if (await db.execute(member_stmt)).scalar_one_or_none() is not None:
        raise HTTPException(status_code=400, detail="User already in group")

    pending_stmt = select(GroupInviteModel).where(
        GroupInviteModel.group_id == request.group_id,
        GroupInviteModel.to_user_id == invited_user.id,
        GroupInviteModel.status == "pending",
    )
    if (await db.execute(pending_stmt)).scalar_one_or_none() is not None:
        raise HTTPException(status_code=400, detail="Pending invite already exists")

    invite = GroupInviteModel(
        group_id=request.group_id,
        from_user_id=request.from_user_id,
        to_user_id=invited_user.id,
        status="pending",
    )
    db.add(invite)
    db.add(
        NotificationModel(
            user_id=invited_user.id,
            title="Приглашение в группу",
            body=f"Вас пригласили в группу «{group.name}».",
            kind="group_invite",
            group_id=group.id,
        )
    )
    await db.flush()
    inviter = await db.get(UserModel, request.from_user_id)
    return GroupInviteResponse(
        id=invite.id,
        group_id=invite.group_id,
        group_name=group.name,
        from_user_id=invite.from_user_id,
        from_username=inviter.username if inviter else "",
        to_user_id=invite.to_user_id,
        status=invite.status,
        created_at=invite.created_at,
    )


@router.get("/invites/pending/{user_id}", response_model=list[GroupInviteResponse])
async def get_pending_invites(user_id: UUID, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(GroupInviteModel, GroupModel.name, UserModel.username)
        .join(GroupModel, GroupModel.id == GroupInviteModel.group_id)
        .join(UserModel, UserModel.id == GroupInviteModel.from_user_id)
        .where(GroupInviteModel.to_user_id == user_id, GroupInviteModel.status == "pending")
        .order_by(GroupInviteModel.created_at.desc())
    )
    rows = (await db.execute(stmt)).all()
    return [
        GroupInviteResponse(
            id=invite.id,
            group_id=invite.group_id,
            group_name=group_name,
            from_user_id=invite.from_user_id,
            from_username=from_username,
            to_user_id=invite.to_user_id,
            status=invite.status,
            created_at=invite.created_at,
        )
        for invite, group_name, from_username in rows
    ]


@router.post("/invites/{invite_id}/decision", status_code=status.HTTP_204_NO_CONTENT)
async def decide_invite(
    invite_id: UUID,
    request: GroupInviteDecisionRequest,
    db: AsyncSession = Depends(get_db),
):
    invite = await db.get(GroupInviteModel, invite_id)
    if invite is None:
        raise HTTPException(status_code=404, detail="Invite not found")
    if invite.to_user_id != request.user_id:
        raise HTTPException(status_code=403, detail="Invite does not belong to this user")
    if invite.status != "pending":
        raise HTTPException(status_code=400, detail="Invite already processed")

    group = await db.get(GroupModel, invite.group_id)
    if group is None or not group.is_active:
        raise HTTPException(status_code=404, detail="Group not found")

    if request.accept:
        existing_member = (
            await db.execute(
                select(GroupMemberModel).where(
                    GroupMemberModel.group_id == invite.group_id,
                    GroupMemberModel.user_id == request.user_id,
                )
            )
        ).scalar_one_or_none()
        if existing_member is None:
            db.add(
                GroupMemberModel(
                    group_id=invite.group_id,
                    user_id=request.user_id,
                )
            )
        invite.status = "accepted"
        db.add(
            NotificationModel(
                user_id=invite.from_user_id,
                title="Приглашение принято",
                body="Пользователь принял ваше приглашение в группу.",
                kind="invite_accepted",
                group_id=invite.group_id,
            )
        )
    else:
        invite.status = "declined"
        db.add(
            NotificationModel(
                user_id=invite.from_user_id,
                title="Приглашение отклонено",
                body="Пользователь отклонил приглашение в группу.",
                kind="invite_declined",
                group_id=invite.group_id,
            )
        )
    await db.flush()
