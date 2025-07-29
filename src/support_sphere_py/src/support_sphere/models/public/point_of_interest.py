import uuid
from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field
from geoalchemy2 import WKBElement, Geometry


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
    geom: WKBElement|None = Field(sa_type=Geometry(geometry_type="POLYGON"), nullable=True)
