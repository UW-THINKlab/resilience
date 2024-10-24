import uuid
from typing import Optional

from support_sphere.models.base import BasePublicSchemaModel
from sqlmodel import Field, Relationship


class SignupCode(BasePublicSchemaModel, table=True):
    """
    Represents signup codes record in the 'public' schema under the 'signup_code' table.

    Attributes
    ----------
    code : str
        The unique identifier for the household. This field is the primary key of the table.
    household_id : uuid
        The unique identifier for the household associated with the signup code. This field is a foreign key
        referencing the `household` table.

    household : Optional[Household]
        The associated `Household` object for this signup_code. Represents a one-to-one relationship where each
        `SignupCode` belongs to a single `Household`. The relationship is configured with `back_populates` to match
        the `signup_code` attribute in the `Household` model, and cascading delete is disabled.
    """

    __tablename__ = "signup_codes"

    code: str = Field(primary_key=True)
    household_id: uuid.UUID = Field(foreign_key="public.households.id")

    household: Optional["Household"] = Relationship(back_populates="signup_code", cascade_delete=False)
