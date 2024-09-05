
from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship
from geoalchemy2 import Geometry


class Cluster(BasePublicSchemaModel, table=True):

    """
    Represents a unique cluster in the 'public' schema under 'clusters' table.

    Attributes
    ----------
    id : int, optional
        The unique identifier for the cluster. This field is the primary key of the table.
    name : str, optional
        The name of the cluster.
    meeting_place : str, optional
        The location where meetings are held for the cluster.
    notes : str, optional
        Additional notes or comments related to the cluster.
    geom : Geometry, optional
        A geometric representation of the cluster area, stored as a POLYGON type. This field uses the SQLAlchemy
        `Geometry` type to store spatial data.
    households : list[Household]
        A list of `Household` entries associated with this cluster, representing a one-to-many relationship
        where a  single `Cluster` can have multiple households. The relationship is configured with `back_populates`
        to match the `cluster` attribute in the `Household` model, and cascade delete is disabled.
    user_captains : list[UserCaptainCluster]
        A list of `UserCaptainCluster` entries associated with this cluster, representing a one-to-many relationship
        where a  single `Cluster` can have multiple captains. The relationship is configured with `back_populates`
        to match the `cluster` attribute in the `UserCaptainCluster` model, and cascade delete is disabled.

    Notes
    -----
    - The `geom` field is intended to store spatial data and uses the `Geometry` type from SQLAlchemy for handling
      geographical information.
    - `households` is a relationship attribute connecting the `Cluster` model to the `Household` model. It allows
      for navigating from a `Cluster` to its associated `Households`.
    """

    __tablename__ = "clusters"

    id: int|None = Field(primary_key=True)
    name: str|None = Field(nullable=True)
    meeting_place: str|None = Field(nullable=True)
    notes: str | None = Field(nullable=True)
    geom: Geometry|None = Field(sa_type=Geometry(geometry_type="POLYGON"), nullable=True)

    households: list["Household"] = Relationship(back_populates="cluster", cascade_delete=False)
    user_captains: list["UserCaptainCluster"] = Relationship(back_populates="cluster", cascade_delete=False)
