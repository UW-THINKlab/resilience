#!/usr/bin/env bash
set -euo pipefail

# This script is constructed from 3 calls to "supabase db dump" to create a full script:
#   supabase db dump --local --keep-comments --dry-run > new-backup.sh
#   supabase db dump --local --role-only --dry-run >> new-backup.sh
#   supabase db dump --local --data-only --dry-run >> new-backup.sh
#
# The script was then modified to dump data only from a few tables needed to fully initialize a new system.
#
# Everything that is user-related is ignored.
#
# This dumps everything needed for a fresh load of a new system.

export PGHOST=${PGHOST:-"127.0.0.1"}
export PGPORT=${PGPORT:-"5432"}
export PGUSER=${PGUSER:-"postgres"}
export PGPASSWORD=${PGPASSWORD:-"postgres"}
export PGDATABASE=${PGDATABASE:-"postgres"}

## Dump schema ##

echo "-- dumping schema"

# Explanation of pg_dump flags:
#
#   --schema-only     omit data like migration history, pgsodium key, etc.
#   --exclude-schema  omit internal schemas as they are maintained by platform
#
# Explanation of sed substitutions:
#
#   - do not emit psql meta commands
#   - do not alter superuser role "supabase_admin"
#   - do not alter foreign data wrappers owner
#   - do not include ACL changes on internal schemas
#   - do not include RLS policies on cron extension schema
#   - do not include event triggers
#   - do not create pgtle schema and extension comments
#   - do not create publication "supabase_realtime"
#   - do not set transaction_timeout which requires pg17
pg_dump \
    --schema-only \
    --quote-all-identifier \
    --role "postgres" \
    --exclude-schema "information_schema|pg_*|_analytics|_realtime|_supavisor|auth|etl|extensions|pgbouncer|realtime|storage|supabase_functions|supabase_migrations|cron|dbdev|graphql|graphql_public|net|pgmq|pgsodium|pgsodium_masks|pgtle|repack|tiger|tiger_data|timescaledb_*|_timescaledb_*|topology|vault" \
     \
| sed -E 's/^\\(un)?restrict .*$/-- &/' \
| sed -E 's/^CREATE SCHEMA "/CREATE SCHEMA IF NOT EXISTS "/' \
| sed -E 's/^CREATE TABLE "/CREATE TABLE IF NOT EXISTS "/' \
| sed -E 's/^CREATE SEQUENCE "/CREATE SEQUENCE IF NOT EXISTS "/' \
| sed -E 's/^CREATE VIEW "/CREATE OR REPLACE VIEW "/' \
| sed -E 's/^CREATE FUNCTION "/CREATE OR REPLACE FUNCTION "/' \
| sed -E 's/^CREATE TRIGGER "/CREATE OR REPLACE TRIGGER "/' \
| sed -E 's/^CREATE PUBLICATION "supabase_realtime/-- &/' \
| sed -E 's/^CREATE EVENT TRIGGER /-- &/' \
| sed -E 's/^         WHEN TAG IN /-- &/' \
| sed -E 's/^   EXECUTE FUNCTION /-- &/' \
| sed -E 's/^ALTER EVENT TRIGGER /-- &/' \
| sed -E 's/^ALTER PUBLICATION "supabase_realtime_/-- &/' \
| sed -E 's/^ALTER FOREIGN DATA WRAPPER (.+) OWNER TO /-- &/' \
| sed -E 's/^ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin"/-- &/' \
| sed -E 's/^GRANT ALL ON FOREIGN DATA WRAPPER (.+) TO "postgres" WITH GRANT OPTION/-- &/' \
| sed -E "s/^GRANT (.+) ON (.+) \"(information_schema|pg_*|_analytics|_realtime|_supavisor|auth|etl|extensions|pgbouncer|realtime|storage|supabase_functions|supabase_migrations|cron|dbdev|graphql|graphql_public|net|pgmq|pgsodium|pgsodium_masks|pgtle|repack|tiger|tiger_data|timescaledb_*|_timescaledb_*|topology|vault)\"/-- &/" \
| sed -E "s/^REVOKE (.+) ON (.+) \"(information_schema|pg_*|_analytics|_realtime|_supavisor|auth|etl|extensions|pgbouncer|realtime|storage|supabase_functions|supabase_migrations|cron|dbdev|graphql|graphql_public|net|pgmq|pgsodium|pgsodium_masks|pgtle|repack|tiger|tiger_data|timescaledb_*|_timescaledb_*|topology|vault)\"/-- &/" \
| sed -E 's/^(CREATE EXTENSION IF NOT EXISTS "pg_tle").+/\1;/' \
| sed -E 's/^(CREATE EXTENSION IF NOT EXISTS "pgsodium").+/\1;/' \
| sed -E 's/^(CREATE EXTENSION IF NOT EXISTS "pgmq").+/\1;/' \
| sed -E 's/^COMMENT ON EXTENSION (.+)/-- &/' \
| sed -E 's/^CREATE POLICY "cron_job_/-- &/' \
| sed -E 's/^ALTER TABLE "cron"/-- &/' \
| sed -E 's/^SET transaction_timeout = 0;/-- &/' \
| sed -E ""

## Dump roles ##

echo "-- dumping roles"

# Explanation of pg_dumpall flags:
#
#   --roles-only     only include create, alter, and grant role statements
#
# Explanation of sed substitutions:
#
#   - do not emit psql meta commands
#   - do not create or alter reserved roles as they are blocked by supautils
#   - explicitly allow altering safe attributes, ie. statement_timeout, pgrst.*
#   - discard role attributes that require superuser, ie. nosuperuser, noreplication
#   - do not alter membership grants by supabase_admin role
pg_dumpall \
    --roles-only \
    --role "postgres" \
    --quote-all-identifier \
    --no-role-passwords \
    --no-comments \
| sed -E 's/^\\(un)?restrict .*$/-- &/' \
| sed -E "s/^CREATE ROLE \"(anon|authenticated|authenticator|cli_login_.*|dashboard_user|pgbouncer|postgres|service_role|supabase_.*|pgsodium_keyholder|pgsodium_keyiduser|pgsodium_keymaker|pgtle_admin)\"/-- &/" \
| sed -E "s/^ALTER ROLE \"(anon|authenticated|authenticator|cli_login_.*|dashboard_user|pgbouncer|postgres|service_role|supabase_.*|pgsodium_keyholder|pgsodium_keyiduser|pgsodium_keymaker|pgtle_admin)\"/-- &/" \
| sed -E "s/ (NOSUPERUSER|NOREPLICATION)//g" \
| sed -E "s/^-- (.* SET \"(pgaudit.*|pgrst.*|session_replication_role|statement_timeout|track_io_timing)\" .*)/\1/" \
| sed -E "s/GRANT \".*\" TO \"(anon|authenticated|authenticator|cli_login_.*|dashboard_user|pgbouncer|postgres|service_role|supabase_.*|pgsodium_keyholder|pgsodium_keyiduser|pgsodium_keymaker|pgtle_admin)\"/-- &/" \
| sed -E "/^--/d" \
| uniq

## Dump data ##

echo "-- dumping data"

# Disable triggers so that data dump can be restored exactly as it is
echo "SET session_replication_role = replica;
"

# Explanation of pg_dump flags:
#
#   --exclude-schema omit data from internal schemas as they are maintained by platform
#   --exclude-table  omit data from migration history tables as they are managed by platform
#   --column-inserts only column insert syntax is supported, ie. no copy from stdin
#   --schema '*'     include all other schemas by default
#
# Explanation of sed substitutions:
#
#   - do not emit psql meta commands
#
# Never delete SQL comments because multiline records may begin with them.
pg_dump \
    --data-only \
    --quote-all-identifier \
    --role "postgres" \
    --table "public.frequency" \
    --table "public.checklists" \
    --table "public.checklist_steps" \
    --table "public.checklist_steps_orders" \
    --table "public.point_of_interest_types" \
    --table "public.resource_types" \
    --table "public.resources" \
    --table "public.resources_cv" \
    --table "public.resource_types" \
    --table "public.role_permissions" \
    --column-inserts --rows-per-insert 100000 \
| sed -E 's/^\\(un)?restrict .*$/-- &/'

# REMOVE
# --exclude-schema "information_schema|pg_*|graphql|graphql_public|pgsodium|pgsodium_masks|pgtle|repack|tiger|tiger_data|timescaledb_*|_timescaledb_*|topology|vault|etl|extensions|pgbouncer|realtime|supabase_migrations|_analytics|_realtime|_supavisor" \
# --exclude-table "auth.schema_migrations" \
# --exclude-table "storage.migrations" \
# --exclude-table "supabase_functions.migrations" \
# --schema "*" \

# Reset session config generated by pg_dump
echo "RESET ALL;"
