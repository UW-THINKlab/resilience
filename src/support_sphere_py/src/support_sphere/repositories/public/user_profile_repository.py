from typing import Optional

from support_sphere.models.public import UserProfile

from sqlmodel import Session, select
from sqlalchemy.orm import joinedload

from support_sphere.repositories.base_repository import BaseRepository


class UserProfileRepository(BaseRepository):
    """
    Repository class for managing CRUD operations and queries related to the `UserProfile` model.

    Methods
    -------
    select_all() -> list[UserProfile]:
        Retrieves all `UserProfile` records from the database.

    find_by_user_id(user_id: str, fetch_user: bool = False, fetch_person_details: bool = False) -> Optional[UserProfile]:
        Finds a `UserProfile` by its user ID with optional eager loading of related `User` and `People`.

    find_by_username(username: str, fetch_user: bool = False, fetch_person_details: bool = False) -> Optional[UserProfile]:
        Finds a `UserProfile` by its username with optional eager loading of related `User` and `People`.

    Notes
    -----
    - The `fetch_user` flag is used to load the associated `User` model.
    - The `fetch_person_details` flag is used to load the associated `People` model.
    - The repository relies on `Session` from SQLModel to execute database operations.
    """
    @classmethod
    def select_all(cls) -> list[UserProfile]:
        """
        Retrieves all `UserProfile` records from the database.

        Returns
        -------
        list[UserProfile]
            A list of all `UserProfile` records.
        """
        return super().select_all(UserProfile)

    @staticmethod
    def find_by_user_id(user_id: str,
                        fetch_user: bool = False, fetch_person_details: bool = False) -> Optional[UserProfile]:
        """
        Finds a `UserProfile` by its user ID with optional eager loading of related `User` and `People`.

        Parameters
        ----------
        user_id : str
            The ID of the user to search for.
        fetch_user : bool, optional
            Whether to fetch the related `User` entity (default is False).
        fetch_person_details : bool, optional
            Whether to fetch the related `People` entity (default is False).

        Returns
        -------
        Optional[UserProfile]
            The `UserProfile` object if found, otherwise None.
        """
        with Session(UserProfileRepository.repository_engine) as session:
            statement = UserProfileRepository._build_search_query(fetch_user, fetch_person_details)
            statement = statement.where(UserProfile.id == user_id)
            user_profile = session.exec(statement).one_or_none()

            return user_profile

    @staticmethod
    def find_by_username(username: str,
                         fetch_user: bool = False, fetch_person_details: bool = False) -> Optional[UserProfile]:
        """
        Finds a `UserProfile` by its username with optional eager loading of related `User` and `People`.

        Parameters
        ----------
        username : str
            The username to search for.
        fetch_user : bool, optional
            Whether to fetch the related `User` entity (default is False).
        fetch_person_details : bool, optional
            Whether to fetch the related `People` entity (default is False).

        Returns
        -------
        Optional[UserProfile]
            The `UserProfile` object if found, otherwise None.
        """
        with Session(UserProfileRepository.repository_engine) as session:
            statement = UserProfileRepository._build_search_query(fetch_user, fetch_person_details)
            statement = statement.where(UserProfile.username == username)

            # Execute the query
            user_profile = session.exec(statement).one_or_none()

            return user_profile

    @staticmethod
    def _build_search_query(fetch_user: bool = False, fetch_person_details: bool = False):
        """
        Builds a SQL query to search for `UserProfile` records with optional eager loading of related entities.

        Parameters
        ----------
        fetch_user : bool, optional
            Whether to eagerly load the related `User` entity (default is False).
        fetch_person_details : bool, optional
            Whether to eagerly load the related `People` entity (default is False).

        Returns
        -------
        sqlalchemy.sql.Select
            A query object ready to be executed for searching `UserProfile` records.
        """
        statement = select(UserProfile)
        # Add eager loading options based on flags
        statement = statement.options(joinedload(UserProfile.user)) if fetch_user else statement
        statement = statement.options(joinedload(UserProfile.person_details)) if fetch_person_details else statement

        return statement
