import uuid
from datetime import datetime
from typing import Optional

from sqlmodel import Field, Relationship
from support_sphere.models.base import BasePublicSchemaModel


class UserResource(BasePublicSchemaModel, table=True):

    """
    Represents a user-resource relationship in the 'public' schema under the 'user_resources' table.
    This model tracks resources assigned to a user and their associated metadata.

    Attributes
    ----------
    user_id : uuid.UUID
        A foreign key reference to the `public.user_profiles` table. Each `user_id` is unique, ensuring
        a many-to-one relationship between `UserResource` and `UserProfile`.
    resource_id : int, optional
        A foreign key reference to the `public.resources` table. It is unique to ensure many-to-one
        relationships between `UserResource` and `Resource`.
    quantity : int, optional
        Specifies the quantity of the resource, with a default of 0.
    notes : str, optional
        Additional notes regarding the resource, if applicable.
    created_at : datetime
        The timestamp when the resource was created or assigned.
    updated_at : datetime
        The timestamp when the resource was last updated.
    user_profile : Optional[UserProfile]
        Defines a relationship with the `UserProfile` model. `back_populates` is set to "user_resources",
        ensuring that each user profile can access its related user resources. Cascading delete is disabled.
    resource : Optional[Resources]
        Defines a relationship with the `Resources` model. `back_populates` is set to "user_resources",
        allowing a resource to reference its relationship with a user. Cascading delete is disabled.

    Notes
    -----
    - The `user_id` and `resource_id` fields are both foreign keys to the respective tables, enforcing
      referential integrity.
    - `created_at` and `updated_at` store timestamps for the resource creation and last update.

    """

    __tablename__ = "user_resources"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="public.user_profiles.id", nullable=True)
    resource_id: uuid.UUID = Field(foreign_key="public.resources.id", nullable=True)
    quantity: int|None = Field(default=0)
    notes: str|None = Field(nullable=True)
    created_at: datetime = Field(nullable=False)
    updated_at: datetime = Field(nullable=False)

    user_profile: Optional["UserProfile"] = Relationship(back_populates="user_resources", cascade_delete=False)
    resource: Optional["Resource"] = Relationship(back_populates="user_resources", cascade_delete=False)
