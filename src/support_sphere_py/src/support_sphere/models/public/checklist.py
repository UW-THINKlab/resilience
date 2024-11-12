import uuid
import datetime
from typing import Optional
from sqlalchemy import Enum

from support_sphere.models.base import BasePublicSchemaModel
from support_sphere.models.enums import Priority
from sqlmodel import Field, Relationship


class Checklist(BasePublicSchemaModel, table=True):
    """
    Represents a checklist entity in the 'public' schema under the 'checklists' table.
    This table defines different types of checklists, including the associated frequency.

    Attributes
    ----------
    id : uuid
        The unique identifier for the checklist.
    recurring_type_id : uuid
        The foreign key referring to the frequency.
    title : str
        The title of the checklist.
    description : str, optional
        A detailed description of the checklist.
    current_version : int
        The current version of this checklist.
    updated_at : datetime
        The timestamp for the last update of this checklist.
    frequency : Frequency, optional
        A relationship to the `Frequency` model.
    user_checklists : list[UserChecklists]
        A list of `UserChecklist` entities associated with this checklist.
    """

    __tablename__ = "checklists"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    title: str | None = Field(nullable=False)
    description: str | None = Field(nullable=True)
    notes: str | None = Field(nullable=True)
    updated_at: datetime.datetime = Field(
        default_factory=lambda: datetime.datetime.now(datetime.UTC),
        nullable=False
    )
    priority: Priority = Field(default=Priority.LOW, sa_type=Enum(Priority, name="priority"), nullable=False)
    frequency_id: uuid.UUID | None = Field(foreign_key="public.frequency.id", nullable=True)

    frequency: Optional["Frequency"] = Relationship(back_populates="checklists", cascade_delete=False)
    user_checklists: list["UserChecklists"] = Relationship(back_populates="checklists", cascade_delete=False)
    checklist_steps_orders: list["ChecklistStepsOrder"] = Relationship(back_populates="checklists", cascade_delete=False)
