from ssdb.models.public import UserProfile

from sqlmodel import Session, select

from ssdb.repository.base_repository import BaseRepository


class UserProfileRepository(BaseRepository):

    def select_all(self) -> list[UserProfile]:
        return super().select_all(UserProfile)

    def find_by_user_id(self, user_id: str) -> list[UserProfile]:
        with Session(self.engine) as session:
            statement = select(UserProfile).where(UserProfile.id == user_id)
            user_profile = session.exec(statement)
            return user_profile.one()

    def find_by_username(self, username: str) -> list[UserProfile]:
        with Session(self.engine) as session:
            statement = select(UserProfile).where(UserProfile.username == username)
            user_profile = session.exec(statement)
            return user_profile.one()
