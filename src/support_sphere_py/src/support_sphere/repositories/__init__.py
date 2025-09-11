import os
import logging

from supabase import create_client
# DO NOT REMOVE: SQLModel requires the models (tables) to be imported so that it is added to the SQLModel.metadata
# https://sqlmodel.tiangolo.com/tutorial/create-db-and-table/#sqlmodel-metadata-order-matters
from sqlmodel import SQLModel, create_engine
from support_sphere.models.auth import *
from support_sphere.models.public import *

from dotenv import load_dotenv


logger = logging.getLogger(__name__)

load_dotenv()

username = os.environ.get('DB_USERNAME', 'postgres')
db_host = os.environ.get('DB_HOST', 'localhost')
password = os.environ.get('DB_PASSWORD', 'example123456')
db_port = os.environ.get('DB_PORT', 5432)
database = os.environ.get('DB_NAME', 'postgres')
postgres_url = os.environ.get('DB_URL',
                              f"postgresql://{username}:{password}@{db_host}:{db_port}/{database}")

logger.info(f"DB_URL URL: {postgres_url}")

# change echo to True to see the SQL queries executed by psycopg2 as logs
engine = create_engine(postgres_url, echo=False)
SQLModel.metadata.create_all(bind=engine)

logger.info("Establishing connection via supabase")
# Setting up the supabase client for python

supabase_host = os.environ.get("SUPABASE_KONG_HOST", "localhost")
supabase_port = os.environ.get("SUPABASE_KONG_PORT", "8000")
key = os.environ.get("JWT_ANON_KEY")

url = f"http://{supabase_host}:{supabase_port}/"
logger.info(f"URL: {url}")

supabase_client = create_client(url, key)

# SQLModel recommends to use the same engine for the connection sessions.
# https://sqlmodel.tiangolo.com/tutorial/select/#review-the-code
__all__ = ["engine", "supabase_client"]
