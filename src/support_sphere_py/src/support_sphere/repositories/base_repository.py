from typing import Type, TypeVar
from sqlmodel import Session, SQLModel, select
from support_sphere import engine

T = TypeVar("T", bound=SQLModel)


class BaseRepository:
    def __init__(self):
        self.engine = engine

    def add(self, entity: T) -> None:
        with Session(self.engine) as session:
            session.add(entity)
            session.commit()

    def add_all(self, entity_list: list[T]) -> None:
        with Session(self.engine) as session:
            session.add_all(entity_list)
            session.commit()

    def select_all(self, from_table: Type[T]) -> list[T]:
        with Session(self.engine) as session:
            statement = select(from_table)
            results = session.exec(statement)
            return results.all()
