import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ResourceTag(BasePublicSchemaModel, table=True):
    """
    Represents a resource tag entity in the 'public' schema under the 'resource_tags' table.
    This model links a resource to a specific subtype tag, establishing relationships between resources and their tags.

    Attributes
    ----------
    resource_id : uuid
        The unique identifier for the resource. It is a required field and references the `resources` table.
    resource_subtype_tag_id : uuid
        The unique identifier for the resource subtype tag. It d references the `resource_subtype_tags` table.
    resources : list[Resource]
        Defines a many-to-one relationship with the `Resource` model. Each `ResourceTag` is associated with a specific `Resource`.
        `back_populates` is set to "resource_tags" in the `Resource` model, establishing the reverse relationship.
    resource_subtype_tag : Optional[ResourceSubtypeTag]
        Defines a many-to-one relationship with the `ResourceSubtypeTag` model. Each `ResourceTag` is associated with a specific `ResourceSubtypeTag`.
        `back_populates` is set to "resource_tags" in the `ResourceSubtypeTag` model, establishing the reverse relationship.
 """
    __tablename__ = "resource_tags"

    resource_id: uuid.UUID = Field(primary_key=True, foreign_key="public.resources.resource_cv_id")
    resource_subtype_tag_id: uuid.UUID = Field(nullable=True, foreign_key="public.resource_subtype_tags.id")

    resources: list["Resource"] = Relationship(back_populates="resource_tags", cascade_delete=False)
    resource_subtype_tag: Optional["ResourceSubtypeTag"] = Relationship(back_populates="resource_tags", cascade_delete=False)
