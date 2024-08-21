from sqlmodel import SQLModel


class BasePublicSchemaModel(SQLModel):
    __table_args__ = {"schema": "public"}
