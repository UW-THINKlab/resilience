import uuid
from typing import Optional

from sqlmodel import Session, select

from support_sphere.models.public import UserCaptainCluster, UserRole
from support_sphere.models.enums import AppRoles
from support_sphere.repositories.base_repository import BaseRepository


class UserCaptainClusterRepository(BaseRepository):
    """
    Repository class for managing CRUD operations related to the `UserCaptainCluster` model.

    Methods
    -------
    find_by_cluster_id(cluster_id: uuid.UUID) -> list[UserCaptainCluster]:
        Retrieves all `UserCaptainCluster` records for a given cluster.

    find_by_user_role_id_and_cluster_id(user_role_id: uuid.UUID, cluster_id: uuid.UUID) -> Optional[UserCaptainCluster]:
        Finds a `UserCaptainCluster` entry by user_role_id and cluster_id.

    grant_captain(user_profile_id: uuid.UUID, cluster_id: uuid.UUID) -> UserCaptainCluster:
        Grants the cluster captain role to a user for a given cluster.
        Upserts the user's role to SUBCOM_AGENT and creates the UserCaptainCluster entry.

    revoke_captain(user_profile_id: uuid.UUID, cluster_id: uuid.UUID) -> bool:
        Revokes the cluster captain role from a user for a given cluster.
        Deletes the UserCaptainCluster entry and reverts the user role to USER if no other captaincies remain.
    """

    @classmethod
    def select_all(cls) -> list[UserCaptainCluster]:
        """
        Retrieves all `UserCaptainCluster` records from the database.

        Returns
        -------
        list[UserCaptainCluster]
            A list of all `UserCaptainCluster` records.
        """
        return super().select_all(UserCaptainCluster)

    @staticmethod
    def find_by_cluster_id(cluster_id: uuid.UUID) -> list[UserCaptainCluster]:
        """
        Retrieves all `UserCaptainCluster` records for a given cluster.

        Parameters
        ----------
        cluster_id : uuid.UUID
            The ID of the cluster to search for.

        Returns
        -------
        list[UserCaptainCluster]
            A list of `UserCaptainCluster` records for the cluster.
        """
        with Session(UserCaptainClusterRepository.repository_engine) as session:
            statement = select(UserCaptainCluster).where(UserCaptainCluster.cluster_id == cluster_id)
            return session.exec(statement).all()

    @staticmethod
    def find_by_user_role_id_and_cluster_id(
        user_role_id: uuid.UUID, cluster_id: uuid.UUID
    ) -> Optional[UserCaptainCluster]:
        """
        Finds a `UserCaptainCluster` entry by user_role_id and cluster_id.

        Parameters
        ----------
        user_role_id : uuid.UUID
            The ID of the user role.
        cluster_id : uuid.UUID
            The ID of the cluster.

        Returns
        -------
        Optional[UserCaptainCluster]
            The `UserCaptainCluster` object if found, otherwise None.
        """
        with Session(UserCaptainClusterRepository.repository_engine) as session:
            statement = (
                select(UserCaptainCluster)
                .where(UserCaptainCluster.user_role_id == user_role_id)
                .where(UserCaptainCluster.cluster_id == cluster_id)
            )
            return session.exec(statement).one_or_none()

    @staticmethod
    def grant_captain(user_profile_id: uuid.UUID, cluster_id: uuid.UUID) -> UserCaptainCluster:
        """
        Grants the cluster captain role to a user for a given cluster.

        This method:
        1. Upserts the user's `UserRole` to `SUBCOM_AGENT`.
        2. Creates a `UserCaptainCluster` entry if one does not already exist.

        Parameters
        ----------
        user_profile_id : uuid.UUID
            The user profile ID to grant the captain role to.
        cluster_id : uuid.UUID
            The cluster ID to associate the captain with.

        Returns
        -------
        UserCaptainCluster
            The created or existing `UserCaptainCluster` entry.
        """
        with Session(UserCaptainClusterRepository.repository_engine) as session:
            # Find or create the UserRole for this user profile
            user_role = session.exec(
                select(UserRole).where(UserRole.user_profile_id == user_profile_id)
            ).one_or_none()

            if user_role is None:
                user_role = UserRole(
                    user_profile_id=user_profile_id,
                    role=AppRoles.SUBCOM_AGENT,
                )
                session.add(user_role)
                session.flush()
            elif user_role.role != AppRoles.SUBCOM_AGENT:
                user_role.role = AppRoles.SUBCOM_AGENT
                session.add(user_role)
                session.flush()

            # Check if the captain entry already exists
            existing = session.exec(
                select(UserCaptainCluster)
                .where(UserCaptainCluster.user_role_id == user_role.id)
                .where(UserCaptainCluster.cluster_id == cluster_id)
            ).one_or_none()

            if existing is not None:
                return existing

            # Create the UserCaptainCluster entry
            captain_cluster = UserCaptainCluster(
                cluster_id=cluster_id,
                user_role_id=user_role.id,
            )
            session.add(captain_cluster)
            session.commit()
            session.refresh(captain_cluster)
            return captain_cluster

    @staticmethod
    def revoke_captain(user_profile_id: uuid.UUID, cluster_id: uuid.UUID) -> bool:
        """
        Revokes the cluster captain role from a user for a given cluster.

        This method:
        1. Deletes the `UserCaptainCluster` entry for the user_role and cluster.
        2. If the user has no remaining captaincies, reverts their `UserRole` to `USER`.

        Parameters
        ----------
        user_profile_id : uuid.UUID
            The user profile ID to revoke the captain role from.
        cluster_id : uuid.UUID
            The cluster ID to disassociate the captain from.

        Returns
        -------
        bool
            True if the revocation was successful, False if the entry was not found.
        """
        with Session(UserCaptainClusterRepository.repository_engine) as session:
            # Find the UserRole for this user profile
            user_role = session.exec(
                select(UserRole).where(UserRole.user_profile_id == user_profile_id)
            ).one_or_none()

            if user_role is None:
                return False

            # Find the captain cluster entry
            captain_cluster = session.exec(
                select(UserCaptainCluster)
                .where(UserCaptainCluster.user_role_id == user_role.id)
                .where(UserCaptainCluster.cluster_id == cluster_id)
            ).one_or_none()

            if captain_cluster is None:
                return False

            # Delete the captain cluster entry
            session.delete(captain_cluster)
            session.flush()

            # Check if the user has any remaining captaincies
            remaining = session.exec(
                select(UserCaptainCluster).where(UserCaptainCluster.user_role_id == user_role.id)
            ).all()

            if not remaining:
                # Revert the user role to USER
                user_role.role = AppRoles.USER
                session.add(user_role)

            session.commit()
            return True
