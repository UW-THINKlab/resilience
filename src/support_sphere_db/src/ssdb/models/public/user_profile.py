import uuid
from sqlmodel import Field, Relationship
from ssdb.models.auth import User
from ssdb.models.base import BasePublicSchemaModel


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
    name : str
        The full name of the user.
    nickname : str, optional
        A nickname for the user, can be null.
    is_safe : bool
        Indicates whether the user is marked as safe, defaults to True.
    needs_help : bool
        Indicates whether the user is flagged as needing help, defaults to False.
    user : User
        A relationship to the `User` model (from the `auth.users` table), with back_populates set
        to "user_profile", establishing a one-to-one connection between UserProfile and User.
        This is NOT a column in the auth.users table.

    Notes
    -----
    - Relationship attributes like `user` are not stored in the table but allow interaction between
      models. https://sqlmodel.tiangolo.com/tutorial/relationship-attributes/define-relationships-attributes/#what-are-these-relationship-attributes

    """
    __tablename__ = "user_profiles"

    id: uuid.UUID = Field(primary_key=True, foreign_key="auth.users.id")
    username: str = Field(unique=True)
    name: str = Field()
    nickname: str = Field(nullable=True)
    is_safe: bool = Field(default=True)
    needs_help: bool = Field(default=False)

    user: User = Relationship(back_populates="user_profile")

