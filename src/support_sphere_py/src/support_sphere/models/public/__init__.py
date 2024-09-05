from support_sphere.models.public.user_profile import UserProfile
from support_sphere.models.public.people import People
from support_sphere.models.public.cluster import Cluster
from support_sphere.models.public.people_group import PeopleGroup
from support_sphere.models.public.household import Household
from support_sphere.models.public.user_role import UserRole
from support_sphere.models.public.user_captain_cluster import UserCaptainCluster
from support_sphere.models.public.role_permission import RolePermission
from support_sphere.models.public.operational_event import OperationalEvent


# New models created should be exposed by adding to __all__. This is used by SQLModel.metadata
# https://sqlmodel.tiangolo.com/tutorial/create-db-and-table/#sqlmodel-metadata-order-matters
__all__ = ['UserProfile', 'People', 'Cluster', 'PeopleGroup', 'Household', 'UserRole', 'UserCaptainCluster',
           'RolePermission', 'OperationalEvent']
