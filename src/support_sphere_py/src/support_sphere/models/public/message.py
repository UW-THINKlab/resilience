import uuid
import enum
import logging
import datetime

from sqlmodel import SQLModel, Field, JSON, Enum, Column

from support_sphere.models.base import BasePublicSchemaModel

log = logging.getLogger(__name__)


class MessageUrgency(str, enum.Enum):
    normal = "normal"
    important = "important"
    urgent = "urgent"
    emergency = "emergency"


class Message(BasePublicSchemaModel, table=True):
    """
    Represents a point of interest (POI) in the 'public' schema under the 'point_of_interests' table.
    Points of interest typically refer to locations that have significance within a geographical area.

    Attributes
    ----------
    id : uuid
        The unique identifier for the point of interest. This is the primary key.
    from_id: uuid
        FK of the user that sent the message
    to_id: uuid
        FK of the target of the message, user or group
    urgency: MessageUrgency
        urgency of the message
    content: str
        message content
    sent_on: datetime
        date the message was sent
    """
    __tablename__ = "messages"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    from_id: uuid.UUID = Field(foreign_key="public.user_profiles.id", nullable=True)
    to_id: uuid.UUID = Field(foreign_key="public.clusters.id", nullable=True)
    urgency: MessageUrgency | None = Field(sa_column=Column(Enum(MessageUrgency)))
    content: str | None = Field(nullable=False)
    sent_on: datetime.datetime | None = Field(nullable=False)

    @classmethod
    def fromDict(cls, dict:map):
        if "id" not in dict:
            dict['id'] = uuid.uuid4()
        if 'urgency' not in dict:
            dict['urgency'] = MessageUrgency.normal
        if 'sent_on' not in dict:
            dict['sent_on'] = datetime.datetime.now()

        return cls(**dict)