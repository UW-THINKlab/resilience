import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class RecurringType(BasePublicSchemaModel, table=True):
    """
    Represents a recurring type in the 'public' schema under the 'recurring_types' table.

    Attributes
    ----------
    id : uuid
        The unique identifier for the recurring type.
    name : str
    num_days : int
        The number of days between recurrences.
    checklist_type : ChecklistType, optional
        A relationship to the `ChecklistType` model, representing the checklist types that can have this recurrence type.
    """

    __tablename__ = "recurring_types"

    id: uuid.UUID | None = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str | None = Field(nullable=False)
    num_days: int | None = Field(nullable=False)

    checklist_type: Optional["ChecklistType"] = Relationship(back_populates="recurring_type", cascade_delete=False)
