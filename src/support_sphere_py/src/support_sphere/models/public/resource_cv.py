import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ResourceCV(BasePublicSchemaModel, table=True):
    """
    ResourceCV represents a list of resource controlled vocabulary (CV) items in the 'public' schema under the 'resources_cv' table.

    Attributes
    ----------
    id : uuid
        The unique identifier for the resource. This is the primary key.
    name : str, optional
        The name of the resource. This field is required.
    description : str, optional
        A description of the resource, providing details about its use or nature.
    """

    __tablename__ = "resources_cv"

    id: uuid.UUID | None = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str | None = Field(nullable=False)
    description: str | None = Field(nullable=True)

    resource: "Resource" = Relationship(back_populates="resource_cv", cascade_delete=False)
