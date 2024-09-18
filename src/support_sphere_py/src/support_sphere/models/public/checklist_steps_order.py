import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ChecklistStepsOrder(BasePublicSchemaModel, table=True):
    """
    Defines the ordering of checklist steps for specific checklist types.
    It manages the priority and versioning of steps from the `checklist_steps_templates`.

    Attributes
    ----------
    checklist_types_id : uuid
        Foreign key that links to the specific checklist type.
    checklist_steps_templates_id : uuid
        Foreign key that links to the template of the checklist step.
    priority : int
        The priority of the step in the checklist. Lower numbers represent higher priority.
    version : int
        The version of the checklist step.
    checklist_steps_template : ChecklistStepsTemplate, optional
        A relationship to the `ChecklistStepsTemplate` model.
    checklist_type : ChecklistType, optional
        A relationship to the `ChecklistType` model.
    """

    __tablename__ = "checklist_steps_orders"

    checklist_types_id: uuid.UUID | None = Field(primary_key=True, foreign_key="public.checklist_types.id")
    checklist_steps_templates_id: uuid.UUID | None = Field(foreign_key="public.checklist_steps_templates.id")
    priority: int | None = Field(nullable=False)
    version: int | None = Field(nullable=False)

    checklist_steps_template: Optional["ChecklistStepsTemplate"] = Relationship(back_populates="checklist_steps_order",                                                                            cascade_delete=False)
    checklist_type: Optional["ChecklistType"] = Relationship(back_populates="checklist_steps_order", cascade_delete=False)
