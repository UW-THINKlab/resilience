from support_sphere.models.public.user_profile import UserProfile
from support_sphere.models.public.people import People


# New models created should be exposed by adding to __all__. This is used by SQLModel.metadata
# https://sqlmodel.tiangolo.com/tutorial/create-db-and-table/#sqlmodel-metadata-order-matters
__all__ = ['UserProfile', 'People']
