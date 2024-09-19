from typing import Type, TypeVar
from sqlmodel import Session, SQLModel, select
from support_sphere.repositories import engine

T = TypeVar("T", bound=SQLModel)


class BaseRepository:
    repository_engine = engine

    @classmethod
    def add(cls, entity: T) -> T:
        with Session(BaseRepository.repository_engine) as session:
            session.add(entity)
            session.commit()
            session.refresh(entity)
            return entity

    @classmethod
    def add_all(cls, entity_list: list[T]) -> None:
        with Session(BaseRepository.repository_engine) as session:
            session.add_all(entity_list)
            session.commit()

    @classmethod
    def select_all(cls, from_table: Type[T]) -> list[T]:
        with Session(BaseRepository.repository_engine) as session:
            statement = select(from_table)
            results = session.exec(statement)
            return results.all()
