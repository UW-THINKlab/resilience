import uuid
from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field


class Group(BasePublicSchemaModel, table=True):

    """
    Represents a person to household record mapping in the 'public' schema under 'people_groups' table.

    Attributes
    ----------
    id : uuid.UUID
        The unique identifier for the group
    created_by_id : uuid.UUID
        The unique identifier for the person who created the group, which is a foreign key
        referencing the `people` table.
    name : str
        The name of the groups. REQUIRED
    description : str
        An optional description of the group
    """
    __tablename__ = "groups"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    created_by_id: uuid.UUID = Field(foreign_key="public.user_profiles.id")
    name: str = Field(nullable=False)
    description: str|None = Field(nullable=True)
