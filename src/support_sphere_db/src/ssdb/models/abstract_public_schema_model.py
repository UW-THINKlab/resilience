from sqlmodel import SQLModel


class AbstractPublicSchemaModel(SQLModel):
    __table_args__ = {"schema": "public"}
