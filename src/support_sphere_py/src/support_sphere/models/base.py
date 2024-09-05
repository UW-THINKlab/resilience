from sqlmodel import SQLModel
from pydantic import ConfigDict


class BasePublicSchemaModel(SQLModel):
    """
    Base model for all tables in the 'public' schema.
    It is intended to be extended by other models that should reside in the 'public' schema.

    Attributes
    ----------
    __table_args__ : dict
        Specifies the schema as 'public' for all inheriting models.
    model_config : ConfigDict
        This is defined using Pydantic's `ConfigDict`. Configuration dictionary allowing
        arbitrary/custom column types for inheriting models.
    """
    __table_args__ = {"schema": "public"}
    model_config: ConfigDict = ConfigDict(arbitrary_types_allowed=True)
