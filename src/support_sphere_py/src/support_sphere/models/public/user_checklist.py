import uuid
from datetime import datetime
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class UserChecklist(BasePublicSchemaModel, table=True):

    """
    Represents a checklist associated with a user in the 'public' schema under the 'user_checklists' table.
    Each checklist is linked to a specific user and a checklist type, with details such as the due date
    and the last completed version.

    Attributes
    ----------
    id : uuid.UUID
        The unique identifier for the checklist, serving as the primary key.
    user_id : uuid.UUID, optional
        Foreign key linking to the `user_profiles` table, representing the user associated with the checklist.
    checklist_type_id : uuid.UUID, optional
        Foreign key linking to the `checklist_types` table, specifying the type of checklist.
    due_date : datetime, optional
        The due date for the checklist completion.
    last_completed_version : int, optional
        The version number of the checklist that was last completed by the user.
    checklist_type : ChecklistType, optional
        A relationship to the `ChecklistType` model, representing the type of the checklist.
    user_profile : UserProfile, optional
        A relationship to the `UserProfile` model, representing the user who owns the checklist.
    user_checklist_state : UserChecklistState, optional
        A relationship to the `UserChecklistState` model, representing the current state of the checklist.
    """

    __tablename__ = "user_checklists"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID | None = Field(foreign_key="public.user_profiles.id", nullable=False)
    checklist_type_id: uuid.UUID = Field(foreign_key="public.checklist_types.id", nullable=False)
    due_date: datetime = Field(nullable=True)
    last_completed_version: int | None = Field(nullable=False)

    checklist_type: Optional["ChecklistType"] = Relationship(back_populates="user_checklists", cascade_delete=False)
    user_profile: Optional["UserProfile"] = Relationship(back_populates="user_checklists", cascade_delete=False)
    user_checklist_state: Optional["UserChecklistState"] = Relationship(back_populates="user_checklist",
                                                                        cascade_delete=False)
