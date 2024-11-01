import typer

import logging
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker
from support_sphere.repositories import engine
from typing_extensions import Annotated

logger = logging.getLogger(__name__)

Session = sessionmaker(bind=engine)
session = Session()

# The types sub-app which will be the part of main app.
execute_sql_app = typer.Typer()

# SQL for custom_access_token_hook function
custom_access_token_hook_sql = """
BEGIN;
  -- Add user_role as part of access token claim
  CREATE OR REPLACE FUNCTION public.custom_access_token(event jsonb)
  RETURNS jsonb
  LANGUAGE plpgsql
  STABLE
  AS $$
    DECLARE
      claims jsonb;
      user_role public.app_roles;
    BEGIN
      -- Fetch the user role from the user_roles table
      SELECT role INTO user_role
      FROM public.user_roles
      WHERE user_profile_id = (event->>'user_id')::uuid;

      claims := event->'claims';

      -- Set or remove the user_role claim based on the presence of user_role
      IF user_role IS NOT NULL THEN
        claims := jsonb_set(claims, '{user_role}', to_jsonb(user_role));
      ELSE
        claims := jsonb_set(claims, '{user_role}', 'null');
      END IF;

      -- Update the 'claims' object in the original event
      event := jsonb_set(event, '{claims}', claims);

      -- Return the modified event
      RETURN event;
    END;
  $$;

  -- Grant permissions
  GRANT USAGE ON SCHEMA public TO supabase_auth_admin;
  GRANT EXECUTE ON FUNCTION public.custom_access_token TO supabase_auth_admin;

  -- Revoke permissions
  REVOKE EXECUTE ON FUNCTION public.custom_access_token FROM authenticated, anon, public;

  GRANT ALL ON TABLE public.user_roles TO supabase_auth_admin;

  COMMIT;
"""

# SQL for role_based_authorization function
role_based_authorization_sql = """
BEGIN;
  -- Function to check if the user is allowed to perform a certain operation
  CREATE OR REPLACE FUNCTION public.authorize(
    requested_permission public.app_permissions
  )
  RETURNS boolean AS $$
  DECLARE
    bind_permissions int;
    user_role public.app_roles;
  BEGIN
    -- Fetch user role from JWT claims
    SELECT (auth.jwt() ->> 'user_role')::public.app_roles INTO user_role;

    -- Check if the user's role has the requested permission
    SELECT count(*)
    INTO bind_permissions
    FROM public.role_permissions
    WHERE role_permissions.permission = requested_permission
      AND role_permissions.role = user_role;

    -- Return true if the permission is granted, otherwise false
    RETURN bind_permissions > 0;
  END;
  $$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '';

  CREATE POLICY "Allow authorized SELECT access" on public.operational_events FOR SELECT USING ( (SELECT authorize('OPERATIONAL_EVENT_READ')) );
  CREATE POLICY "Allow authorized INSERT access" on public.operational_events FOR INSERT WITH CHECK (authorize('OPERATIONAL_EVENT_CREATE'));
  CREATE POLICY "Allow authorized UPDATE access" on public.operational_events FOR UPDATE USING ( (SELECT authorize('OPERATIONAL_EVENT_CREATE')) );

  ALTER TABLE public.operational_events ENABLE ROW LEVEL SECURITY;

COMMIT;
"""

# SQL For activating realtime tables
activate_realtime_tables_sql = """
BEGIN;
  -- See: https://supabase.com/docs/guides/realtime for more details about enabling realtime on tables

  -- Enable realtime on the 'operational_events' table
  ALTER PUBLICATION supabase_realtime ADD TABLE public.operational_events;
COMMIT;
"""


# Execute the SQL commands
@execute_sql_app.command(help="CLI command to execute custom SQL statement passed as `sql_text` argument in multi-line string")
def run_custom_sql_statement(
        sql_text: Annotated[
        str,
        typer.Option(
            help="SQL command to execute. Entered as multi-line string",
        ),
    ],):
    with session:
        try:
            session.execute(text(sql_text))
            session.commit()  # Commit the transaction if successful
            logger.info("Functions executed successfully.")
        except Exception as ex:
            session.rollback()  # Rollback in case of an error
            logger.info(f"Error occurred while executing {sql_text}:\n{ex}")


@execute_sql_app.command(help="Runs the SQL code to setup custom hooks, role based authorization and real-time tables")
def run_all():
    logger.info("Executing custom_access_token_hook_sql...")
    run_custom_sql_statement(custom_access_token_hook_sql)

    logger.info("Execution role_based_authorization_sql...")
    run_custom_sql_statement(role_based_authorization_sql)

    logger.info("Activating realtime tables...")
    run_custom_sql_statement(activate_realtime_tables_sql)


if __name__ == '__main__':
    execute_sql_app()
