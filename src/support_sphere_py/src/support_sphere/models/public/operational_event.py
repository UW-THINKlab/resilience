import uuid
from datetime import datetime
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship
from sqlalchemy import Enum

from support_sphere.models.enums import OperationalStatus


class OperationalEvent(BasePublicSchemaModel, table=True):
    """
    Represents an operational event in the 'public' schema under the 'operational_events' table.

    Attributes
    ----------
    id : uuid.UUID
        The unique identifier for the operational event, generated automatically using UUID.
    created_by : uuid.UUID
        The identifier of the user profile that created the event, representing a foreign key
        to the 'public.user_profiles' table. This field cannot be null.
    created_at : datetime
        The timestamp of when the event was created. This field cannot be null.
    status : OperationalStatus
        The status of the operational event, represented as an enum (OperationalStatus). This field cannot be null.
    user_profile : Optional[UserProfile]
        The associated `UserProfile` object, representing a many-to-one relationship between `OperationalEvent`
        and `UserProfile`. Cascading delete is disabled.
    """

    __tablename__ = "operational_events"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    created_by: uuid.UUID | None = Field(foreign_key="public.user_profiles.id", nullable=False)
    created_at: datetime = Field(nullable=False)
    status: OperationalStatus = Field(sa_type=Enum(OperationalStatus, name="operational_status"), nullable=False)

    user_profile: Optional["UserProfile"] = Relationship(back_populates="operational_events", cascade_delete=False)
