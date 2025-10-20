create extension if not exists "postgis" with schema "extensions";


create type "public"."app_permissions" as enum ('OPERATIONAL_EVENT_READ', 'OPERATIONAL_EVENT_CREATE');

create type "public"."app_roles" as enum ('USER', 'SUBCOM_AGENT', 'COM_ADMIN', 'ADMIN');

create type "public"."messageurgency" as enum ('normal', 'important', 'urgent', 'emergency');

create type "public"."operational_status" as enum ('EMERGENCY', 'TEST', 'NORMAL');

create type "public"."priority" as enum ('LOW', 'MEDIUM', 'HIGH');

create table "public"."checklist_steps" (
    "id" uuid not null,
    "label" character varying not null,
    "description" character varying,
    "updated_at" timestamp without time zone not null
);


create table "public"."checklist_steps_orders" (
    "id" uuid not null,
    "checklist_id" uuid not null,
    "checklist_step_id" uuid not null,
    "priority" integer not null,
    "updated_at" timestamp without time zone not null
);


create table "public"."checklist_steps_states" (
    "id" uuid not null,
    "checklist_steps_order_id" uuid not null,
    "user_profile_id" uuid not null,
    "is_completed" boolean not null
);


create table "public"."checklists" (
    "id" uuid not null,
    "title" character varying not null,
    "description" character varying,
    "notes" character varying,
    "updated_at" timestamp without time zone not null,
    "priority" priority not null,
    "frequency_id" uuid
);


create table "public"."clusters" (
    "id" uuid not null,
    "name" character varying,
    "meeting_place" character varying,
    "meeting_point" geometry(Point),
    "notes" character varying,
    "geom" geometry(Polygon)
);


create table "public"."frequency" (
    "id" uuid not null,
    "name" character varying not null,
    "num_days" integer not null
);


create table "public"."households" (
    "id" uuid not null,
    "cluster_id" uuid not null,
    "name" character varying,
    "address" character varying,
    "notes" character varying,
    "pets" character varying,
    "accessibility_needs" character varying,
    "geom" geometry(Polygon)
);


create table "public"."messages" (
    "id" uuid not null,
    "from_id" uuid,
    "to_id" uuid,
    "urgency" messageurgency,
    "content" character varying not null,
    "sent_on" timestamp without time zone not null
);


create table "public"."operational_events" (
    "id" uuid not null,
    "created_by" uuid not null,
    "created_at" timestamp without time zone not null,
    "status" operational_status not null
);


alter table "public"."operational_events" enable row level security;

create table "public"."people" (
    "id" uuid not null,
    "user_profile_id" uuid,
    "given_name" character varying,
    "family_name" character varying,
    "nickname" character varying,
    "is_safe" boolean not null,
    "needs_help" boolean not null
);


create table "public"."people_groups" (
    "people_id" uuid not null,
    "household_id" uuid,
    "notes" character varying
);


create table "public"."point_of_interest_types" (
    "name" character varying not null,
    "icon" character varying not null
);


create table "public"."point_of_interests" (
    "id" uuid not null,
    "name" character varying not null,
    "address" character varying not null,
    "geom" geometry(Point),
    "point_type_name" character varying not null
);


create table "public"."resource_subtype_tags" (
    "id" uuid not null,
    "name" character varying not null
);


create table "public"."resource_tags" (
    "resource_id" uuid not null,
    "resource_subtype_tag_id" uuid
);


create table "public"."resource_types" (
    "id" uuid not null,
    "name" character varying not null,
    "description" character varying
);


create table "public"."resources" (
    "resource_cv_id" uuid not null,
    "resource_type_id" uuid not null,
    "notes" character varying,
    "qty_needed" integer not null,
    "qty_available" integer not null
);


create table "public"."resources_cv" (
    "id" uuid not null,
    "name" character varying not null,
    "description" character varying
);


create table "public"."role_permissions" (
    "id" uuid not null,
    "role" app_roles not null,
    "permission" app_permissions not null
);


create table "public"."signup_codes" (
    "code" character varying(7) not null,
    "household_id" uuid not null
);


create table "public"."user_captain_clusters" (
    "id" uuid not null,
    "cluster_id" uuid not null,
    "user_role_id" uuid not null
);


create table "public"."user_checklists" (
    "id" uuid not null,
    "checklist_id" uuid not null,
    "user_profile_id" uuid not null,
    "completed_at" timestamp without time zone
);


create table "public"."user_profiles" (
    "id" uuid not null
);


create table "public"."user_resources" (
    "id" uuid not null,
    "user_id" uuid,
    "resource_id" uuid,
    "quantity" integer,
    "notes" character varying,
    "created_at" timestamp without time zone not null,
    "updated_at" timestamp without time zone not null
);


create table "public"."user_roles" (
    "id" uuid not null,
    "user_profile_id" uuid not null,
    "role" app_roles not null
);


CREATE UNIQUE INDEX checklist_steps_orders_pkey ON public.checklist_steps_orders USING btree (id);

CREATE UNIQUE INDEX checklist_steps_pkey ON public.checklist_steps USING btree (id);

CREATE UNIQUE INDEX checklist_steps_states_pkey ON public.checklist_steps_states USING btree (id);

CREATE UNIQUE INDEX checklists_pkey ON public.checklists USING btree (id);

CREATE UNIQUE INDEX clusters_pkey ON public.clusters USING btree (id);

CREATE UNIQUE INDEX frequency_pkey ON public.frequency USING btree (id);

CREATE UNIQUE INDEX households_pkey ON public.households USING btree (id);

CREATE INDEX idx_clusters_geom ON public.clusters USING gist (geom);

CREATE INDEX idx_clusters_meeting_point ON public.clusters USING gist (meeting_point);

CREATE INDEX idx_households_geom ON public.households USING gist (geom);

CREATE INDEX idx_point_of_interests_geom ON public.point_of_interests USING gist (geom);

CREATE UNIQUE INDEX messages_pkey ON public.messages USING btree (id);

CREATE UNIQUE INDEX operational_events_pkey ON public.operational_events USING btree (id);

CREATE UNIQUE INDEX people_groups_pkey ON public.people_groups USING btree (people_id);

CREATE UNIQUE INDEX people_pkey ON public.people USING btree (id);

CREATE UNIQUE INDEX people_user_profile_id_key ON public.people USING btree (user_profile_id);

CREATE UNIQUE INDEX point_of_interest_types_pkey ON public.point_of_interest_types USING btree (name);

CREATE UNIQUE INDEX point_of_interests_pkey ON public.point_of_interests USING btree (id);

CREATE UNIQUE INDEX resource_subtype_tags_pkey ON public.resource_subtype_tags USING btree (id);

CREATE UNIQUE INDEX resource_tags_pkey ON public.resource_tags USING btree (resource_id);

CREATE UNIQUE INDEX resource_types_pkey ON public.resource_types USING btree (id);

CREATE UNIQUE INDEX resources_cv_pkey ON public.resources_cv USING btree (id);

CREATE UNIQUE INDEX resources_pkey ON public.resources USING btree (resource_cv_id);

CREATE UNIQUE INDEX role_permissions_pkey ON public.role_permissions USING btree (id);

CREATE UNIQUE INDEX signup_codes_pkey ON public.signup_codes USING btree (code);

CREATE UNIQUE INDEX user_captain_clusters_pkey ON public.user_captain_clusters USING btree (id);

CREATE UNIQUE INDEX user_checklists_pkey ON public.user_checklists USING btree (id);

CREATE UNIQUE INDEX user_profiles_pkey ON public.user_profiles USING btree (id);

CREATE UNIQUE INDEX user_resources_pkey ON public.user_resources USING btree (id);

CREATE UNIQUE INDEX user_roles_pkey ON public.user_roles USING btree (id);

CREATE UNIQUE INDEX user_roles_user_profile_id_key ON public.user_roles USING btree (user_profile_id);

alter table "public"."checklist_steps" add constraint "checklist_steps_pkey" PRIMARY KEY using index "checklist_steps_pkey";

alter table "public"."checklist_steps_orders" add constraint "checklist_steps_orders_pkey" PRIMARY KEY using index "checklist_steps_orders_pkey";

alter table "public"."checklist_steps_states" add constraint "checklist_steps_states_pkey" PRIMARY KEY using index "checklist_steps_states_pkey";

alter table "public"."checklists" add constraint "checklists_pkey" PRIMARY KEY using index "checklists_pkey";

alter table "public"."clusters" add constraint "clusters_pkey" PRIMARY KEY using index "clusters_pkey";

alter table "public"."frequency" add constraint "frequency_pkey" PRIMARY KEY using index "frequency_pkey";

alter table "public"."households" add constraint "households_pkey" PRIMARY KEY using index "households_pkey";

alter table "public"."messages" add constraint "messages_pkey" PRIMARY KEY using index "messages_pkey";

alter table "public"."operational_events" add constraint "operational_events_pkey" PRIMARY KEY using index "operational_events_pkey";

alter table "public"."people" add constraint "people_pkey" PRIMARY KEY using index "people_pkey";

alter table "public"."people_groups" add constraint "people_groups_pkey" PRIMARY KEY using index "people_groups_pkey";

alter table "public"."point_of_interest_types" add constraint "point_of_interest_types_pkey" PRIMARY KEY using index "point_of_interest_types_pkey";

alter table "public"."point_of_interests" add constraint "point_of_interests_pkey" PRIMARY KEY using index "point_of_interests_pkey";

alter table "public"."resource_subtype_tags" add constraint "resource_subtype_tags_pkey" PRIMARY KEY using index "resource_subtype_tags_pkey";

alter table "public"."resource_tags" add constraint "resource_tags_pkey" PRIMARY KEY using index "resource_tags_pkey";

alter table "public"."resource_types" add constraint "resource_types_pkey" PRIMARY KEY using index "resource_types_pkey";

alter table "public"."resources" add constraint "resources_pkey" PRIMARY KEY using index "resources_pkey";

alter table "public"."resources_cv" add constraint "resources_cv_pkey" PRIMARY KEY using index "resources_cv_pkey";

alter table "public"."role_permissions" add constraint "role_permissions_pkey" PRIMARY KEY using index "role_permissions_pkey";

alter table "public"."signup_codes" add constraint "signup_codes_pkey" PRIMARY KEY using index "signup_codes_pkey";

alter table "public"."user_captain_clusters" add constraint "user_captain_clusters_pkey" PRIMARY KEY using index "user_captain_clusters_pkey";

alter table "public"."user_checklists" add constraint "user_checklists_pkey" PRIMARY KEY using index "user_checklists_pkey";

alter table "public"."user_profiles" add constraint "user_profiles_pkey" PRIMARY KEY using index "user_profiles_pkey";

alter table "public"."user_resources" add constraint "user_resources_pkey" PRIMARY KEY using index "user_resources_pkey";

alter table "public"."user_roles" add constraint "user_roles_pkey" PRIMARY KEY using index "user_roles_pkey";

alter table "public"."checklist_steps_orders" add constraint "checklist_steps_orders_checklist_id_fkey" FOREIGN KEY (checklist_id) REFERENCES checklists(id) not valid;

alter table "public"."checklist_steps_orders" validate constraint "checklist_steps_orders_checklist_id_fkey";

alter table "public"."checklist_steps_orders" add constraint "checklist_steps_orders_checklist_step_id_fkey" FOREIGN KEY (checklist_step_id) REFERENCES checklist_steps(id) not valid;

alter table "public"."checklist_steps_orders" validate constraint "checklist_steps_orders_checklist_step_id_fkey";

alter table "public"."checklist_steps_states" add constraint "checklist_steps_states_checklist_steps_order_id_fkey" FOREIGN KEY (checklist_steps_order_id) REFERENCES checklist_steps_orders(id) not valid;

alter table "public"."checklist_steps_states" validate constraint "checklist_steps_states_checklist_steps_order_id_fkey";

alter table "public"."checklist_steps_states" add constraint "checklist_steps_states_user_profile_id_fkey" FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id) not valid;

alter table "public"."checklist_steps_states" validate constraint "checklist_steps_states_user_profile_id_fkey";

alter table "public"."checklists" add constraint "checklists_frequency_id_fkey" FOREIGN KEY (frequency_id) REFERENCES frequency(id) not valid;

alter table "public"."checklists" validate constraint "checklists_frequency_id_fkey";

alter table "public"."households" add constraint "households_cluster_id_fkey" FOREIGN KEY (cluster_id) REFERENCES clusters(id) not valid;

alter table "public"."households" validate constraint "households_cluster_id_fkey";

alter table "public"."messages" add constraint "messages_from_id_fkey" FOREIGN KEY (from_id) REFERENCES user_profiles(id) not valid;

alter table "public"."messages" validate constraint "messages_from_id_fkey";

alter table "public"."messages" add constraint "messages_to_id_fkey" FOREIGN KEY (to_id) REFERENCES clusters(id) not valid;

alter table "public"."messages" validate constraint "messages_to_id_fkey";

alter table "public"."operational_events" add constraint "operational_events_created_by_fkey" FOREIGN KEY (created_by) REFERENCES user_profiles(id) not valid;

alter table "public"."operational_events" validate constraint "operational_events_created_by_fkey";

alter table "public"."people" add constraint "people_user_profile_id_fkey" FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id) not valid;

alter table "public"."people" validate constraint "people_user_profile_id_fkey";

alter table "public"."people" add constraint "people_user_profile_id_key" UNIQUE using index "people_user_profile_id_key";

alter table "public"."people_groups" add constraint "people_groups_household_id_fkey" FOREIGN KEY (household_id) REFERENCES households(id) not valid;

alter table "public"."people_groups" validate constraint "people_groups_household_id_fkey";

alter table "public"."people_groups" add constraint "people_groups_people_id_fkey" FOREIGN KEY (people_id) REFERENCES people(id) not valid;

alter table "public"."people_groups" validate constraint "people_groups_people_id_fkey";

alter table "public"."point_of_interests" add constraint "point_of_interests_point_type_name_fkey" FOREIGN KEY (point_type_name) REFERENCES point_of_interest_types(name) not valid;

alter table "public"."point_of_interests" validate constraint "point_of_interests_point_type_name_fkey";

alter table "public"."resource_tags" add constraint "resource_tags_resource_id_fkey" FOREIGN KEY (resource_id) REFERENCES resources(resource_cv_id) not valid;

alter table "public"."resource_tags" validate constraint "resource_tags_resource_id_fkey";

alter table "public"."resource_tags" add constraint "resource_tags_resource_subtype_tag_id_fkey" FOREIGN KEY (resource_subtype_tag_id) REFERENCES resource_subtype_tags(id) not valid;

alter table "public"."resource_tags" validate constraint "resource_tags_resource_subtype_tag_id_fkey";

alter table "public"."resources" add constraint "resources_resource_cv_id_fkey" FOREIGN KEY (resource_cv_id) REFERENCES resources_cv(id) not valid;

alter table "public"."resources" validate constraint "resources_resource_cv_id_fkey";

alter table "public"."resources" add constraint "resources_resource_type_id_fkey" FOREIGN KEY (resource_type_id) REFERENCES resource_types(id) not valid;

alter table "public"."resources" validate constraint "resources_resource_type_id_fkey";

alter table "public"."signup_codes" add constraint "signup_codes_household_id_fkey" FOREIGN KEY (household_id) REFERENCES households(id) not valid;

alter table "public"."signup_codes" validate constraint "signup_codes_household_id_fkey";

alter table "public"."user_captain_clusters" add constraint "user_captain_clusters_cluster_id_fkey" FOREIGN KEY (cluster_id) REFERENCES clusters(id) not valid;

alter table "public"."user_captain_clusters" validate constraint "user_captain_clusters_cluster_id_fkey";

alter table "public"."user_captain_clusters" add constraint "user_captain_clusters_user_role_id_fkey" FOREIGN KEY (user_role_id) REFERENCES user_roles(id) not valid;

alter table "public"."user_captain_clusters" validate constraint "user_captain_clusters_user_role_id_fkey";

alter table "public"."user_checklists" add constraint "user_checklists_checklist_id_fkey" FOREIGN KEY (checklist_id) REFERENCES checklists(id) not valid;

alter table "public"."user_checklists" validate constraint "user_checklists_checklist_id_fkey";

alter table "public"."user_checklists" add constraint "user_checklists_user_profile_id_fkey" FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id) not valid;

alter table "public"."user_checklists" validate constraint "user_checklists_user_profile_id_fkey";

alter table "public"."user_profiles" add constraint "user_profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) not valid;

alter table "public"."user_profiles" validate constraint "user_profiles_id_fkey";

alter table "public"."user_resources" add constraint "user_resources_resource_id_fkey" FOREIGN KEY (resource_id) REFERENCES resources(resource_cv_id) not valid;

alter table "public"."user_resources" validate constraint "user_resources_resource_id_fkey";

alter table "public"."user_resources" add constraint "user_resources_user_id_fkey" FOREIGN KEY (user_id) REFERENCES user_profiles(id) not valid;

alter table "public"."user_resources" validate constraint "user_resources_user_id_fkey";

alter table "public"."user_roles" add constraint "user_roles_user_profile_id_fkey" FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id) not valid;

alter table "public"."user_roles" validate constraint "user_roles_user_profile_id_fkey";

alter table "public"."user_roles" add constraint "user_roles_user_profile_id_key" UNIQUE using index "user_roles_user_profile_id_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.authorize(requested_permission app_permissions)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
  $function$
;

CREATE OR REPLACE FUNCTION public.custom_access_token(event jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
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
  $function$
;

CREATE OR REPLACE FUNCTION public.delete_checklist_step_cascade()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
  $function$
;

CREATE OR REPLACE FUNCTION public.insert_checklist_steps_state_for_all_users()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
  $function$
;

CREATE OR REPLACE FUNCTION public.insert_user_checklists_for_all_users()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
  $function$
;

CREATE OR REPLACE FUNCTION public.invalidate_signup_code(input_code text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;

grant delete on table "public"."checklist_steps" to "anon";

grant insert on table "public"."checklist_steps" to "anon";

grant references on table "public"."checklist_steps" to "anon";

grant select on table "public"."checklist_steps" to "anon";

grant trigger on table "public"."checklist_steps" to "anon";

grant truncate on table "public"."checklist_steps" to "anon";

grant update on table "public"."checklist_steps" to "anon";

grant delete on table "public"."checklist_steps" to "authenticated";

grant insert on table "public"."checklist_steps" to "authenticated";

grant references on table "public"."checklist_steps" to "authenticated";

grant select on table "public"."checklist_steps" to "authenticated";

grant trigger on table "public"."checklist_steps" to "authenticated";

grant truncate on table "public"."checklist_steps" to "authenticated";

grant update on table "public"."checklist_steps" to "authenticated";

grant delete on table "public"."checklist_steps" to "service_role";

grant insert on table "public"."checklist_steps" to "service_role";

grant references on table "public"."checklist_steps" to "service_role";

grant select on table "public"."checklist_steps" to "service_role";

grant trigger on table "public"."checklist_steps" to "service_role";

grant truncate on table "public"."checklist_steps" to "service_role";

grant update on table "public"."checklist_steps" to "service_role";

grant delete on table "public"."checklist_steps_orders" to "anon";

grant insert on table "public"."checklist_steps_orders" to "anon";

grant references on table "public"."checklist_steps_orders" to "anon";

grant select on table "public"."checklist_steps_orders" to "anon";

grant trigger on table "public"."checklist_steps_orders" to "anon";

grant truncate on table "public"."checklist_steps_orders" to "anon";

grant update on table "public"."checklist_steps_orders" to "anon";

grant delete on table "public"."checklist_steps_orders" to "authenticated";

grant insert on table "public"."checklist_steps_orders" to "authenticated";

grant references on table "public"."checklist_steps_orders" to "authenticated";

grant select on table "public"."checklist_steps_orders" to "authenticated";

grant trigger on table "public"."checklist_steps_orders" to "authenticated";

grant truncate on table "public"."checklist_steps_orders" to "authenticated";

grant update on table "public"."checklist_steps_orders" to "authenticated";

grant delete on table "public"."checklist_steps_orders" to "service_role";

grant insert on table "public"."checklist_steps_orders" to "service_role";

grant references on table "public"."checklist_steps_orders" to "service_role";

grant select on table "public"."checklist_steps_orders" to "service_role";

grant trigger on table "public"."checklist_steps_orders" to "service_role";

grant truncate on table "public"."checklist_steps_orders" to "service_role";

grant update on table "public"."checklist_steps_orders" to "service_role";

grant delete on table "public"."checklist_steps_states" to "anon";

grant insert on table "public"."checklist_steps_states" to "anon";

grant references on table "public"."checklist_steps_states" to "anon";

grant select on table "public"."checklist_steps_states" to "anon";

grant trigger on table "public"."checklist_steps_states" to "anon";

grant truncate on table "public"."checklist_steps_states" to "anon";

grant update on table "public"."checklist_steps_states" to "anon";

grant delete on table "public"."checklist_steps_states" to "authenticated";

grant insert on table "public"."checklist_steps_states" to "authenticated";

grant references on table "public"."checklist_steps_states" to "authenticated";

grant select on table "public"."checklist_steps_states" to "authenticated";

grant trigger on table "public"."checklist_steps_states" to "authenticated";

grant truncate on table "public"."checklist_steps_states" to "authenticated";

grant update on table "public"."checklist_steps_states" to "authenticated";

grant delete on table "public"."checklist_steps_states" to "service_role";

grant insert on table "public"."checklist_steps_states" to "service_role";

grant references on table "public"."checklist_steps_states" to "service_role";

grant select on table "public"."checklist_steps_states" to "service_role";

grant trigger on table "public"."checklist_steps_states" to "service_role";

grant truncate on table "public"."checklist_steps_states" to "service_role";

grant update on table "public"."checklist_steps_states" to "service_role";

grant delete on table "public"."checklists" to "anon";

grant insert on table "public"."checklists" to "anon";

grant references on table "public"."checklists" to "anon";

grant select on table "public"."checklists" to "anon";

grant trigger on table "public"."checklists" to "anon";

grant truncate on table "public"."checklists" to "anon";

grant update on table "public"."checklists" to "anon";

grant delete on table "public"."checklists" to "authenticated";

grant insert on table "public"."checklists" to "authenticated";

grant references on table "public"."checklists" to "authenticated";

grant select on table "public"."checklists" to "authenticated";

grant trigger on table "public"."checklists" to "authenticated";

grant truncate on table "public"."checklists" to "authenticated";

grant update on table "public"."checklists" to "authenticated";

grant delete on table "public"."checklists" to "service_role";

grant insert on table "public"."checklists" to "service_role";

grant references on table "public"."checklists" to "service_role";

grant select on table "public"."checklists" to "service_role";

grant trigger on table "public"."checklists" to "service_role";

grant truncate on table "public"."checklists" to "service_role";

grant update on table "public"."checklists" to "service_role";

grant delete on table "public"."clusters" to "anon";

grant insert on table "public"."clusters" to "anon";

grant references on table "public"."clusters" to "anon";

grant select on table "public"."clusters" to "anon";

grant trigger on table "public"."clusters" to "anon";

grant truncate on table "public"."clusters" to "anon";

grant update on table "public"."clusters" to "anon";

grant delete on table "public"."clusters" to "authenticated";

grant insert on table "public"."clusters" to "authenticated";

grant references on table "public"."clusters" to "authenticated";

grant select on table "public"."clusters" to "authenticated";

grant trigger on table "public"."clusters" to "authenticated";

grant truncate on table "public"."clusters" to "authenticated";

grant update on table "public"."clusters" to "authenticated";

grant delete on table "public"."clusters" to "service_role";

grant insert on table "public"."clusters" to "service_role";

grant references on table "public"."clusters" to "service_role";

grant select on table "public"."clusters" to "service_role";

grant trigger on table "public"."clusters" to "service_role";

grant truncate on table "public"."clusters" to "service_role";

grant update on table "public"."clusters" to "service_role";

grant delete on table "public"."frequency" to "anon";

grant insert on table "public"."frequency" to "anon";

grant references on table "public"."frequency" to "anon";

grant select on table "public"."frequency" to "anon";

grant trigger on table "public"."frequency" to "anon";

grant truncate on table "public"."frequency" to "anon";

grant update on table "public"."frequency" to "anon";

grant delete on table "public"."frequency" to "authenticated";

grant insert on table "public"."frequency" to "authenticated";

grant references on table "public"."frequency" to "authenticated";

grant select on table "public"."frequency" to "authenticated";

grant trigger on table "public"."frequency" to "authenticated";

grant truncate on table "public"."frequency" to "authenticated";

grant update on table "public"."frequency" to "authenticated";

grant delete on table "public"."frequency" to "service_role";

grant insert on table "public"."frequency" to "service_role";

grant references on table "public"."frequency" to "service_role";

grant select on table "public"."frequency" to "service_role";

grant trigger on table "public"."frequency" to "service_role";

grant truncate on table "public"."frequency" to "service_role";

grant update on table "public"."frequency" to "service_role";

grant delete on table "public"."households" to "anon";

grant insert on table "public"."households" to "anon";

grant references on table "public"."households" to "anon";

grant select on table "public"."households" to "anon";

grant trigger on table "public"."households" to "anon";

grant truncate on table "public"."households" to "anon";

grant update on table "public"."households" to "anon";

grant delete on table "public"."households" to "authenticated";

grant insert on table "public"."households" to "authenticated";

grant references on table "public"."households" to "authenticated";

grant select on table "public"."households" to "authenticated";

grant trigger on table "public"."households" to "authenticated";

grant truncate on table "public"."households" to "authenticated";

grant update on table "public"."households" to "authenticated";

grant delete on table "public"."households" to "service_role";

grant insert on table "public"."households" to "service_role";

grant references on table "public"."households" to "service_role";

grant select on table "public"."households" to "service_role";

grant trigger on table "public"."households" to "service_role";

grant truncate on table "public"."households" to "service_role";

grant update on table "public"."households" to "service_role";

grant delete on table "public"."messages" to "anon";

grant insert on table "public"."messages" to "anon";

grant references on table "public"."messages" to "anon";

grant select on table "public"."messages" to "anon";

grant trigger on table "public"."messages" to "anon";

grant truncate on table "public"."messages" to "anon";

grant update on table "public"."messages" to "anon";

grant delete on table "public"."messages" to "authenticated";

grant insert on table "public"."messages" to "authenticated";

grant references on table "public"."messages" to "authenticated";

grant select on table "public"."messages" to "authenticated";

grant trigger on table "public"."messages" to "authenticated";

grant truncate on table "public"."messages" to "authenticated";

grant update on table "public"."messages" to "authenticated";

grant delete on table "public"."messages" to "service_role";

grant insert on table "public"."messages" to "service_role";

grant references on table "public"."messages" to "service_role";

grant select on table "public"."messages" to "service_role";

grant trigger on table "public"."messages" to "service_role";

grant truncate on table "public"."messages" to "service_role";

grant update on table "public"."messages" to "service_role";

grant delete on table "public"."operational_events" to "anon";

grant insert on table "public"."operational_events" to "anon";

grant references on table "public"."operational_events" to "anon";

grant select on table "public"."operational_events" to "anon";

grant trigger on table "public"."operational_events" to "anon";

grant truncate on table "public"."operational_events" to "anon";

grant update on table "public"."operational_events" to "anon";

grant delete on table "public"."operational_events" to "authenticated";

grant insert on table "public"."operational_events" to "authenticated";

grant references on table "public"."operational_events" to "authenticated";

grant select on table "public"."operational_events" to "authenticated";

grant trigger on table "public"."operational_events" to "authenticated";

grant truncate on table "public"."operational_events" to "authenticated";

grant update on table "public"."operational_events" to "authenticated";

grant delete on table "public"."operational_events" to "service_role";

grant insert on table "public"."operational_events" to "service_role";

grant references on table "public"."operational_events" to "service_role";

grant select on table "public"."operational_events" to "service_role";

grant trigger on table "public"."operational_events" to "service_role";

grant truncate on table "public"."operational_events" to "service_role";

grant update on table "public"."operational_events" to "service_role";

grant delete on table "public"."people" to "anon";

grant insert on table "public"."people" to "anon";

grant references on table "public"."people" to "anon";

grant select on table "public"."people" to "anon";

grant trigger on table "public"."people" to "anon";

grant truncate on table "public"."people" to "anon";

grant update on table "public"."people" to "anon";

grant delete on table "public"."people" to "authenticated";

grant insert on table "public"."people" to "authenticated";

grant references on table "public"."people" to "authenticated";

grant select on table "public"."people" to "authenticated";

grant trigger on table "public"."people" to "authenticated";

grant truncate on table "public"."people" to "authenticated";

grant update on table "public"."people" to "authenticated";

grant delete on table "public"."people" to "service_role";

grant insert on table "public"."people" to "service_role";

grant references on table "public"."people" to "service_role";

grant select on table "public"."people" to "service_role";

grant trigger on table "public"."people" to "service_role";

grant truncate on table "public"."people" to "service_role";

grant update on table "public"."people" to "service_role";

grant delete on table "public"."people_groups" to "anon";

grant insert on table "public"."people_groups" to "anon";

grant references on table "public"."people_groups" to "anon";

grant select on table "public"."people_groups" to "anon";

grant trigger on table "public"."people_groups" to "anon";

grant truncate on table "public"."people_groups" to "anon";

grant update on table "public"."people_groups" to "anon";

grant delete on table "public"."people_groups" to "authenticated";

grant insert on table "public"."people_groups" to "authenticated";

grant references on table "public"."people_groups" to "authenticated";

grant select on table "public"."people_groups" to "authenticated";

grant trigger on table "public"."people_groups" to "authenticated";

grant truncate on table "public"."people_groups" to "authenticated";

grant update on table "public"."people_groups" to "authenticated";

grant delete on table "public"."people_groups" to "service_role";

grant insert on table "public"."people_groups" to "service_role";

grant references on table "public"."people_groups" to "service_role";

grant select on table "public"."people_groups" to "service_role";

grant trigger on table "public"."people_groups" to "service_role";

grant truncate on table "public"."people_groups" to "service_role";

grant update on table "public"."people_groups" to "service_role";

grant delete on table "public"."point_of_interest_types" to "anon";

grant insert on table "public"."point_of_interest_types" to "anon";

grant references on table "public"."point_of_interest_types" to "anon";

grant select on table "public"."point_of_interest_types" to "anon";

grant trigger on table "public"."point_of_interest_types" to "anon";

grant truncate on table "public"."point_of_interest_types" to "anon";

grant update on table "public"."point_of_interest_types" to "anon";

grant delete on table "public"."point_of_interest_types" to "authenticated";

grant insert on table "public"."point_of_interest_types" to "authenticated";

grant references on table "public"."point_of_interest_types" to "authenticated";

grant select on table "public"."point_of_interest_types" to "authenticated";

grant trigger on table "public"."point_of_interest_types" to "authenticated";

grant truncate on table "public"."point_of_interest_types" to "authenticated";

grant update on table "public"."point_of_interest_types" to "authenticated";

grant delete on table "public"."point_of_interest_types" to "service_role";

grant insert on table "public"."point_of_interest_types" to "service_role";

grant references on table "public"."point_of_interest_types" to "service_role";

grant select on table "public"."point_of_interest_types" to "service_role";

grant trigger on table "public"."point_of_interest_types" to "service_role";

grant truncate on table "public"."point_of_interest_types" to "service_role";

grant update on table "public"."point_of_interest_types" to "service_role";

grant delete on table "public"."point_of_interests" to "anon";

grant insert on table "public"."point_of_interests" to "anon";

grant references on table "public"."point_of_interests" to "anon";

grant select on table "public"."point_of_interests" to "anon";

grant trigger on table "public"."point_of_interests" to "anon";

grant truncate on table "public"."point_of_interests" to "anon";

grant update on table "public"."point_of_interests" to "anon";

grant delete on table "public"."point_of_interests" to "authenticated";

grant insert on table "public"."point_of_interests" to "authenticated";

grant references on table "public"."point_of_interests" to "authenticated";

grant select on table "public"."point_of_interests" to "authenticated";

grant trigger on table "public"."point_of_interests" to "authenticated";

grant truncate on table "public"."point_of_interests" to "authenticated";

grant update on table "public"."point_of_interests" to "authenticated";

grant delete on table "public"."point_of_interests" to "service_role";

grant insert on table "public"."point_of_interests" to "service_role";

grant references on table "public"."point_of_interests" to "service_role";

grant select on table "public"."point_of_interests" to "service_role";

grant trigger on table "public"."point_of_interests" to "service_role";

grant truncate on table "public"."point_of_interests" to "service_role";

grant update on table "public"."point_of_interests" to "service_role";

grant delete on table "public"."resource_subtype_tags" to "anon";

grant insert on table "public"."resource_subtype_tags" to "anon";

grant references on table "public"."resource_subtype_tags" to "anon";

grant select on table "public"."resource_subtype_tags" to "anon";

grant trigger on table "public"."resource_subtype_tags" to "anon";

grant truncate on table "public"."resource_subtype_tags" to "anon";

grant update on table "public"."resource_subtype_tags" to "anon";

grant delete on table "public"."resource_subtype_tags" to "authenticated";

grant insert on table "public"."resource_subtype_tags" to "authenticated";

grant references on table "public"."resource_subtype_tags" to "authenticated";

grant select on table "public"."resource_subtype_tags" to "authenticated";

grant trigger on table "public"."resource_subtype_tags" to "authenticated";

grant truncate on table "public"."resource_subtype_tags" to "authenticated";

grant update on table "public"."resource_subtype_tags" to "authenticated";

grant delete on table "public"."resource_subtype_tags" to "service_role";

grant insert on table "public"."resource_subtype_tags" to "service_role";

grant references on table "public"."resource_subtype_tags" to "service_role";

grant select on table "public"."resource_subtype_tags" to "service_role";

grant trigger on table "public"."resource_subtype_tags" to "service_role";

grant truncate on table "public"."resource_subtype_tags" to "service_role";

grant update on table "public"."resource_subtype_tags" to "service_role";

grant delete on table "public"."resource_tags" to "anon";

grant insert on table "public"."resource_tags" to "anon";

grant references on table "public"."resource_tags" to "anon";

grant select on table "public"."resource_tags" to "anon";

grant trigger on table "public"."resource_tags" to "anon";

grant truncate on table "public"."resource_tags" to "anon";

grant update on table "public"."resource_tags" to "anon";

grant delete on table "public"."resource_tags" to "authenticated";

grant insert on table "public"."resource_tags" to "authenticated";

grant references on table "public"."resource_tags" to "authenticated";

grant select on table "public"."resource_tags" to "authenticated";

grant trigger on table "public"."resource_tags" to "authenticated";

grant truncate on table "public"."resource_tags" to "authenticated";

grant update on table "public"."resource_tags" to "authenticated";

grant delete on table "public"."resource_tags" to "service_role";

grant insert on table "public"."resource_tags" to "service_role";

grant references on table "public"."resource_tags" to "service_role";

grant select on table "public"."resource_tags" to "service_role";

grant trigger on table "public"."resource_tags" to "service_role";

grant truncate on table "public"."resource_tags" to "service_role";

grant update on table "public"."resource_tags" to "service_role";

grant delete on table "public"."resource_types" to "anon";

grant insert on table "public"."resource_types" to "anon";

grant references on table "public"."resource_types" to "anon";

grant select on table "public"."resource_types" to "anon";

grant trigger on table "public"."resource_types" to "anon";

grant truncate on table "public"."resource_types" to "anon";

grant update on table "public"."resource_types" to "anon";

grant delete on table "public"."resource_types" to "authenticated";

grant insert on table "public"."resource_types" to "authenticated";

grant references on table "public"."resource_types" to "authenticated";

grant select on table "public"."resource_types" to "authenticated";

grant trigger on table "public"."resource_types" to "authenticated";

grant truncate on table "public"."resource_types" to "authenticated";

grant update on table "public"."resource_types" to "authenticated";

grant delete on table "public"."resource_types" to "service_role";

grant insert on table "public"."resource_types" to "service_role";

grant references on table "public"."resource_types" to "service_role";

grant select on table "public"."resource_types" to "service_role";

grant trigger on table "public"."resource_types" to "service_role";

grant truncate on table "public"."resource_types" to "service_role";

grant update on table "public"."resource_types" to "service_role";

grant delete on table "public"."resources" to "anon";

grant insert on table "public"."resources" to "anon";

grant references on table "public"."resources" to "anon";

grant select on table "public"."resources" to "anon";

grant trigger on table "public"."resources" to "anon";

grant truncate on table "public"."resources" to "anon";

grant update on table "public"."resources" to "anon";

grant delete on table "public"."resources" to "authenticated";

grant insert on table "public"."resources" to "authenticated";

grant references on table "public"."resources" to "authenticated";

grant select on table "public"."resources" to "authenticated";

grant trigger on table "public"."resources" to "authenticated";

grant truncate on table "public"."resources" to "authenticated";

grant update on table "public"."resources" to "authenticated";

grant delete on table "public"."resources" to "service_role";

grant insert on table "public"."resources" to "service_role";

grant references on table "public"."resources" to "service_role";

grant select on table "public"."resources" to "service_role";

grant trigger on table "public"."resources" to "service_role";

grant truncate on table "public"."resources" to "service_role";

grant update on table "public"."resources" to "service_role";

grant delete on table "public"."resources_cv" to "anon";

grant insert on table "public"."resources_cv" to "anon";

grant references on table "public"."resources_cv" to "anon";

grant select on table "public"."resources_cv" to "anon";

grant trigger on table "public"."resources_cv" to "anon";

grant truncate on table "public"."resources_cv" to "anon";

grant update on table "public"."resources_cv" to "anon";

grant delete on table "public"."resources_cv" to "authenticated";

grant insert on table "public"."resources_cv" to "authenticated";

grant references on table "public"."resources_cv" to "authenticated";

grant select on table "public"."resources_cv" to "authenticated";

grant trigger on table "public"."resources_cv" to "authenticated";

grant truncate on table "public"."resources_cv" to "authenticated";

grant update on table "public"."resources_cv" to "authenticated";

grant delete on table "public"."resources_cv" to "service_role";

grant insert on table "public"."resources_cv" to "service_role";

grant references on table "public"."resources_cv" to "service_role";

grant select on table "public"."resources_cv" to "service_role";

grant trigger on table "public"."resources_cv" to "service_role";

grant truncate on table "public"."resources_cv" to "service_role";

grant update on table "public"."resources_cv" to "service_role";

grant delete on table "public"."role_permissions" to "anon";

grant insert on table "public"."role_permissions" to "anon";

grant references on table "public"."role_permissions" to "anon";

grant select on table "public"."role_permissions" to "anon";

grant trigger on table "public"."role_permissions" to "anon";

grant truncate on table "public"."role_permissions" to "anon";

grant update on table "public"."role_permissions" to "anon";

grant delete on table "public"."role_permissions" to "authenticated";

grant insert on table "public"."role_permissions" to "authenticated";

grant references on table "public"."role_permissions" to "authenticated";

grant select on table "public"."role_permissions" to "authenticated";

grant trigger on table "public"."role_permissions" to "authenticated";

grant truncate on table "public"."role_permissions" to "authenticated";

grant update on table "public"."role_permissions" to "authenticated";

grant delete on table "public"."role_permissions" to "service_role";

grant insert on table "public"."role_permissions" to "service_role";

grant references on table "public"."role_permissions" to "service_role";

grant select on table "public"."role_permissions" to "service_role";

grant trigger on table "public"."role_permissions" to "service_role";

grant truncate on table "public"."role_permissions" to "service_role";

grant update on table "public"."role_permissions" to "service_role";

grant delete on table "public"."signup_codes" to "anon";

grant insert on table "public"."signup_codes" to "anon";

grant references on table "public"."signup_codes" to "anon";

grant select on table "public"."signup_codes" to "anon";

grant trigger on table "public"."signup_codes" to "anon";

grant truncate on table "public"."signup_codes" to "anon";

grant update on table "public"."signup_codes" to "anon";

grant delete on table "public"."signup_codes" to "authenticated";

grant insert on table "public"."signup_codes" to "authenticated";

grant references on table "public"."signup_codes" to "authenticated";

grant select on table "public"."signup_codes" to "authenticated";

grant trigger on table "public"."signup_codes" to "authenticated";

grant truncate on table "public"."signup_codes" to "authenticated";

grant update on table "public"."signup_codes" to "authenticated";

grant delete on table "public"."signup_codes" to "service_role";

grant insert on table "public"."signup_codes" to "service_role";

grant references on table "public"."signup_codes" to "service_role";

grant select on table "public"."signup_codes" to "service_role";

grant trigger on table "public"."signup_codes" to "service_role";

grant truncate on table "public"."signup_codes" to "service_role";

grant update on table "public"."signup_codes" to "service_role";

grant delete on table "public"."user_captain_clusters" to "anon";

grant insert on table "public"."user_captain_clusters" to "anon";

grant references on table "public"."user_captain_clusters" to "anon";

grant select on table "public"."user_captain_clusters" to "anon";

grant trigger on table "public"."user_captain_clusters" to "anon";

grant truncate on table "public"."user_captain_clusters" to "anon";

grant update on table "public"."user_captain_clusters" to "anon";

grant delete on table "public"."user_captain_clusters" to "authenticated";

grant insert on table "public"."user_captain_clusters" to "authenticated";

grant references on table "public"."user_captain_clusters" to "authenticated";

grant select on table "public"."user_captain_clusters" to "authenticated";

grant trigger on table "public"."user_captain_clusters" to "authenticated";

grant truncate on table "public"."user_captain_clusters" to "authenticated";

grant update on table "public"."user_captain_clusters" to "authenticated";

grant delete on table "public"."user_captain_clusters" to "service_role";

grant insert on table "public"."user_captain_clusters" to "service_role";

grant references on table "public"."user_captain_clusters" to "service_role";

grant select on table "public"."user_captain_clusters" to "service_role";

grant trigger on table "public"."user_captain_clusters" to "service_role";

grant truncate on table "public"."user_captain_clusters" to "service_role";

grant update on table "public"."user_captain_clusters" to "service_role";

grant delete on table "public"."user_checklists" to "anon";

grant insert on table "public"."user_checklists" to "anon";

grant references on table "public"."user_checklists" to "anon";

grant select on table "public"."user_checklists" to "anon";

grant trigger on table "public"."user_checklists" to "anon";

grant truncate on table "public"."user_checklists" to "anon";

grant update on table "public"."user_checklists" to "anon";

grant delete on table "public"."user_checklists" to "authenticated";

grant insert on table "public"."user_checklists" to "authenticated";

grant references on table "public"."user_checklists" to "authenticated";

grant select on table "public"."user_checklists" to "authenticated";

grant trigger on table "public"."user_checklists" to "authenticated";

grant truncate on table "public"."user_checklists" to "authenticated";

grant update on table "public"."user_checklists" to "authenticated";

grant delete on table "public"."user_checklists" to "service_role";

grant insert on table "public"."user_checklists" to "service_role";

grant references on table "public"."user_checklists" to "service_role";

grant select on table "public"."user_checklists" to "service_role";

grant trigger on table "public"."user_checklists" to "service_role";

grant truncate on table "public"."user_checklists" to "service_role";

grant update on table "public"."user_checklists" to "service_role";

grant delete on table "public"."user_profiles" to "anon";

grant insert on table "public"."user_profiles" to "anon";

grant references on table "public"."user_profiles" to "anon";

grant select on table "public"."user_profiles" to "anon";

grant trigger on table "public"."user_profiles" to "anon";

grant truncate on table "public"."user_profiles" to "anon";

grant update on table "public"."user_profiles" to "anon";

grant delete on table "public"."user_profiles" to "authenticated";

grant insert on table "public"."user_profiles" to "authenticated";

grant references on table "public"."user_profiles" to "authenticated";

grant select on table "public"."user_profiles" to "authenticated";

grant trigger on table "public"."user_profiles" to "authenticated";

grant truncate on table "public"."user_profiles" to "authenticated";

grant update on table "public"."user_profiles" to "authenticated";

grant delete on table "public"."user_profiles" to "service_role";

grant insert on table "public"."user_profiles" to "service_role";

grant references on table "public"."user_profiles" to "service_role";

grant select on table "public"."user_profiles" to "service_role";

grant trigger on table "public"."user_profiles" to "service_role";

grant truncate on table "public"."user_profiles" to "service_role";

grant update on table "public"."user_profiles" to "service_role";

grant delete on table "public"."user_resources" to "anon";

grant insert on table "public"."user_resources" to "anon";

grant references on table "public"."user_resources" to "anon";

grant select on table "public"."user_resources" to "anon";

grant trigger on table "public"."user_resources" to "anon";

grant truncate on table "public"."user_resources" to "anon";

grant update on table "public"."user_resources" to "anon";

grant delete on table "public"."user_resources" to "authenticated";

grant insert on table "public"."user_resources" to "authenticated";

grant references on table "public"."user_resources" to "authenticated";

grant select on table "public"."user_resources" to "authenticated";

grant trigger on table "public"."user_resources" to "authenticated";

grant truncate on table "public"."user_resources" to "authenticated";

grant update on table "public"."user_resources" to "authenticated";

grant delete on table "public"."user_resources" to "service_role";

grant insert on table "public"."user_resources" to "service_role";

grant references on table "public"."user_resources" to "service_role";

grant select on table "public"."user_resources" to "service_role";

grant trigger on table "public"."user_resources" to "service_role";

grant truncate on table "public"."user_resources" to "service_role";

grant update on table "public"."user_resources" to "service_role";

grant delete on table "public"."user_roles" to "anon";

grant insert on table "public"."user_roles" to "anon";

grant references on table "public"."user_roles" to "anon";

grant select on table "public"."user_roles" to "anon";

grant trigger on table "public"."user_roles" to "anon";

grant truncate on table "public"."user_roles" to "anon";

grant update on table "public"."user_roles" to "anon";

grant delete on table "public"."user_roles" to "authenticated";

grant insert on table "public"."user_roles" to "authenticated";

grant references on table "public"."user_roles" to "authenticated";

grant select on table "public"."user_roles" to "authenticated";

grant trigger on table "public"."user_roles" to "authenticated";

grant truncate on table "public"."user_roles" to "authenticated";

grant update on table "public"."user_roles" to "authenticated";

grant delete on table "public"."user_roles" to "service_role";

grant insert on table "public"."user_roles" to "service_role";

grant references on table "public"."user_roles" to "service_role";

grant select on table "public"."user_roles" to "service_role";

grant trigger on table "public"."user_roles" to "service_role";

grant truncate on table "public"."user_roles" to "service_role";

grant update on table "public"."user_roles" to "service_role";

grant delete on table "public"."user_roles" to "supabase_auth_admin";

grant insert on table "public"."user_roles" to "supabase_auth_admin";

grant references on table "public"."user_roles" to "supabase_auth_admin";

grant select on table "public"."user_roles" to "supabase_auth_admin";

grant trigger on table "public"."user_roles" to "supabase_auth_admin";

grant truncate on table "public"."user_roles" to "supabase_auth_admin";

grant update on table "public"."user_roles" to "supabase_auth_admin";

create policy "Allow authorized INSERT access"
on "public"."operational_events"
as permissive
for insert
to public
with check (authorize('OPERATIONAL_EVENT_CREATE'::app_permissions));


create policy "Allow authorized SELECT access"
on "public"."operational_events"
as permissive
for select
to public
using (( SELECT authorize('OPERATIONAL_EVENT_READ'::app_permissions) AS authorize));


create policy "Allow authorized UPDATE access"
on "public"."operational_events"
as permissive
for update
to public
using (( SELECT authorize('OPERATIONAL_EVENT_CREATE'::app_permissions) AS authorize));


CREATE TRIGGER trigger_delete_checklist_step_cascade BEFORE DELETE ON public.checklist_steps FOR EACH ROW EXECUTE FUNCTION delete_checklist_step_cascade();

CREATE TRIGGER trigger_insert_checklist_steps_state_for_all_users AFTER INSERT ON public.checklist_steps_orders FOR EACH ROW EXECUTE FUNCTION insert_checklist_steps_state_for_all_users();

CREATE TRIGGER trigger_insert_user_checklists_for_all_users AFTER INSERT ON public.checklists FOR EACH ROW EXECUTE FUNCTION insert_user_checklists_for_all_users();


