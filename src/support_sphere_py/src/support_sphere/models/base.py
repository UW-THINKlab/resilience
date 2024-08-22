from sqlmodel import SQLModel


class BasePublicSchemaModel(SQLModel):
    """
    Base model for all tables in the 'public' schema.
    It is intended to be extended by other models that should reside in the 'public' schema.

    Attributes
    ----------
    __table_args__ : dict
        Specifies the schema as 'public' for all inheriting models.

    """
    __table_args__ = {"schema": "public"}
