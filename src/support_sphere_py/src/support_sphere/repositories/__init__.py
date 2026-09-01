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

key = os.environ.get("ANON_KEY")

supabase_host = os.environ.get("API_HOST", "localhost")
supabase_port = os.environ.get("API_PORT", "8000")
supabase_url = os.environ.get('API_URL', f"http://{supabase_host}:{supabase_port}")

# Setting up the supabase client for python
supabase_client = create_client(supabase_url, key)
logger.info(f"SUPABASE CLIENT: {supabase_client}, url={supabase_url}")

db_host = os.environ.get('DB_HOST', supabase_host)
username = os.environ.get('DB_USERNAME', 'postgres')
password = os.environ.get('DB_PASSWORD', 'postgres')
db_port = os.environ.get('DB_PORT', 5432)
database = os.environ.get('DB_NAME', 'postgres')
postgres_url = os.environ.get('DB_URL', f"postgresql://{username}:{password}@{db_host}:{db_port}/{database}")

logger.info(f"DB_URL: {postgres_url}")

# change echo to True to see the SQL queries executed by psycopg2 as logs
engine = create_engine(postgres_url, echo=False)
SQLModel.metadata.create_all(bind=engine)


# SQLModel recommends to use the same engine for the connection sessions.
# https://sqlmodel.tiangolo.com/tutorial/select/#review-the-code
__all__ = ["engine", "supabase_client"]
