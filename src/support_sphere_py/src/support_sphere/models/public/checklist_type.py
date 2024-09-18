import uuid
from datetime import datetime
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ChecklistType(BasePublicSchemaModel, table=True):

    """
    Represents a checklist type entity in the 'public' schema under the 'checklist_types' table.
    This table defines different types of checklists, including the associated recurring type.

    Attributes
    ----------
    id : uuid
        The unique identifier for the checklist type.
    recurring_type_id : uuid
        The foreign key referring to the recurring type.
    title : str
        The title of the checklist type.
    description : str, optional
        A detailed description of the checklist type.
    current_version : int
        The current version of this checklist type.
    updated_at : datetime
        The timestamp for the last update of this checklist type.
    recurring_type : RecurringType, optional
        A relationship to the `RecurringType` model.
    user_checklists : list[UserChecklist]
        A list of `UserChecklist` entities associated with this checklist type.
    checklist_steps_order : ChecklistStepsOrder, optional
        A relationship to define the order of checklist steps for this checklist type.
    """

    __tablename__ = "checklist_types"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    recurring_type_id: uuid.UUID | None = Field(foreign_key="public.recurring_types.id", nullable=True)
    title: str | None = Field(nullable=False)
    description: str | None = Field(nullable=True)
    current_version: int | None = Field(nullable=False)
    updated_at: datetime = Field(nullable=False)

    recurring_type: Optional["RecurringType"] = Relationship(back_populates="checklist_type", cascade_delete=False)
    user_checklists: list["UserChecklist"] = Relationship(back_populates="checklist_type", cascade_delete=False)
    checklist_steps_order: Optional["ChecklistStepsOrder"] = Relationship(back_populates="checklist_type",
                                                                          cascade_delete=False)
