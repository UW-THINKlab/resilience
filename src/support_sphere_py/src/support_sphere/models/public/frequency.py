import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class Frequency(BasePublicSchemaModel, table=True):
    """
    Represents a frequency in the 'public' schema under the 'checklist_frequency' table.

    Attributes
    ----------
    id : uuid
        The unique identifier for the frequency.
    name : str
    num_days : int
        The number of days between recurrences.
    checklists: list[Checklists]
        A relationship to the `Checklist` model, representing the checklists that can have this frequency.
    """

    __tablename__ = "frequency"

    id: uuid.UUID | None = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str | None = Field(nullable=False)
    num_days: int | None = Field(nullable=False)

    checklists: list["Checklist"] = Relationship(back_populates="frequency", cascade_delete=False)
