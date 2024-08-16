import os
from sqlmodel import SQLModel, create_engine

import logging

# DO NOT REMOVE: SQLModel requires the models (tables) to be imported so that it is added to the SQLModel.metadata
# https://sqlmodel.tiangolo.com/tutorial/create-db-and-table/#sqlmodel-metadata-order-matters
from ssdb.models import *

logger = logging.getLogger(__name__)

username = os.environ.get('DB_USERNAME', 'postgres')
db_host = os.environ.get('DB_HOST', 'localhost')
db_port = os.environ.get('DB_PORT', 5432)
database = os.environ.get('DATABASE', 'postgres')

postgres_url = f"postgresql://{username}@{db_host}:{db_port}/{database}"

# change echo to True to see the SQL queries executed by psycopg2 as logs
engine = create_engine(postgres_url, echo=False)
SQLModel.metadata.create_all(bind=engine)

# SQLModel recommends to use the same engine for the connection sessions.
# https://sqlmodel.tiangolo.com/tutorial/select/#review-the-code
__all__ = ["engine"]
