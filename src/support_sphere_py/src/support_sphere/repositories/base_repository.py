from typing import Type, TypeVar
from sqlmodel import Session, SQLModel, select
from support_sphere import engine

T = TypeVar("T", bound=SQLModel)


class BaseRepository:
    repository_engine = engine

    @staticmethod
    def add(entity: T) -> None:
        with Session(BaseRepository.repository_engine) as session:
            session.add(entity)
            session.commit()

    @staticmethod
    def add_all( entity_list: list[T]) -> None:
        with Session(BaseRepository.repository_engine) as session:
            session.add_all(entity_list)
            session.commit()

    @staticmethod
    def select_all(from_table: Type[T]) -> list[T]:
        with Session(BaseRepository.repository_engine) as session:
            statement = select(from_table)
            results = session.exec(statement)
            return results.all()
