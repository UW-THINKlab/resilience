import uuid
from typing import Optional
import datetime

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

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    checklist_id: uuid.UUID = Field(foreign_key="public.checklists.id", nullable=False)
    checklist_step_id: uuid.UUID = Field(foreign_key="public.checklist_steps.id", nullable=False)
    priority: int = Field(nullable=False)
    updated_at: datetime.datetime = Field(
        default_factory=lambda: datetime.datetime.now(datetime.UTC),
        nullable=False
    )

    checklists: list["Checklist"] = Relationship(back_populates="checklist_steps_orders", cascade_delete=False)
    checklist_steps: list["ChecklistStep"] = Relationship(back_populates="checklist_steps_orders", cascade_delete=False)
