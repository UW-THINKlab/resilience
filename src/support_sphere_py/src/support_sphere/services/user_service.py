from support_sphere.models.auth import User
from support_sphere.repositories.auth import UserRepository


def get_user_by_id(user_id: str) -> User|None:
    user: User = UserRepository.find_by_user_id(user_id, fetch_user_profile=True)
    return user


def get_all_users() -> list[User]:
    users: list[User] = UserRepository.select_all()
    return users
