from ssdb.models.auth import User

from sqlmodel import Session, select

from ssdb.repository.base_repository import BaseRepository


class UserRepository(BaseRepository):

    def select_all(self) -> list[User]:
        return super().select_all(User)

    def find_by_user_id(self, user_id: str) -> list[User]:
        with Session(self.engine) as session:
            statement = select(User).where(User.id == user_id)
            results = session.exec(statement)
            return results.one()
