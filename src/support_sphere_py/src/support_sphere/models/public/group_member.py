import uuid
from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field


class GroupMember(BasePublicSchemaModel, table=True):

    """
    Represents a person to group record mapping in the 'public' schema under 'people_groups' table.

    Attributes
    ----------
    people_id : uuid.UUID
        The unique identifier for the person in the people group, which is a foreign key referencing
        the `people` table.
    group_id : uuid.UUID
        The unique identifier for the household associated with the entry, which is a foreign key
        referencing the `households` table. This field is optional.
    """
    __tablename__ = "group_members"

    group_id: uuid.UUID|None = Field(primary_key=True, foreign_key="public.groups.id")
    people_id: uuid.UUID = Field(primary_key=True, foreign_key="public.user_profiles.id")
