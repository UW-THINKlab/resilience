import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship

from support_sphere.models.enums import AppRoles
from sqlalchemy import Enum


class UserRole(BasePublicSchemaModel, table=True):
    """
    Represents the roles assigned to user profiles in the 'public' schema under the 'user_roles' table.

    Attributes
    ----------
    id : uuid.UUID
        The unique identifier for the user role, generated automatically using UUID.
    user_profile_id : uuid.UUID
        The unique identifier of the associated user profile from the 'public.user_profiles' table.
        This is a foreign key and is unique for each role.
    role : AppRoles
        The role assigned to the user profile, represented as an enum (AppRoles). This field cannot be null.
    user_captains : list[UserCaptainCluster]
        A list of `UserCaptainCluster` entries associated with this user_role, representing a one-to-many relationship
        where a  single `UserRole` can be captain of multiple clusters. The relationship is configured with
        `back_populates` to match the `user_role` attribute in the `UserCaptainCluster` model. Cascade delete disabled.
    user_profile : Optional[UserProfile]
        The associated `UserProfile` object for this role. It represents a one-to-one relationship where
        each `UserRole` is linked to a single `UserProfile`. The relationship uses `back_populates` to match
        the `user_role` attribute in the `UserProfile` model. Cascading delete is disabled.

    Notes
    -----
    - The `role` field uses the SQLAlchemy `Enum` type to store role data, mapped from the `AppRoles` enum.
    - The relationship between `UserRole` and `UserProfile` is designed as a one-to-one relationship.
    """
    __tablename__ = "user_roles"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_profile_id: uuid.UUID | None = Field(foreign_key="public.user_profiles.id", nullable=False, unique=True)
    role: AppRoles = Field(sa_type=Enum(AppRoles, name="app_roles"), nullable=False)
    user_captains: list["UserCaptainCluster"] = Relationship(back_populates="user_role", cascade_delete=False)

    user_profile: Optional["UserProfile"] = Relationship(
        back_populates="user_role", cascade_delete=False,
    )
