from typing import Optional

from sqlmodel import Session, select
from sqlalchemy.orm import joinedload

from support_sphere.models.public import People
from support_sphere.repositories.base_repository import BaseRepository


class PeopleRepository(BaseRepository):
    """
    Repository class for managing CRUD operations and queries related to the `People` model.

    Methods
    -------
    select_all() -> list[People]:
        Retrieves all `People` records from the database.

    find_by_id(id: str, fetch_user_profile: bool = False) -> Optional[People]:
        Finds a `People` record by its ID with optional eager loading of the related `UserProfile`.

    find_by_user_id(user_id: str, fetch_user_profile: bool = False) -> Optional[People]:
        Finds a `People` record by the associated `user_id` with optional eager loading of the related `UserProfile`.

    find_by_is_safe(is_safe: bool, fetch_user_profile: bool = False) -> list[People]:
        Finds all `People` records with a specific `is_safe` status with optional eager loading of the related `UserProfile`.

    Notes
    -----
    - The `fetch_user_profile` flag is used to load the associated `UserProfile` model.
    - The repository relies on `Session` from SQLModel to execute database operations.
    """

    @staticmethod
    def select_all() -> list[People]:
        """
        Retrieves all `People` records from the database.

        Returns
        -------
        list[People]
            A list of all `People` records.
        """
        return super().select_all(People)

    @staticmethod
    def find_by_id(id: str, fetch_user_profile: bool = False) -> Optional[People]:
        """
        Finds a `People` record by its ID with optional eager loading of the related `UserProfile`.

        Parameters
        ----------
        id : str
            The ID of the `People` record to search for.
        fetch_user_profile : bool, optional
            Whether to fetch the related `UserProfile` entity (default is False).

        Returns
        -------
        Optional[People]
            The `People` object if found, otherwise None.
        """
        with Session(PeopleRepository.repository_engine) as session:
            statement = PeopleRepository._build_search_query(fetch_user_profile)
            statement = statement.where(People.id == id)
            user_profile = session.exec(statement).one_or_none()
            return user_profile

    @staticmethod
    def find_by_user_id(user_id: str, fetch_user_profile: bool = False) -> Optional[People]:
        """
        Finds a `People` record by the associated `user_id` with optional eager loading of the related `UserProfile`.

        Parameters
        ----------
        user_id : str
            The `user_id` to search for in the `People` model.
        fetch_user_profile : bool, optional
            Whether to fetch the related `UserProfile` entity (default is False).

        Returns
        -------
        Optional[People]
            The `People` object if found, otherwise None.
        """
        with Session(PeopleRepository.repository_engine) as session:
            statement = PeopleRepository._build_search_query(fetch_user_profile)
            statement = statement.where(People.user_id == user_id)
            user_profile = session.exec(statement).one_or_none()
            return user_profile

    @staticmethod
    def find_by_is_safe(is_safe: bool, fetch_user_profile: bool = False) -> list[People]:
        """
        Finds all `People` records with a specific `is_safe` status with optional eager loading of the related `UserProfile`.

        Parameters
        ----------
        is_safe : bool
            The safety status to search for in the `People` model.
        fetch_user_profile : bool, optional
            Whether to fetch the related `UserProfile` entity (default is False).

        Returns
        -------
        list[People]
            A list of `People` records matching the `is_safe` status.
        """
        with Session(PeopleRepository.repository_engine) as session:
            statement = PeopleRepository._build_search_query(fetch_user_profile)
            statement = statement.where(People.is_safe == is_safe)
            people = session.exec(statement)
            return people.all()

    @staticmethod
    def _build_search_query(fetch_user_profile: bool = False):
        """
        Builds a SQL query to search for `People` records with optional eager loading of the `UserProfile`.

        Parameters
        ----------
        fetch_user_profile : bool, optional
            Whether to eagerly load the related `UserProfile` entity (default is False).

        Returns
        -------
        sqlalchemy.sql.Select
            A query object ready to be executed for searching `People` records.
        """
        statement = select(People)
        # Add eager loading options based on flags
        statement = statement.options(joinedload(People.user_profile)) if fetch_user_profile else statement

        return statement
