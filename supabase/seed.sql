-- Enable the "postgis" extension
create extension postgis with schema "extensions";



SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."app_permissions" AS ENUM (
    'OPERATIONAL_EVENT_READ',
    'OPERATIONAL_EVENT_CREATE'
);


ALTER TYPE "public"."app_permissions" OWNER TO "postgres";


CREATE TYPE "public"."app_roles" AS ENUM (
    'USER',
    'SUBCOM_AGENT',
    'COM_ADMIN',
    'ADMIN'
);


ALTER TYPE "public"."app_roles" OWNER TO "postgres";


CREATE TYPE "public"."group_chat_type" AS ENUM (
    'request',
    'chat'
);


ALTER TYPE "public"."group_chat_type" OWNER TO "postgres";


CREATE TYPE "public"."message_type" AS ENUM (
    'resource_request',
    'text'
);


ALTER TYPE "public"."message_type" OWNER TO "postgres";


COMMENT ON TYPE "public"."message_type" IS 'type of message';



CREATE TYPE "public"."messageurgency" AS ENUM (
    'normal',
    'important',
    'urgent',
    'emergency'
);


ALTER TYPE "public"."messageurgency" OWNER TO "postgres";


CREATE TYPE "public"."operational_status" AS ENUM (
    'emergency',
    'test',
    'normal'
);


ALTER TYPE "public"."operational_status" OWNER TO "postgres";


CREATE TYPE "public"."priority" AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH'
);


ALTER TYPE "public"."priority" OWNER TO "postgres";


CREATE TYPE "public"."request_scope" AS ENUM (
    'nearby',
    'neighbors'
);


ALTER TYPE "public"."request_scope" OWNER TO "postgres";


COMMENT ON TYPE "public"."request_scope" IS 'ask based on current location or nearest households for a given request';



CREATE TYPE "public"."reservation_status" AS ENUM (
    'pending',
    'accepted',
    'rejected',
    'released',
    'expired'
);


ALTER TYPE "public"."reservation_status" OWNER TO "postgres";


CREATE TYPE "public"."sharing_scopes" AS ENUM (
    'cluster',
    'neighborhood',
    'everyone'
);


ALTER TYPE "public"."sharing_scopes" OWNER TO "postgres";


COMMENT ON TYPE "public"."sharing_scopes" IS 'scopes for sharing resources';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."user_resources" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid",
    "resource_id" "uuid",
    "quantity" integer,
    "notes" character varying,
    "created_at" timestamp without time zone NOT NULL,
    "updated_at" timestamp without time zone NOT NULL,
    "sharing_scope" "public"."sharing_scopes" DEFAULT 'cluster'::"public"."sharing_scopes" NOT NULL,
    "sharing_scope_emergency" "public"."sharing_scopes" DEFAULT 'neighborhood'::"public"."sharing_scopes" NOT NULL
);


ALTER TABLE "public"."user_resources" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_resources"."sharing_scope" IS 'sharing scope of resource during normal times';



COMMENT ON COLUMN "public"."user_resources"."sharing_scope_emergency" IS 'sharing scope for resource during emergency';



CREATE OR REPLACE FUNCTION "public"."add_user_resource"("p_user_id" "uuid", "p_resource_id" "uuid", "p_quantity" integer, "p_notes" character varying DEFAULT NULL::character varying, "p_sharing_scope" "public"."sharing_scopes" DEFAULT 'cluster'::"public"."sharing_scopes", "p_sharing_scope_emergency" "public"."sharing_scopes" DEFAULT 'neighborhood'::"public"."sharing_scopes") RETURNS "public"."user_resources"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions'
    AS $$declare
  v_row public.user_resources;
begin
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than 0';
  end if;
  insert into public.user_resources (
    id,
    user_id,
    resource_id,
    quantity,
    notes,
    created_at,
    updated_at,
    sharing_scope,
    sharing_scope_emergency
  )
  values (
    extensions.gen_random_uuid(),
    p_user_id,
    p_resource_id,
    p_quantity,
    p_notes,
    now(),
    now(),
    p_sharing_scope,
    p_sharing_scope_emergency
  )
  on conflict (user_id, resource_id, sharing_scope, sharing_scope_emergency)
  do update
  set
    quantity = public.user_resources.quantity + excluded.quantity,
    notes = coalesce(excluded.notes, public.user_resources.notes),
    updated_at = now()
  returning * into v_row;

  return v_row;
end;$$;


ALTER FUNCTION "public"."add_user_resource"("p_user_id" "uuid", "p_resource_id" "uuid", "p_quantity" integer, "p_notes" character varying, "p_sharing_scope" "public"."sharing_scopes", "p_sharing_scope_emergency" "public"."sharing_scopes") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."authorize"("requested_permission" "public"."app_permissions") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
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
  $$;


ALTER FUNCTION "public"."authorize"("requested_permission" "public"."app_permissions") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."custom_access_token"("event" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
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


ALTER FUNCTION "public"."custom_access_token"("event" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_checklist_step_cascade"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
  BEGIN
      DELETE FROM checklist_steps_states
      WHERE checklist_steps_order_id IN (
          SELECT id
          FROM checklist_steps_orders
          WHERE checklist_step_id = OLD.id
      );

      DELETE FROM checklist_steps_orders
      WHERE checklist_step_id = OLD.id;

      RETURN OLD;
  END;
  $$;


ALTER FUNCTION "public"."delete_checklist_step_cascade"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_direct_group_between_profiles"("p_profile_a" "uuid", "p_profile_b" "uuid") RETURNS "uuid"
    LANGUAGE "sql"
    AS $$
  select gm.group_id
  from group_members gm
  group by gm.group_id
  having
    count(*) = 2
    and count(*) filter (where gm.profile_id = p_profile_a) = 1
    and count(*) filter (where gm.profile_id = p_profile_b) = 1
  limit 1;
$$;


ALTER FUNCTION "public"."find_direct_group_between_profiles"("p_profile_a" "uuid", "p_profile_b" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_nearest_resource_suppliers_by_current_location"("p_requester_profile_id" "uuid", "p_resource_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) RETURNS TABLE("profile_id" "uuid", "people_id" "uuid", "household_id" "uuid", "user_resource_id" "uuid", "available_quantity" bigint, "distance_meters" double precision)
    LANGUAGE "sql"
    SET "search_path" TO 'public', 'extensions'
    AS $$
with origin as (
  select extensions.ST_SetSRID(
    extensions.ST_MakePoint(
      p_longitude::float8,
      p_latitude::float8
    ),
    4326
  ) as geom
),
active_reservations as (
  select
    rr.user_resource_id,
    sum(rr.quantity) as reserved_quantity
  from public.resource_reservations rr
  where rr.status in ('pending', 'accepted')
  group by rr.user_resource_id
)
select
  candidate_up.id as profile_id,
  candidate_p.id as people_id,
  candidate_pg.household_id,
  ur.id as user_resource_id,
  (ur.quantity - coalesce(ar.reserved_quantity, 0))::bigint as available_quantity,
  extensions.ST_Distance(
    candidate_h.geom::extensions.geography,
    o.geom::extensions.geography
  ) as distance_meters
from public.user_resources ur
join public.user_profiles candidate_up
  on candidate_up.id = ur.user_id
join public.people candidate_p
  on candidate_p.user_profile_id = candidate_up.id
join public.people_groups candidate_pg
  on candidate_pg.people_id = candidate_p.id
join public.households candidate_h
  on candidate_h.id = candidate_pg.household_id
left join active_reservations ar
  on ar.user_resource_id = ur.id
cross join origin o
where ur.resource_id = p_resource_id
  and (ur.quantity - coalesce(ar.reserved_quantity, 0)) > 0
  and candidate_up.id <> p_requester_profile_id
  and candidate_h.geom is not null
order by candidate_h.geom <-> o.geom;
$$;


ALTER FUNCTION "public"."get_nearest_resource_suppliers_by_current_location"("p_requester_profile_id" "uuid", "p_resource_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_nearest_resource_suppliers_by_household"("p_requester_profile_id" "uuid", "p_resource_id" "uuid") RETURNS TABLE("profile_id" "uuid", "people_id" "uuid", "household_id" "uuid", "user_resource_id" "uuid", "available_quantity" integer, "distance_meters" double precision)
    LANGUAGE "sql"
    SET "search_path" TO 'public', 'extensions'
    AS $$
  with requester as (
    select
      up.id as profile_id,
      p.id as people_id,
      pg.household_id,
      h.geom
    from user_profiles up
    join people p
      on p.user_profile_id = up.id
    join people_groups pg
      on pg.people_id = p.id
    join households h
      on h.id = pg.household_id
    where up.id = p_requester_profile_id
  ),
  active_reservations as (
    select
      rr.user_resource_id,
      sum(rr.quantity)::integer as reserved_quantity
    from public.resource_reservations rr
    where rr.status in ('pending', 'accepted')
    group by rr.user_resource_id
  )
  select
    candidate_up.id as profile_id,
    candidate_p.id as people_id,
    candidate_pg.household_id,
    ur.id as user_resource_id,
    (ur.quantity - coalesce(ar.reserved_quantity, 0))::integer as available_quantity,
    ST_Distance(candidate_h.geom::geography, rq.geom::geography) as distance_meters
  from user_resources ur
  join user_profiles candidate_up
    on candidate_up.id = ur.user_id
  join people candidate_p
    on candidate_p.user_profile_id = candidate_up.id
  join people_groups candidate_pg
    on candidate_pg.people_id = candidate_p.id
  join households candidate_h
    on candidate_h.id = candidate_pg.household_id
  left join active_reservations ar
    on ar.user_resource_id = ur.id
  cross join requester rq
  where ur.resource_id = p_resource_id
    and (ur.quantity - coalesce(ar.reserved_quantity, 0)) > 0
    and candidate_up.id <> p_requester_profile_id
    and candidate_pg.household_id <> rq.household_id
    and candidate_h.geom is not null
    and rq.geom is not null
  order by candidate_h.geom <-> rq.geom;
$$;


ALTER FUNCTION "public"."get_nearest_resource_suppliers_by_household"("p_requester_profile_id" "uuid", "p_resource_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_group_name"("p_base_name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $_$declare
  v_name text;
  v_max_suffix int;
begin
  if not exists (
    select 1
    from groups
    where name = p_base_name
  ) then
    return p_base_name;
  end if;

  select coalesce(
    max(
      nullif(
        substring(name from '\((\d+)\)$'),
        ''
      )::int
    ),
    0
  )
  into v_max_suffix
  from groups
  where name = p_base_name
     or name ~ ('^' || regexp_replace(p_base_name, '([.[\]{}()*+?^$|\\-])', '\\\1', 'g') || ' \(\d+\)$');

  return p_base_name || ' (' || (v_max_suffix + 1) || ')';
end;$_$;


ALTER FUNCTION "public"."get_next_group_name"("p_base_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_checklist_steps_state_for_all_users"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
      user_record RECORD;
  BEGIN
      -- Loop through each user in the user_profiles table
      FOR user_record IN SELECT id FROM public.user_profiles LOOP
          -- Insert a new row into checklist_steps_states for each user
          INSERT INTO public.checklist_steps_states (id, checklist_steps_order_id, user_profile_id, is_completed)
          VALUES (gen_random_uuid(), NEW.id, user_record.id, FALSE);
      END LOOP;

      RETURN NEW;
  END;
  $$;


ALTER FUNCTION "public"."insert_checklist_steps_state_for_all_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_user_checklists_for_all_users"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
      user_record RECORD;
  BEGIN
      -- Loop through each user in the user_profiles table
      FOR user_record IN SELECT id FROM public.user_profiles LOOP
          -- Insert a new row into user_checklists for each user
          INSERT INTO public.user_checklists (id, checklist_id, user_profile_id)
          VALUES (gen_random_uuid(), NEW.id, user_record.id);
      END LOOP;

      RETURN NEW;
  END;
  $$;


ALTER FUNCTION "public"."insert_user_checklists_for_all_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."invalidate_signup_code"("input_code" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    new_code TEXT;
BEGIN
    -- Generate new code using first 7 characters of UUID hex, capitalized
    new_code := UPPER(LEFT(REPLACE(gen_random_uuid()::TEXT, '-', ''), 7));

    -- Update signup_codes table with the new code
    UPDATE signup_codes
    SET code = new_code
    WHERE code = input_code;

    -- Return the newly generated code
    RETURN new_code;
END;
$$;


ALTER FUNCTION "public"."invalidate_signup_code"("input_code" "text") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "resource_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quantity" integer DEFAULT 0 NOT NULL,
    "notes" "text",
    "request_scope" "public"."request_scope" DEFAULT 'neighbors'::"public"."request_scope" NOT NULL,
    "requester_profile_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "expires_at" timestamp with time zone,
    "hours_needed" integer,
    "distance_meters" double precision,
    "supplier_profile_id" "uuid",
    "urgency" "public"."messageurgency" DEFAULT 'normal'::"public"."messageurgency" NOT NULL
);


ALTER TABLE "public"."requests" OWNER TO "postgres";


COMMENT ON COLUMN "public"."requests"."requester_profile_id" IS 'user who requested';



CREATE OR REPLACE FUNCTION "public"."reserve_request_candidate"("p_resource_id" "uuid", "p_quantity" integer, "p_request_scope" "public"."request_scope", "p_requester_profile_id" "uuid", "p_supplier_profile_id" "uuid", "p_user_resource_id" "uuid", "p_notes" "text" DEFAULT NULL::"text", "p_distance_meters" double precision DEFAULT NULL::double precision) RETURNS "public"."requests"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public', 'extensions'
    AS $$
declare
  v_request public.requests;
  v_user_resource public.user_resources;
  v_reserved_quantity integer;
  v_available_quantity integer;
begin
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than 0';
  end if;

  perform pg_advisory_xact_lock(
    ('x' || substr(md5('user_resource_reservation:' || p_user_resource_id::text), 1, 16))::bit(64)::bigint
  );

  select *
  into v_user_resource
  from public.user_resources ur
  where ur.id = p_user_resource_id
    and ur.resource_id = p_resource_id
    and ur.user_id = p_supplier_profile_id
  for update;

  if not found then
    raise exception 'Selected user_resource row not found for supplier/resource';
  end if;

  select coalesce(sum(rr.quantity), 0)::integer
  into v_reserved_quantity
  from public.resource_reservations rr
  where rr.user_resource_id = p_user_resource_id
    and rr.status in ('pending', 'accepted');

  v_available_quantity := coalesce(v_user_resource.quantity, 0) - v_reserved_quantity;

  if v_available_quantity <= 0 then
    raise exception 'No available inventory remains for this candidate row';
  end if;

  if p_quantity > v_available_quantity then
    raise exception
      'Requested quantity % exceeds available quantity % for this candidate row',
      p_quantity, v_available_quantity;
  end if;

  insert into public.requests (
    resource_id,
    quantity,
    notes,
    request_scope,
    requester_profile_id,
    supplier_profile_id,
    distance_meters
  )
  values (
    p_resource_id,
    p_quantity,
    p_notes,
    p_request_scope,
    p_requester_profile_id,
    p_supplier_profile_id,
    p_distance_meters
  )
  returning * into v_request;

  insert into public.resource_reservations (
    id,
    user_resource_id,
    request_id,
    requester_profile_id,
    quantity,
    status,
    created_at,
    updated_at
  )
  values (
    extensions.gen_random_uuid(),
    p_user_resource_id,
    v_request.id,
    p_requester_profile_id,
    p_quantity,
    'pending',
    now(),
    now()
  );

  return v_request;
end;
$$;


ALTER FUNCTION "public"."reserve_request_candidate"("p_resource_id" "uuid", "p_quantity" integer, "p_request_scope" "public"."request_scope", "p_requester_profile_id" "uuid", "p_supplier_profile_id" "uuid", "p_user_resource_id" "uuid", "p_notes" "text", "p_distance_meters" double precision) OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."checklist_steps" (
    "id" "uuid" NOT NULL,
    "label" character varying NOT NULL,
    "description" character varying,
    "updated_at" timestamp without time zone NOT NULL
);


ALTER TABLE "public"."checklist_steps" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."checklist_steps_orders" (
    "id" "uuid" NOT NULL,
    "checklist_id" "uuid" NOT NULL,
    "checklist_step_id" "uuid" NOT NULL,
    "priority" integer NOT NULL,
    "updated_at" timestamp without time zone NOT NULL
);


ALTER TABLE "public"."checklist_steps_orders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."checklist_steps_states" (
    "id" "uuid" NOT NULL,
    "checklist_steps_order_id" "uuid" NOT NULL,
    "user_profile_id" "uuid" NOT NULL,
    "is_completed" boolean NOT NULL
);


ALTER TABLE "public"."checklist_steps_states" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."checklists" (
    "id" "uuid" NOT NULL,
    "title" character varying NOT NULL,
    "description" character varying,
    "notes" character varying,
    "updated_at" timestamp without time zone NOT NULL,
    "priority" "public"."priority" NOT NULL,
    "frequency_id" "uuid"
);


ALTER TABLE "public"."checklists" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."clusters" (
    "id" "uuid" NOT NULL,
    "name" character varying,
    "meeting_place" character varying,
    "meeting_point" "extensions"."geometry"(Point),
    "notes" character varying,
    "geom" "extensions"."geometry"(Polygon)
);


ALTER TABLE "public"."clusters" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."frequency" (
    "id" "uuid" NOT NULL,
    "name" character varying NOT NULL,
    "num_days" integer NOT NULL
);


ALTER TABLE "public"."frequency" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."group_members" (
    "group_id" "uuid" NOT NULL,
    "profile_id" "uuid" NOT NULL
);


ALTER TABLE "public"."group_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."groups" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_by_id" "uuid" NOT NULL,
    "name" character varying NOT NULL,
    "description" character varying,
    "type" "public"."group_chat_type" DEFAULT 'chat'::"public"."group_chat_type" NOT NULL
);


ALTER TABLE "public"."groups" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."households" (
    "id" "uuid" NOT NULL,
    "cluster_id" "uuid" NOT NULL,
    "name" character varying,
    "address" character varying,
    "notes" character varying,
    "pets" character varying,
    "accessibility_needs" character varying,
    "geom" "extensions"."geometry"(Point),
    CONSTRAINT "households_geom_srid_check" CHECK ((("geom" IS NULL) OR ("extensions"."st_srid"("geom") = 4326)))
);


ALTER TABLE "public"."households" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" NOT NULL,
    "from_id" "uuid",
    "to_id" "uuid",
    "urgency" "public"."messageurgency",
    "content" character varying NOT NULL,
    "sent_on" timestamp without time zone NOT NULL,
    "message_type" "public"."message_type" DEFAULT 'text'::"public"."message_type" NOT NULL,
    "metadata" "jsonb",
    "request_id" "uuid"
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


COMMENT ON COLUMN "public"."messages"."message_type" IS 'currently text or resource_request';



COMMENT ON COLUMN "public"."messages"."metadata" IS 'if message is a request, carries request info in json';



CREATE TABLE IF NOT EXISTS "public"."operational_events" (
    "id" "uuid" NOT NULL,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp without time zone NOT NULL,
    "status" "public"."operational_status" NOT NULL
);


ALTER TABLE "public"."operational_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."people" (
    "id" "uuid" NOT NULL,
    "user_profile_id" "uuid",
    "given_name" character varying,
    "family_name" character varying,
    "nickname" character varying,
    "is_safe" boolean NOT NULL,
    "needs_help" boolean NOT NULL
);


ALTER TABLE "public"."people" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."people_groups" (
    "people_id" "uuid" NOT NULL,
    "household_id" "uuid",
    "notes" character varying
);


ALTER TABLE "public"."people_groups" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."point_of_interest_types" (
    "name" character varying NOT NULL,
    "icon" character varying NOT NULL
);


ALTER TABLE "public"."point_of_interest_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."point_of_interests" (
    "id" "uuid" NOT NULL,
    "name" character varying NOT NULL,
    "address" character varying NOT NULL,
    "geom" "extensions"."geometry"(Point),
    "point_type_name" character varying NOT NULL
);


ALTER TABLE "public"."point_of_interests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resource_reservations" (
    "id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "user_resource_id" "uuid" NOT NULL,
    "request_id" "uuid" NOT NULL,
    "quantity" integer NOT NULL,
    "status" "public"."reservation_status" DEFAULT 'pending'::"public"."reservation_status" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp without time zone,
    "requester_profile_id" "uuid" NOT NULL,
    CONSTRAINT "resource_reservations_quantity_positive" CHECK (("quantity" > 0))
);


ALTER TABLE "public"."resource_reservations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resource_subtype_tags" (
    "id" "uuid" NOT NULL,
    "name" character varying NOT NULL
);


ALTER TABLE "public"."resource_subtype_tags" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resource_tags" (
    "resource_id" "uuid" NOT NULL,
    "resource_subtype_tag_id" "uuid"
);


ALTER TABLE "public"."resource_tags" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resource_types" (
    "id" "uuid" NOT NULL,
    "name" character varying NOT NULL,
    "description" character varying
);


ALTER TABLE "public"."resource_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resources" (
    "resource_cv_id" "uuid" NOT NULL,
    "resource_type_id" "uuid" NOT NULL,
    "notes" character varying,
    "qty_needed" integer NOT NULL,
    "qty_available" integer NOT NULL
);


ALTER TABLE "public"."resources" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resources_cv" (
    "id" "uuid" NOT NULL,
    "name" character varying NOT NULL,
    "description" character varying
);


ALTER TABLE "public"."resources_cv" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "id" "uuid" NOT NULL,
    "role" "public"."app_roles" NOT NULL,
    "permission" "public"."app_permissions" NOT NULL
);


ALTER TABLE "public"."role_permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."signup_codes" (
    "code" character varying(7) NOT NULL,
    "household_id" "uuid" NOT NULL
);


ALTER TABLE "public"."signup_codes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_captain_clusters" (
    "id" "uuid" NOT NULL,
    "cluster_id" "uuid" NOT NULL,
    "user_role_id" "uuid" NOT NULL
);


ALTER TABLE "public"."user_captain_clusters" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_checklists" (
    "id" "uuid" NOT NULL,
    "checklist_id" "uuid" NOT NULL,
    "user_profile_id" "uuid" NOT NULL,
    "completed_at" timestamp without time zone
);


ALTER TABLE "public"."user_checklists" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profiles" (
    "id" "uuid" NOT NULL
);


ALTER TABLE "public"."user_profiles" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."user_resources_view" AS
 WITH "urs" AS (
         SELECT "ur"."id",
            "ur"."user_id",
            "ur"."quantity",
            "ur"."notes",
            "ur"."created_at",
            "ur"."updated_at",
            "r"."resource_cv_id" AS "rc_id",
            "r"."resource_type_id" AS "rt_id"
           FROM ("public"."user_resources" "ur"
             JOIN "public"."resources" "r" ON (("r"."resource_cv_id" = "ur"."resource_id")))
        )
 SELECT "urs"."id",
    "urs"."user_id",
    "urs"."quantity",
    "urs"."notes",
    "urs"."created_at",
    "urs"."updated_at",
    "rc"."id" AS "rc_id",
    "rc"."name" AS "rc_name",
    "rc"."description" AS "rc_desc",
    "rt"."id" AS "rt_id",
    "rt"."name" AS "rt_name",
    "rt"."description" AS "rt_desc"
   FROM "public"."resources_cv" "rc",
    "public"."resource_types" "rt",
    "urs"
  WHERE (("rc"."id" = "urs"."rc_id") AND ("rt"."id" = "urs"."rt_id"));


ALTER VIEW "public"."user_resources_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "id" "uuid" NOT NULL,
    "user_profile_id" "uuid" NOT NULL,
    "role" "public"."app_roles" NOT NULL
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."checklist_steps_orders"
    ADD CONSTRAINT "checklist_steps_orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."checklist_steps"
    ADD CONSTRAINT "checklist_steps_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."checklist_steps_states"
    ADD CONSTRAINT "checklist_steps_states_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."checklists"
    ADD CONSTRAINT "checklists_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."clusters"
    ADD CONSTRAINT "clusters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."frequency"
    ADD CONSTRAINT "frequency_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_pkey" PRIMARY KEY ("group_id", "profile_id");



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."households"
    ADD CONSTRAINT "households_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."operational_events"
    ADD CONSTRAINT "operational_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."people_groups"
    ADD CONSTRAINT "people_groups_pkey" PRIMARY KEY ("people_id");



ALTER TABLE ONLY "public"."people"
    ADD CONSTRAINT "people_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."people"
    ADD CONSTRAINT "people_user_profile_id_key" UNIQUE ("user_profile_id");



ALTER TABLE ONLY "public"."point_of_interest_types"
    ADD CONSTRAINT "point_of_interest_types_pkey" PRIMARY KEY ("name");



ALTER TABLE ONLY "public"."point_of_interests"
    ADD CONSTRAINT "point_of_interests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."requests"
    ADD CONSTRAINT "requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resource_reservations"
    ADD CONSTRAINT "resource_reservations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resource_subtype_tags"
    ADD CONSTRAINT "resource_subtype_tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resource_tags"
    ADD CONSTRAINT "resource_tags_pkey" PRIMARY KEY ("resource_id");



ALTER TABLE ONLY "public"."resource_types"
    ADD CONSTRAINT "resource_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resources_cv"
    ADD CONSTRAINT "resources_cv_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resources"
    ADD CONSTRAINT "resources_pkey" PRIMARY KEY ("resource_cv_id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."signup_codes"
    ADD CONSTRAINT "signup_codes_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."user_captain_clusters"
    ADD CONSTRAINT "user_captain_clusters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_checklists"
    ADD CONSTRAINT "user_checklists_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_resources"
    ADD CONSTRAINT "user_resources_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_resources"
    ADD CONSTRAINT "user_resources_unique_supply" UNIQUE ("user_id", "resource_id", "sharing_scope", "sharing_scope_emergency");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_profile_id_key" UNIQUE ("user_profile_id");



CREATE INDEX "idx_clusters_geom" ON "public"."clusters" USING "gist" ("geom");



CREATE INDEX "idx_clusters_meeting_point" ON "public"."clusters" USING "gist" ("meeting_point");



CREATE INDEX "idx_households_geom" ON "public"."households" USING "gist" ("geom");



CREATE INDEX "idx_point_of_interests_geom" ON "public"."point_of_interests" USING "gist" ("geom");



CREATE OR REPLACE TRIGGER "trigger_delete_checklist_step_cascade" BEFORE DELETE ON "public"."checklist_steps" FOR EACH ROW EXECUTE FUNCTION "public"."delete_checklist_step_cascade"();



CREATE OR REPLACE TRIGGER "trigger_insert_checklist_steps_state_for_all_users" AFTER INSERT ON "public"."checklist_steps_orders" FOR EACH ROW EXECUTE FUNCTION "public"."insert_checklist_steps_state_for_all_users"();



CREATE OR REPLACE TRIGGER "trigger_insert_user_checklists_for_all_users" AFTER INSERT ON "public"."checklists" FOR EACH ROW EXECUTE FUNCTION "public"."insert_user_checklists_for_all_users"();



ALTER TABLE ONLY "public"."checklist_steps_orders"
    ADD CONSTRAINT "checklist_steps_orders_checklist_id_fkey" FOREIGN KEY ("checklist_id") REFERENCES "public"."checklists"("id");



ALTER TABLE ONLY "public"."checklist_steps_orders"
    ADD CONSTRAINT "checklist_steps_orders_checklist_step_id_fkey" FOREIGN KEY ("checklist_step_id") REFERENCES "public"."checklist_steps"("id");



ALTER TABLE ONLY "public"."checklist_steps_states"
    ADD CONSTRAINT "checklist_steps_states_checklist_steps_order_id_fkey" FOREIGN KEY ("checklist_steps_order_id") REFERENCES "public"."checklist_steps_orders"("id");



ALTER TABLE ONLY "public"."checklist_steps_states"
    ADD CONSTRAINT "checklist_steps_states_user_profile_id_fkey" FOREIGN KEY ("user_profile_id") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."checklists"
    ADD CONSTRAINT "checklists_frequency_id_fkey" FOREIGN KEY ("frequency_id") REFERENCES "public"."frequency"("id");



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_people_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."households"
    ADD CONSTRAINT "households_cluster_id_fkey" FOREIGN KEY ("cluster_id") REFERENCES "public"."clusters"("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_from_id_fkey" FOREIGN KEY ("from_id") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_to_id_fkey" FOREIGN KEY ("to_id") REFERENCES "public"."groups"("id");



ALTER TABLE ONLY "public"."operational_events"
    ADD CONSTRAINT "operational_events_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."people_groups"
    ADD CONSTRAINT "people_groups_household_id_fkey" FOREIGN KEY ("household_id") REFERENCES "public"."households"("id");



ALTER TABLE ONLY "public"."people_groups"
    ADD CONSTRAINT "people_groups_people_id_fkey" FOREIGN KEY ("people_id") REFERENCES "public"."people"("id");



ALTER TABLE ONLY "public"."people"
    ADD CONSTRAINT "people_user_profile_id_fkey" FOREIGN KEY ("user_profile_id") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."point_of_interests"
    ADD CONSTRAINT "point_of_interests_point_type_name_fkey" FOREIGN KEY ("point_type_name") REFERENCES "public"."point_of_interest_types"("name");



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "public_group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "public_messages_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "public"."requests"("id");



ALTER TABLE ONLY "public"."requests"
    ADD CONSTRAINT "public_requests_requester_profile_id_fkey" FOREIGN KEY ("requester_profile_id") REFERENCES "public"."user_profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."requests"
    ADD CONSTRAINT "public_requests_resource_id_fkey" FOREIGN KEY ("resource_id") REFERENCES "public"."resources"("resource_cv_id");



ALTER TABLE ONLY "public"."requests"
    ADD CONSTRAINT "public_requests_supplier_profile_id_fkey" FOREIGN KEY ("supplier_profile_id") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."resource_reservations"
    ADD CONSTRAINT "public_resource_reservations_requester_profile_id_fkey" FOREIGN KEY ("requester_profile_id") REFERENCES "public"."user_profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."resource_reservations"
    ADD CONSTRAINT "resource_reservations_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "public"."requests"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."resource_reservations"
    ADD CONSTRAINT "resource_reservations_user_resource_id_fkey" FOREIGN KEY ("user_resource_id") REFERENCES "public"."user_resources"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."resource_tags"
    ADD CONSTRAINT "resource_tags_resource_id_fkey" FOREIGN KEY ("resource_id") REFERENCES "public"."resources"("resource_cv_id");



ALTER TABLE ONLY "public"."resource_tags"
    ADD CONSTRAINT "resource_tags_resource_subtype_tag_id_fkey" FOREIGN KEY ("resource_subtype_tag_id") REFERENCES "public"."resource_subtype_tags"("id");



ALTER TABLE ONLY "public"."resources"
    ADD CONSTRAINT "resources_resource_cv_id_fkey" FOREIGN KEY ("resource_cv_id") REFERENCES "public"."resources_cv"("id");



ALTER TABLE ONLY "public"."resources"
    ADD CONSTRAINT "resources_resource_type_id_fkey" FOREIGN KEY ("resource_type_id") REFERENCES "public"."resource_types"("id");



ALTER TABLE ONLY "public"."signup_codes"
    ADD CONSTRAINT "signup_codes_household_id_fkey" FOREIGN KEY ("household_id") REFERENCES "public"."households"("id");



ALTER TABLE ONLY "public"."user_captain_clusters"
    ADD CONSTRAINT "user_captain_clusters_cluster_id_fkey" FOREIGN KEY ("cluster_id") REFERENCES "public"."clusters"("id");



ALTER TABLE ONLY "public"."user_captain_clusters"
    ADD CONSTRAINT "user_captain_clusters_user_role_id_fkey" FOREIGN KEY ("user_role_id") REFERENCES "public"."user_roles"("id");



ALTER TABLE ONLY "public"."user_checklists"
    ADD CONSTRAINT "user_checklists_checklist_id_fkey" FOREIGN KEY ("checklist_id") REFERENCES "public"."checklists"("id");



ALTER TABLE ONLY "public"."user_checklists"
    ADD CONSTRAINT "user_checklists_user_profile_id_fkey" FOREIGN KEY ("user_profile_id") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."user_resources"
    ADD CONSTRAINT "user_resources_resource_id_fkey" FOREIGN KEY ("resource_id") REFERENCES "public"."resources"("resource_cv_id");



ALTER TABLE ONLY "public"."user_resources"
    ADD CONSTRAINT "user_resources_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profiles"("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_profile_id_fkey" FOREIGN KEY ("user_profile_id") REFERENCES "public"."user_profiles"("id");



CREATE POLICY "Allow authorized INSERT access" ON "public"."operational_events" FOR INSERT WITH CHECK ("public"."authorize"('OPERATIONAL_EVENT_CREATE'::"public"."app_permissions"));



CREATE POLICY "Allow authorized SELECT access" ON "public"."operational_events" FOR SELECT USING (( SELECT "public"."authorize"('OPERATIONAL_EVENT_READ'::"public"."app_permissions") AS "authorize"));



CREATE POLICY "Allow authorized UPDATE access" ON "public"."operational_events" FOR UPDATE USING (( SELECT "public"."authorize"('OPERATIONAL_EVENT_CREATE'::"public"."app_permissions") AS "authorize"));



ALTER TABLE "public"."operational_events" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT USAGE ON SCHEMA "public" TO "supabase_auth_admin";





















































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































GRANT ALL ON TABLE "public"."user_resources" TO "anon";
GRANT ALL ON TABLE "public"."user_resources" TO "authenticated";
GRANT ALL ON TABLE "public"."user_resources" TO "service_role";



GRANT ALL ON FUNCTION "public"."add_user_resource"("p_user_id" "uuid", "p_resource_id" "uuid", "p_quantity" integer, "p_notes" character varying, "p_sharing_scope" "public"."sharing_scopes", "p_sharing_scope_emergency" "public"."sharing_scopes") TO "postgres";
GRANT ALL ON FUNCTION "public"."add_user_resource"("p_user_id" "uuid", "p_resource_id" "uuid", "p_quantity" integer, "p_notes" character varying, "p_sharing_scope" "public"."sharing_scopes", "p_sharing_scope_emergency" "public"."sharing_scopes") TO "anon";
GRANT ALL ON FUNCTION "public"."add_user_resource"("p_user_id" "uuid", "p_resource_id" "uuid", "p_quantity" integer, "p_notes" character varying, "p_sharing_scope" "public"."sharing_scopes", "p_sharing_scope_emergency" "public"."sharing_scopes") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_user_resource"("p_user_id" "uuid", "p_resource_id" "uuid", "p_quantity" integer, "p_notes" character varying, "p_sharing_scope" "public"."sharing_scopes", "p_sharing_scope_emergency" "public"."sharing_scopes") TO "service_role";



GRANT ALL ON FUNCTION "public"."authorize"("requested_permission" "public"."app_permissions") TO "anon";
GRANT ALL ON FUNCTION "public"."authorize"("requested_permission" "public"."app_permissions") TO "authenticated";
GRANT ALL ON FUNCTION "public"."authorize"("requested_permission" "public"."app_permissions") TO "service_role";



REVOKE ALL ON FUNCTION "public"."custom_access_token"("event" "jsonb") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."custom_access_token"("event" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."custom_access_token"("event" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."custom_access_token"("event" "jsonb") TO "service_role";
GRANT ALL ON FUNCTION "public"."custom_access_token"("event" "jsonb") TO "supabase_auth_admin";



GRANT ALL ON FUNCTION "public"."delete_checklist_step_cascade"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_checklist_step_cascade"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_checklist_step_cascade"() TO "service_role";



GRANT ALL ON FUNCTION "public"."find_direct_group_between_profiles"("p_profile_a" "uuid", "p_profile_b" "uuid") TO "postgres";
GRANT ALL ON FUNCTION "public"."find_direct_group_between_profiles"("p_profile_a" "uuid", "p_profile_b" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."find_direct_group_between_profiles"("p_profile_a" "uuid", "p_profile_b" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_direct_group_between_profiles"("p_profile_a" "uuid", "p_profile_b" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_nearest_resource_suppliers_by_current_location"("p_requester_profile_id" "uuid", "p_resource_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."get_nearest_resource_suppliers_by_current_location"("p_requester_profile_id" "uuid", "p_resource_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."get_nearest_resource_suppliers_by_current_location"("p_requester_profile_id" "uuid", "p_resource_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_nearest_resource_suppliers_by_current_location"("p_requester_profile_id" "uuid", "p_resource_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_nearest_resource_suppliers_by_household"("p_requester_profile_id" "uuid", "p_resource_id" "uuid") TO "postgres";
GRANT ALL ON FUNCTION "public"."get_nearest_resource_suppliers_by_household"("p_requester_profile_id" "uuid", "p_resource_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_nearest_resource_suppliers_by_household"("p_requester_profile_id" "uuid", "p_resource_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_nearest_resource_suppliers_by_household"("p_requester_profile_id" "uuid", "p_resource_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_group_name"("p_base_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."get_next_group_name"("p_base_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_group_name"("p_base_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_group_name"("p_base_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_checklist_steps_state_for_all_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."insert_checklist_steps_state_for_all_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_checklist_steps_state_for_all_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_user_checklists_for_all_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."insert_user_checklists_for_all_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_user_checklists_for_all_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."invalidate_signup_code"("input_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."invalidate_signup_code"("input_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."invalidate_signup_code"("input_code" "text") TO "service_role";



GRANT ALL ON TABLE "public"."requests" TO "anon";
GRANT ALL ON TABLE "public"."requests" TO "authenticated";
GRANT ALL ON TABLE "public"."requests" TO "service_role";



GRANT ALL ON FUNCTION "public"."reserve_request_candidate"("p_resource_id" "uuid", "p_quantity" integer, "p_request_scope" "public"."request_scope", "p_requester_profile_id" "uuid", "p_supplier_profile_id" "uuid", "p_user_resource_id" "uuid", "p_notes" "text", "p_distance_meters" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."reserve_request_candidate"("p_resource_id" "uuid", "p_quantity" integer, "p_request_scope" "public"."request_scope", "p_requester_profile_id" "uuid", "p_supplier_profile_id" "uuid", "p_user_resource_id" "uuid", "p_notes" "text", "p_distance_meters" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."reserve_request_candidate"("p_resource_id" "uuid", "p_quantity" integer, "p_request_scope" "public"."request_scope", "p_requester_profile_id" "uuid", "p_supplier_profile_id" "uuid", "p_user_resource_id" "uuid", "p_notes" "text", "p_distance_meters" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."reserve_request_candidate"("p_resource_id" "uuid", "p_quantity" integer, "p_request_scope" "public"."request_scope", "p_requester_profile_id" "uuid", "p_supplier_profile_id" "uuid", "p_user_resource_id" "uuid", "p_notes" "text", "p_distance_meters" double precision) TO "service_role";

















































































GRANT ALL ON TABLE "public"."checklist_steps" TO "anon";
GRANT ALL ON TABLE "public"."checklist_steps" TO "authenticated";
GRANT ALL ON TABLE "public"."checklist_steps" TO "service_role";



GRANT ALL ON TABLE "public"."checklist_steps_orders" TO "anon";
GRANT ALL ON TABLE "public"."checklist_steps_orders" TO "authenticated";
GRANT ALL ON TABLE "public"."checklist_steps_orders" TO "service_role";



GRANT ALL ON TABLE "public"."checklist_steps_states" TO "anon";
GRANT ALL ON TABLE "public"."checklist_steps_states" TO "authenticated";
GRANT ALL ON TABLE "public"."checklist_steps_states" TO "service_role";



GRANT ALL ON TABLE "public"."checklists" TO "anon";
GRANT ALL ON TABLE "public"."checklists" TO "authenticated";
GRANT ALL ON TABLE "public"."checklists" TO "service_role";



GRANT ALL ON TABLE "public"."clusters" TO "anon";
GRANT ALL ON TABLE "public"."clusters" TO "authenticated";
GRANT ALL ON TABLE "public"."clusters" TO "service_role";



GRANT ALL ON TABLE "public"."frequency" TO "anon";
GRANT ALL ON TABLE "public"."frequency" TO "authenticated";
GRANT ALL ON TABLE "public"."frequency" TO "service_role";



GRANT ALL ON TABLE "public"."group_members" TO "anon";
GRANT ALL ON TABLE "public"."group_members" TO "authenticated";
GRANT ALL ON TABLE "public"."group_members" TO "service_role";



GRANT ALL ON TABLE "public"."groups" TO "anon";
GRANT ALL ON TABLE "public"."groups" TO "authenticated";
GRANT ALL ON TABLE "public"."groups" TO "service_role";



GRANT ALL ON TABLE "public"."households" TO "anon";
GRANT ALL ON TABLE "public"."households" TO "authenticated";
GRANT ALL ON TABLE "public"."households" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON TABLE "public"."operational_events" TO "anon";
GRANT ALL ON TABLE "public"."operational_events" TO "authenticated";
GRANT ALL ON TABLE "public"."operational_events" TO "service_role";



GRANT ALL ON TABLE "public"."people" TO "anon";
GRANT ALL ON TABLE "public"."people" TO "authenticated";
GRANT ALL ON TABLE "public"."people" TO "service_role";



GRANT ALL ON TABLE "public"."people_groups" TO "anon";
GRANT ALL ON TABLE "public"."people_groups" TO "authenticated";
GRANT ALL ON TABLE "public"."people_groups" TO "service_role";



GRANT ALL ON TABLE "public"."point_of_interest_types" TO "anon";
GRANT ALL ON TABLE "public"."point_of_interest_types" TO "authenticated";
GRANT ALL ON TABLE "public"."point_of_interest_types" TO "service_role";



GRANT ALL ON TABLE "public"."point_of_interests" TO "anon";
GRANT ALL ON TABLE "public"."point_of_interests" TO "authenticated";
GRANT ALL ON TABLE "public"."point_of_interests" TO "service_role";



GRANT ALL ON TABLE "public"."resource_reservations" TO "postgres";
GRANT ALL ON TABLE "public"."resource_reservations" TO "anon";
GRANT ALL ON TABLE "public"."resource_reservations" TO "authenticated";
GRANT ALL ON TABLE "public"."resource_reservations" TO "service_role";



GRANT ALL ON TABLE "public"."resource_subtype_tags" TO "anon";
GRANT ALL ON TABLE "public"."resource_subtype_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."resource_subtype_tags" TO "service_role";



GRANT ALL ON TABLE "public"."resource_tags" TO "anon";
GRANT ALL ON TABLE "public"."resource_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."resource_tags" TO "service_role";



GRANT ALL ON TABLE "public"."resource_types" TO "anon";
GRANT ALL ON TABLE "public"."resource_types" TO "authenticated";
GRANT ALL ON TABLE "public"."resource_types" TO "service_role";



GRANT ALL ON TABLE "public"."resources" TO "anon";
GRANT ALL ON TABLE "public"."resources" TO "authenticated";
GRANT ALL ON TABLE "public"."resources" TO "service_role";



GRANT ALL ON TABLE "public"."resources_cv" TO "anon";
GRANT ALL ON TABLE "public"."resources_cv" TO "authenticated";
GRANT ALL ON TABLE "public"."resources_cv" TO "service_role";



GRANT ALL ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."signup_codes" TO "anon";
GRANT ALL ON TABLE "public"."signup_codes" TO "authenticated";
GRANT ALL ON TABLE "public"."signup_codes" TO "service_role";



GRANT ALL ON TABLE "public"."user_captain_clusters" TO "anon";
GRANT ALL ON TABLE "public"."user_captain_clusters" TO "authenticated";
GRANT ALL ON TABLE "public"."user_captain_clusters" TO "service_role";



GRANT ALL ON TABLE "public"."user_checklists" TO "anon";
GRANT ALL ON TABLE "public"."user_checklists" TO "authenticated";
GRANT ALL ON TABLE "public"."user_checklists" TO "service_role";



GRANT ALL ON TABLE "public"."user_profiles" TO "anon";
GRANT ALL ON TABLE "public"."user_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."user_resources_view" TO "postgres";
GRANT ALL ON TABLE "public"."user_resources_view" TO "anon";
GRANT ALL ON TABLE "public"."user_resources_view" TO "authenticated";
GRANT ALL ON TABLE "public"."user_resources_view" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";
GRANT ALL ON TABLE "public"."user_roles" TO "supabase_auth_admin";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";
