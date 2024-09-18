import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class UserCaptainCluster(BasePublicSchemaModel, table=True):
    """
    Represents the association between clusters and the captain role in the 'public' schema under the 'user_captain_clusters'
     table.

    Attributes
    ----------
    id : uuid.UUID
        The unique identifier for the cluster role entry, generated automatically using UUID.
    cluster_id : uuid.UUID
        The identifier for the cluster that this role is associated with, representing a foreign key
        to the 'public.clusters' table.
    user_role_id : uuid.UUID
        The identifier for the user_role associated with this cluster, representing a foreign key
        to the 'public.user_roles' table.
    cluster : Optional[Cluster]
        The associated `Cluster` object, representing a many-to-one relationship between `UserCaptainCluster`
        and `Cluster`. Cascading delete is disabled.
    user_role : Optional[UserRole]
        The associated `UserRole` object, representing a many-to-one relationship between `UserCaptainCluster`
        and `UserRole`. Cascading delete is disabled.

    Notes
    -----
    - The `cluster_id` and `role_permission_id` fields create foreign key constraints to the 'clusters' and
      'user_roles' tables respectively.
    - The relationships with `Cluster` and `RolePermission` are designed as many-to-one relationships.
    """
    __tablename__ = "user_captain_clusters"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    cluster_id: uuid.UUID = Field(foreign_key="public.clusters.id", nullable=False)
    user_role_id: uuid.UUID = Field(foreign_key="public.user_roles.id", nullable=False)

    cluster: Optional["Cluster"] = Relationship(back_populates="user_captains", cascade_delete=False)
    user_role: Optional["UserRole"] = Relationship(back_populates="user_captains", cascade_delete=False)
