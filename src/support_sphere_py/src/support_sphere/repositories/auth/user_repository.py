from typing import Optional

from support_sphere.models.auth import User

from sqlmodel import Session, select
from sqlalchemy.orm import joinedload

from support_sphere.repositories.base_repository import BaseRepository


class UserRepository(BaseRepository):
    """
    Repository class for managing CRUD operations and queries related to the `User` model.

    Methods
    -------
    select_all() -> list[User]:
        Retrieves all `User` records from the database.

    find_by_user_id(user_id: str, fetch_user_profile: bool = False) -> Optional[User]:
        Finds a `User` by its user ID with optional eager loading of the related `UserProfile`.

    find_by_email(email: str, fetch_user_profile: bool = False) -> Optional[User]:
        Finds a `User` by its email with optional eager loading of the related `UserProfile`.

    Notes
    -----
    - The `fetch_user_profile` flag is used to load the associated `UserProfile` model.
    - The repository relies on `Session` from SQLModel to execute database operations.
    """

    @classmethod
    def select_all(cls) -> list[User]:
        """
        Retrieves all `User` records from the database.

        Returns
        -------
        list[User]
            A list of all `User` records.
        """
        return super().select_all(User)

    @staticmethod
    def find_by_user_id(user_id: str, fetch_user_profile: bool = False) -> Optional[User]:
        """
        Finds a `User` by its user ID with optional eager loading of the related `UserProfile`.

        Parameters
        ----------
        user_id : str
            The ID of the user to search for.
        fetch_user_profile : bool, optional
            Whether to fetch the related `UserProfile` entity (default is False).

        Returns
        -------
        Optional[User]
            The `User` object if found, otherwise None.
        """
        with Session(UserRepository.repository_engine) as session:
            statement = UserRepository._build_search_query(fetch_user_profile)
            statement = statement.where(User.id == user_id)
            user = session.exec(statement).one_or_none()
            return user

    @staticmethod
    def find_by_email(email: str, fetch_user_profile: bool = False) -> Optional[User]:
        """
        Finds a `User` by their email address with optional eager loading of the related `UserProfile`.

        Parameters
        ----------
        email : str
            The email address to search for.
        fetch_user_profile : bool, optional
            Whether to fetch the related `UserProfile` entity (default is False).

        Returns
        -------
        Optional[User]
            The `User` object if found, otherwise None.
        """
        with Session(UserRepository.repository_engine) as session:
            statement = UserRepository._build_search_query(fetch_user_profile)
            statement = statement.where(User.email == email)
            user = session.exec(statement).one_or_none()
            return user

    @staticmethod
    def _build_search_query(fetch_user_profile: bool = False):
        """
        Builds a SQL query to search for `User` records with optional eager loading of the `UserProfile`.

        Parameters
        ----------
        fetch_user_profile : bool, optional
            Whether to eagerly load the related `UserProfile` entity (default is False).

        Returns
        -------
        sqlalchemy.sql.Select
            A query object ready to be executed for searching `User` records.
        """
        statement = select(User)
        # Add eager loading options based on flags
        statement = statement.options(joinedload(User.user_profile)) if fetch_user_profile else statement

        return statement
