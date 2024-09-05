import logging

from support_sphere.models.auth import User
from support_sphere.services import user_service
from fastapi import APIRouter, HTTPException

router = APIRouter(
    prefix="/users",
    tags=["users"],
    responses={404: {"description": "Not found"}},
)

logger = logging.getLogger(__name__)


@router.get("/", response_model=list[User])
def get_users():
    try:
        users: list[User] = user_service.get_all_users()
    except Exception as ex:
        logger.error(f"Exception Occurred: {ex}")
        raise HTTPException(status_code=502, detail="Some error occurred")
    return users


@router.get("/{user_id}", response_model= User)
def get_user_by_user_id(user_id: str):
    try:
        user: User = user_service.get_user_by_id(user_id)
    except Exception as ex:
        logger.error(f"Exception Occurred: {ex}")
        raise HTTPException(status_code=502, detail="Some error occurred")

    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
