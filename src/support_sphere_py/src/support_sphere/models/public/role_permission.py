import uuid
from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship
from sqlalchemy import Enum

from support_sphere.models.enums import AppRoles, AppPermissions


class RolePermission(BasePublicSchemaModel, table=True):
    """
    Represents the permissions assigned to roles in the 'public' schema under the 'role_permissions' table.

    Attributes
    ----------
    id : uuid.UUID
        The unique identifier for the role permission entry, generated automatically using UUID.
    role : AppRoles
        The role to which the permission is assigned, represented as an enum (AppRoles). This field cannot be null.
    permission : AppPermissions
        The permission granted to the role, represented as an enum (AppPermissions). This field cannot be null.

    Notes
    -----
    - The `role` and `permission` fields use the SQLAlchemy `Enum` type to store enum values for roles and permissions.
    - The relationship between `RolePermission` and `ClusterRole` is designed as a one-to-many relationship.
    """
    __tablename__ = "role_permissions"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    role: AppRoles = Field(sa_type=Enum(AppRoles, name="app_roles"), nullable=False)
    permission: AppPermissions = Field(sa_type=Enum(AppPermissions, name="app_permissions"), nullable=False)
