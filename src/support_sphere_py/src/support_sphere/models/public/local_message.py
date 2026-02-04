import uuid
import datetime
from typing import Any
from geoalchemy2 import Geometry

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Column


class LocalMessage(BasePublicSchemaModel, table=True):
    """
    Represents a message entity in the 'public' schema under the 'local_messages' table.
    This table defines messages with geoloc coordinates

    Attributes
    ----------
    id : uuid
        The unique identifier for the checklist.
    message : str
        The message
    code : str, optional
        A optional short-code, to represent special catagories of messages
    location : A geographic location, represented by lat and long
    updated_at : datetime
        The timestamp for the last update of this checklist.
    """

    __tablename__ = "local_messages"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    message: str | None = Field(nullable=False)
    code: str | None = Field(nullable=True)
    location: Any = Field(sa_column=Column(Geometry('POINT'))) # Here POINT is used but could be other geometries as well
    updated_at: datetime.datetime = Field(
        default_factory=lambda: datetime.datetime.now(datetime.UTC),
        nullable=False
    )
