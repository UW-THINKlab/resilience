from typing import Optional

import uuid
from sqlmodel import SQLModel, Field, Relationship


class User(SQLModel, table=True):
    __tablename__ = "users"
    __table_args__ = {"schema": "auth"}

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    email: str = Field()
    phone: str = Field()

    user_profile: Optional["UserProfile"] = Relationship(
        back_populates="user", cascade_delete=False,
        sa_relationship_kwargs={"uselist": False}
    )