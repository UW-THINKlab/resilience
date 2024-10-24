import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship
from geoalchemy2 import Geometry


class Household(BasePublicSchemaModel, table=True):
    """
    Represents a household record in the 'public' schema under the 'households' table.

    Attributes
    ----------
    id : uuid
        The unique identifier for the household. This field is the primary key of the table.
    cluster_id : uuid
        The unique identifier for the cluster associated with the household. This field is a foreign key
        referencing the `clusters` table.
    name : str, optional
        The name of the household.
    address : str, optional
        The address of the household.
    notes : str, optional
        Additional notes or comments related to the household.
    pets : str, optional
        Information about pets in the household.
    accessibility_needs : str, optional
        Details about any accessibility needs of the household.
    geom : Geometry, optional
        A geometric representation of the household area, stored as a POLYGON type. This field uses the SQLAlchemy
        `Geometry` type to store spatial data.

    cluster : Optional[Cluster]
        The associated `Cluster` object for this household. Represents a many-to-one relationship where each
        `Household` belongs to a single `Cluster`. The relationship is configured with `back_populates` to match
        the `households` attribute in the `Cluster` model, and cascading delete is disabled.

    people_group : List[PeopleGroup]
        A list of `PeopleGroup` objects associated with this household. Represents a one-to-many relationship where
        each `Household` can have multiple `PeopleGroup` entities. The relationship is configured with `back_populates`
        to match the `household` attribute in the `PeopleGroup` model, and cascading delete is disabled.

    signup_code : Optional[SignupCode]
        The associated `SignupCode` object for this household. Represents a one-to-one relationship where each
        `Household` can have a single `SignupCode`. The relationship is configured with `back_populates` to match
        the `household` attribute in the `SignupCode` model, and cascading delete is

    """

    __tablename__ = "households"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    cluster_id: uuid.UUID = Field(foreign_key="public.clusters.id")

    name: str|None = Field(nullable=True)
    address: str|None = Field(nullable=True)
    notes: str|None = Field(nullable=True)
    pets: str|None = Field(nullable=True)
    accessibility_needs: str | None = Field(nullable=True)
    geom: Geometry|None = Field(sa_type=Geometry(geometry_type="POLYGON"), nullable=True)

    cluster: Optional["Cluster"] = Relationship(back_populates="households", cascade_delete=False)
    people_group: list["PeopleGroup"] = Relationship(back_populates="household", cascade_delete=False)
    signup_code: Optional["SignupCode"] = Relationship(back_populates="household", cascade_delete=False)
