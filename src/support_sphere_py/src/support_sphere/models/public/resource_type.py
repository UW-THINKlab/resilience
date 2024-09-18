import uuid
from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ResourceType(BasePublicSchemaModel, table=True):
    """
    Represents a resource type entity in the 'public' schema under the 'resource_types' table.
    This model stores types of resources, and each resource type can have associated tags.

    Attributes
    ----------
    id : uuid
        The unique identifier for the resource type.
    name : str
        The name of the resource type. It is a required field, meaning it cannot be nullable.
    resources : list[ResourceTag]
        Defines a one-to-many relationship with the `ResourceTag` model. Each `ResourceType` can have
        multiple associated `ResourceTag` entities. `back_populates` is set to "resource_subtype_tag", establishing
        the reverse relationship. Cascading delete is disabled to prevent deletion of tags when a resource type
        is removed.

    """
    __tablename__ = "resource_types"

    id: uuid.UUID|None = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str|None = Field(nullable=False)

    resources: list["Resource"] = Relationship(back_populates="resource_type", cascade_delete=False)
