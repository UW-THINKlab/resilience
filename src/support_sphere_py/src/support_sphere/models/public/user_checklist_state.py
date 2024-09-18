import uuid
from datetime import datetime
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class UserChecklistState(BasePublicSchemaModel, table=True):

    """
    Represents the state of a user checklist in the 'public' schema under the 'user_checklist_states' table.
    This table tracks whether a checklist has been completed and when it was completed.

    Attributes
    ----------
    id : uuid
        The unique identifier for the checklist state, which also serves as a foreign key from the `user_checklists` table.
    completed : bool
        Indicates whether the checklist has been completed (True or False).
    completed_at : datetime
        The date and time when the checklist was completed.
    user_checklist : UserChecklist, optional
        A relationship to the `UserChecklist` model, representing the checklist whose state is being tracked.
    """

    __tablename__ = "user_checklist_states"

    id: uuid.UUID | None = Field(primary_key=True, foreign_key="public.user_checklists.id")
    completed: bool | None = Field(nullable=False)
    completed_at: datetime = Field(nullable=False)

    user_checklist: Optional["UserChecklist"] = Relationship(back_populates="user_checklist_state", cascade_delete=False)
