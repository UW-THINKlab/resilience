from support_sphere.models.public.checklist_steps_order import ChecklistStepsOrder
from support_sphere.models.public.checklist_steps_template import ChecklistStepsTemplate
from support_sphere.models.public.checklist_type import ChecklistType
from support_sphere.models.public.cluster import Cluster
from support_sphere.models.public.household import Household
from support_sphere.models.public.operational_event import OperationalEvent
from support_sphere.models.public.people import People
from support_sphere.models.public.people_group import PeopleGroup
from support_sphere.models.public.point_of_interest import PointOfInterest
from support_sphere.models.public.recurring_type import RecurringType
from support_sphere.models.public.resource import Resource
from support_sphere.models.public.resource_subtype_tag import ResourceSubtypeTag
from support_sphere.models.public.resource_tag import ResourceTag
from support_sphere.models.public.resource_type import ResourceType
from support_sphere.models.public.resource_cv import ResourceCV
from support_sphere.models.public.role_permission import RolePermission
from support_sphere.models.public.user_captain_cluster import UserCaptainCluster
from support_sphere.models.public.user_checklist import UserChecklist
from support_sphere.models.public.user_checklist_state import UserChecklistState
from support_sphere.models.public.user_profile import UserProfile
from support_sphere.models.public.user_resource import UserResource
from support_sphere.models.public.user_role import UserRole
from support_sphere.models.public.signup_code import SignupCode



# New models created should be exposed by adding to __all__. This is used by SQLModel.metadata
# https://sqlmodel.tiangolo.com/tutorial/create-db-and-table/#sqlmodel-metadata-order-matters
__all__ = [
    "ChecklistStepsOrder",
    "ChecklistStepsTemplate",
    "ChecklistType",
    "Cluster",
    "Household",
    "OperationalEvent",
    "People",
    "PeopleGroup",
    "PointOfInterest",
    "RecurringType",
    "Resource",
    "ResourceSubtypeTag",
    "ResourceTag",
    "ResourceType",
    "ResourceCV",
    "RolePermission",
    "SignupCode",
    "UserCaptainCluster",
    "UserChecklist",
    "UserChecklistState",
    "UserProfile",
    "UserResource",
    "UserRole",
]
