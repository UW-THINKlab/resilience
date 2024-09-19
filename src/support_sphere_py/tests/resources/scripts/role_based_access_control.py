import logging
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker
from support_sphere.repositories import engine

logger = logging.getLogger(__name__)

Session = sessionmaker(bind=engine)
session = Session()

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
  
  REVOKE ALL ON TABLE public.user_roles FROM authenticated, anon, public;
  
  CREATE POLICY "Allow auth admin to read user roles" ON public.user_roles AS PERMISSIVE FOR SELECT TO supabase_auth_admin USING (true);
  
  ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
  
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

# Execute the SQL commands
def execute_custom_sql_statement(sql_text):
    with session:
        try:
            session.execute(text(sql_text))
            session.commit()  # Commit the transaction if successful
            logger.info("Functions executed successfully.")
        except Exception as ex:
            session.rollback()  # Rollback in case of an error
            logger.info(f"Error occurred while executing {sql_text}:\n{ex}")


if __name__ == '__main__':
    logger.info("Executing custom_access_token_hook_sql...")
    execute_custom_sql_statement(custom_access_token_hook_sql)

    logger.info("Execution role_based_authorization_sql...")
    execute_custom_sql_statement(role_based_authorization_sql)
