import uuid
from datetime import datetime
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class UserChecklists(BasePublicSchemaModel, table=True):

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
    checklists : list[Checklist]
        A relationship to the `Checklist` model, representing the checklist.
    user_profile : UserProfile
        A relationship to the `UserProfile` model, representing the user who owns the checklists.
    """

    __tablename__ = "user_checklists"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    checklist_id: uuid.UUID = Field(foreign_key="public.checklists.id", nullable=False)
    user_profile_id: uuid.UUID = Field(foreign_key="public.user_profiles.id", nullable=False)
    completed_at: datetime | None = Field(nullable=True)

    checklists: list["Checklist"] = Relationship(back_populates="user_checklists", cascade_delete=False)
    user_profile: "UserProfile" = Relationship(back_populates="user_checklists", cascade_delete=False)
