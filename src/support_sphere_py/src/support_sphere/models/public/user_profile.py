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

