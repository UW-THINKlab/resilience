import uuid
from typing import Optional

from sqlmodel import Field, Relationship
from support_sphere.models.auth import User
from support_sphere.models.base import BasePublicSchemaModel


class UserProfile(BasePublicSchemaModel, table=True):
    """
    Represents a user profile entity in the 'public' schema under the 'user_profiles' table.
    This table contains metadata about the user and has one-to-one mapping with auth.users table.

    Attributes
    ----------
    id : uuid.UUID
        The unique identifier for the user profile, which references the id from the `auth.users` table.
    username : str
        A unique username for the user profile.
    user : User
        A relationship to the `User` model (from the `auth.users` table), with back_populates set
        to "user_profile", establishing a one-to-one connection between UserProfile and User.
        This is NOT a column in the table but represents relationship only.
    user_role: Optional[UserRole]
        A `UserRole` objects associated with this user_profile. Represents a one-to-one relationship where
        each `user_profile` can have a single `UserRole` entity. The relationship is configured with `back_populates`
        to match the `user_profile` attribute in the `UserRole` model, and cascading delete is disabled.
    operational_events : list[OperationalEvent]
        A list of `OperationalEvent` objects related to this user profile. This establishes a one-to-many relationship
        where a user profile can have multiple operational events. Cascading delete is disabled.
    user_resources : list[UserResource]
        A list of `UserResource` objects associated with this user profile, allowing the user to manage resources.
        Cascading delete is disabled.
    user_checklists : list[Checklist]
        A list of `UserChecklist` objects associated with this user profile

    Notes
    -----
    - Relationship attributes like `user` are not stored in the table but allow interaction between
      models. https://sqlmodel.tiangolo.com/tutorial/relationship-attributes/define-relationships-attributes/#what-are-these-relationship-attributes

    """
    __tablename__ = "user_profiles"

    id: uuid.UUID = Field(primary_key=True, foreign_key="auth.users.id")
    username: str = Field(unique=True)

    user: User = Relationship(back_populates="user_profile")
    person_details: Optional["People"] = Relationship(back_populates="user_profile",
                                                      cascade_delete=False, sa_relationship_kwargs={"uselist": False})
    user_role: Optional["UserRole"] = Relationship(back_populates="user_profile", cascade_delete=False)
    operational_events: list["OperationalEvent"] = Relationship(back_populates="user_profile", cascade_delete=False)
    user_resources: list["UserResource"] = Relationship(back_populates="user_profile", cascade_delete=False)
    user_checklists: list["UserChecklist"] = Relationship(back_populates="user_profile", cascade_delete=False)
