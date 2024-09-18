import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ChecklistStepsTemplate(BasePublicSchemaModel, table=True):
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
    checklist_steps_order : ChecklistStepsOrder, optional
        A relationship to the `ChecklistStepsOrder` model, which defines the order of these steps within a checklist.
    """
    __tablename__ = "checklist_steps_templates"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    title: str | None = Field(nullable=False)
    description: str | None = Field(nullable=True)

    checklist_steps_order: Optional["ChecklistStepsOrder"] = Relationship(back_populates="checklist_steps_template",
                                                                          cascade_delete=False)
