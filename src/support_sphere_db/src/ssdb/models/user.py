from typing import Optional

import uuid
from sqlmodel import SQLModel, Field, Relationship


class User(SQLModel, table=True):
    """
    Represents a user record in the 'auth' schema under 'users' table. *

    Attributes
    ----------
    id : uuid.UUID
        The unique identifier for the user, generated automatically using UUID.
    email : str
        The email address of the user.
    phone : str
        The phone number of the user.
    user_profile : Optional[UserProfile]
        The associated user profile object, representing a one-to-one relationship
        between the User and the UserProfile. The relationship to the UserProfile model
        is established with back_populates set to "user" (attribute in UserProfile) and
        cascading delete set to False. Only a single profile (uselist=False) is allowed per user.
        Note: This is NOT a column in the auth.users table. **


    Notes
    -----
    - * The 'auth' schema is managed by supabase. It is not recommended to make changes to the existing auth.users table.
      Read here: https://github.com/orgs/supabase/discussions/3142
    - ** See more information about relationship attributes in SQLModel:
      https://sqlmodel.tiangolo.com/tutorial/relationship-attributes/define-relationships-attributes/#what-are-these-relationship-attributes
    """

    __tablename__ = "users"
    __table_args__ = {"schema": "auth"}

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    email: str = Field()
    phone: str = Field()

    user_profile: Optional["UserProfile"] = Relationship(
        back_populates="user", cascade_delete=False,
        sa_relationship_kwargs={"uselist": False}
    )