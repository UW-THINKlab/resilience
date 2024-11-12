import uuid
from typing import Optional
import datetime

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ChecklistStepsState(BasePublicSchemaModel, table=True):
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
    __tablename__ = "checklist_steps_states"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    checklist_steps_order_id: uuid.UUID = Field(foreign_key="public.checklist_steps_orders.id", nullable=False)
    user_profile_id: uuid.UUID = Field(foreign_key="public.user_profiles.id", nullable=False)
    is_completed: bool = Field(default=False, nullable=False)

    checklist_steps_order: "ChecklistStepsOrder" = Relationship(cascade_delete=False)
    user_profile: Optional["UserProfile"] = Relationship(back_populates="checklist_steps_state", cascade_delete=False)
