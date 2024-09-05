import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class PeopleGroup(BasePublicSchemaModel, table=True):

    """
    Represents a person to household record mapping in the 'public' schema under 'people_groups' table.

    Attributes
    ----------
    people_id : uuid.UUID
        The unique identifier for the person in the people group, which is a foreign key referencing
        the `people` table.
    household_id : int, optional
        The unique identifier for the household associated with the entry, which is a foreign key
        referencing the `households` table. This field is optional.
    notes : str, optional
        Additional notes or comments related to the entry. This field is optional.

    household : Optional[Household]
        The associated `Household` object for this entry. Represents a many-to-one relationship where
        each entry may be linked to a single `Household`. The relationship is configured with `back_populates`
        to match the `people_group` attribute in the `Household` model, and cascading delete is disabled.

    people : Optional[People]
        The associated `People` object for this user group. Represents a one-to-one relationship where each
        entry is linked to a single `People` entity. The relationship is configured with `back_populates`
        to match the `people_group` attribute in the `People` model, and cascading delete is disabled.

    Notes
    -----
    - The `household_id` field is optional and may be `None` if not associated with a specific `Household`.
    """
    __tablename__ = "people_groups"

    people_id: uuid.UUID = Field(primary_key=True, foreign_key="public.people.id")
    household_id: int|None = Field(foreign_key="public.households.id")
    notes: str|None = Field(nullable=True)

    household: Optional["Household"] = Relationship(back_populates="people_group", cascade_delete=False)
    people: Optional["People"] = Relationship(back_populates="people_group", cascade_delete=False)
