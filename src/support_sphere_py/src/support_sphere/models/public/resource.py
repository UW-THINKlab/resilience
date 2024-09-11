from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class Resource(BasePublicSchemaModel, table=True):
    """
    Represents a resource entity in the 'public' schema under the 'resources' table.
    Resources represent items or assets that have attributes like quantity, description, and tags.

    Attributes
    ----------
    id : int, optional
        The unique identifier for the resource. This is the primary key.
    resource_type : int, optional
        A foreign key referring to the 'resource_types' table that categorizes the resource.
    name : str, optional
        The name of the resource. This field is required.
    description : str, optional
        A description of the resource, providing details about its use or nature.
    notes : str, optional
        Additional notes or comments about the resource.
    qty_needed : int, optional
        The quantity of the resource that is needed. Default is 0.
    qty_available : int, optional
        The quantity of the resource that is available. Default is 0.
    resource_tags : list[ResourceTag]
        Defines a one-to-many relationship with the `ResourceTag` model, allowing multiple tags to be associated with a resource.
    user_resources : list[UserResource]
        Defines a one-to-many relationship with the `UserResource` model, associating user with specific resources.
    """

    __tablename__ = "resources"

    id: int | None = Field(primary_key=True)
    resource_type_id: int|None = Field(foreign_key="public.resource_types.id", nullable=False)
    name: str | None = Field(nullable=False)
    description: str | None = Field(nullable=True)
    notes: str | None = Field(nullable=False)

    qty_needed: int|None = Field(nullable=False, default=0)
    qty_available: int|None = Field(nullable=False, default=0)

    resource_tags: list["ResourceTag"] = Relationship(back_populates="resources", cascade_delete=False)
    user_resources: list["UserResource"] = Relationship(back_populates="resource", cascade_delete=False)
    resource_type: Optional["ResourceType"] = Relationship(back_populates="resources", cascade_delete=False)
