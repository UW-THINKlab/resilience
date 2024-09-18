import uuid
from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class ResourceSubtypeTag(BasePublicSchemaModel, table=True):
    """
    Represents a resource subtype tag entity in the 'public' schema under the 'resource_subtype_tags' table.
    This model categorizes resources by tagging them with specific subtype tags.

    Attributes
    ----------
    id : uuid
        The unique identifier for the resource subtype tag. It is the primary key.
    name : str, optional
        The name of the subtype tag. This field is required.
    resource_tags : list[ResourceTag]
        Defines a one-to-many relationship with the `ResourceTag` model. Each `ResourceSubtypeTag` can be associated
        with multiple `ResourceTag` entities. The `back_populates` is set to "resource_subtype_tag" in the `ResourceTag`
        model, establishing the reverse relationship.
    """

    __tablename__ = "resource_subtype_tags"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str|None = Field(nullable=False)

    resource_tags: list["ResourceTag"] = Relationship(back_populates="resource_subtype_tag", cascade_delete=False)
