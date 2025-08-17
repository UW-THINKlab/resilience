import uuid
import logging

from sqlmodel import Field, Relationship
from geoalchemy2 import Geometry, WKBElement

from support_sphere.models.base import BasePublicSchemaModel
#from support_sphere.repositories.base_repository import BaseRepository

log = logging.getLogger(__name__)

class PointOfInterestType(BasePublicSchemaModel, table=True):
    """
    Represents a point-of-interest type entity in the 'public' schema under the 'point_of_interest_types' table.
    This model stores types of resources, and each resource type can have associated tags.

    Attributes
    ----------
    name : str
        The name of the point-of-interest type. It is a required field, meaning it cannot be nullable.
    icon : str
        The icon associated with the point-of-interest type. It is a required field, meaning it cannot be nullable.
    """
    __tablename__ = "point_of_interest_types"

    name: str = Field(nullable=False, primary_key=True)
    icon: str = Field(nullable=False)


class PointOfInterest(BasePublicSchemaModel, table=True):
    """
    Represents a point of interest (POI) in the 'public' schema under the 'point_of_interests' table.
    Points of interest typically refer to locations that have significance within a geographical area.

    Attributes
    ----------
    id : uuid
        The unique identifier for the point of interest. This is the primary key.
    name : str, optional
        The name of the point of interest. This field is required.
    address : str, optional
        The address or description of the location for the point of interest. This field is required.
    geom : Geometry, optional
        A geometry field that represents the location's spatial data as a POLYGON. Uses GeoAlchemy2 to store spatial data.
    """
    __tablename__ = "point_of_interests"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str | None = Field(nullable=False)
    address: str | None = Field(nullable=False)
    geom: WKBElement|None = Field(sa_type=Geometry(geometry_type="POINT"), nullable=True)
    point_type_name: str = Field(foreign_key="public.point_of_interest_types.name", nullable=False)
    point_type: PointOfInterestType = Relationship(cascade_delete=False)
