import uuid
from typing import Optional
import datetime

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ChecklistStep(BasePublicSchemaModel, table=True):
    """
    Represents a template for checklist steps in the 'public' schema under the 'checklist_steps_templates' table.

    Attributes
    ----------
    id : uuid
        The unique identifier for the checklist step template.
    title : str
        The title of the checklist step template.
    description : str, optional
        A detailed description of the checklist step template.
    checklist_steps_order : list[ChecklistStepsOrder]
        A relationship to the `ChecklistStepsOrder` model, which defines the order of these steps within a checklist.
    """
    __tablename__ = "checklist_steps"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    label: str | None = Field(nullable=False)
    description: str | None = Field(nullable=True)
    updated_at: datetime.datetime = Field(
        default_factory=lambda: datetime.datetime.now(datetime.UTC),
        nullable=False
    )

    checklist_steps_orders: list["ChecklistStepsOrder"] = Relationship(back_populates="checklist_steps",
                                                                          cascade_delete=True)
