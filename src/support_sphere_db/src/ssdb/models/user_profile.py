import uuid
from sqlmodel import Field, Relationship
from ssdb.models import User
from ssdb.models.abstract_public_schema_model import AbstractPublicSchemaModel


class UserProfile(AbstractPublicSchemaModel, table=True):
    __tablename__ = "user_profiles"

    id: uuid.UUID = Field(primary_key=True, foreign_key="auth.users.id")
    username: str = Field(unique=True)
    name: str = Field()
    nickname: str = Field(nullable=True)
    is_safe: bool = Field(default=True)
    needs_help: bool = Field(default=False)

    user: User = Relationship(back_populates="user_profile")

