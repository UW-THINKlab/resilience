import uuid
from sqlmodel import Field, SQLModel


class UserProfile(SQLModel, table=True):
    __tablename__ = "user_profiles"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str = Field()
    nickname: str = Field()
    username: str = Field()
    is_safe: bool = Field(default=True)
    needs_help: bool = Field(default=True)
