#!/usr/bin/env bash
#
# This script is run in the db container in kubernetes
# There is another script, run from pixi, that:
# 1. finds the correct db pod
# 2. copies _this_ script to the pod    - kubectl cp backup-on-db.sh POD:/tmp/backup-on-db.sh
# 3. runs this script to get the backup - kubectl exec POD -- /tmp/backup-on-db.sh

# Backup the resilience DB using supabase tool

# Original - supabase CLI - https://supabase.com/docs/guides/local-development/cli
# supabase db dump --local --keep-comments > $backup_file
# supabase db dump --local --role-only >> $backup_file
# supabase db dump --local --data-only >> $backup_file
# gzip $backup_file

# NOTE: admin user is needed for dumpall
#user=supabase_admin

# dump schema first
# based on `supabase db dump --dry-run --local`

# set -euo pipefail

PGHOST=${PGHOST:-127.0.0.1}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-postgres} # POSTGRES_USER
PGPASSWORD=${PGPASSWORD:-postgres}
PGDATABASE=${PGDATABASE:-postgres}

# echo db: $PGHOST:$PGPORT
# echo db user: $PGUSER
# echo db name: $PGDATABASE

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
#
#   --schema-only \
pg_dump \
    --username $PGUSER \
    --quote-all-identifier \
    --role "postgres" \
    --exclude-schema "information_schema|pg_*|_analytics|_realtime|_supavisor|auth|extensions|pgbouncer|realtime|storage|supabase_functions|supabase_migrations|cron|dbdev|graphql|graphql_public|net|pgmq|pgsodium|pgsodium_masks|pgtle|repack|tiger|tiger_data|timescaledb_*|_timescaledb_*|topology|vault" \
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
| sed -E "s/^GRANT (.+) ON (.+) \"(information_schema|pg_*|_analytics|_realtime|_supavisor|auth|extensions|pgbouncer|realtime|storage|supabase_functions|supabase_migrations|cron|dbdev|graphql|graphql_public|net|pgmq|pgsodium|pgsodium_masks|pgtle|repack|tiger|tiger_data|timescaledb_*|_timescaledb_*|topology|vault)\"/-- &/" \
| sed -E "s/^REVOKE (.+) ON (.+) \"(information_schema|pg_*|_analytics|_realtime|_supavisor|auth|extensions|pgbouncer|realtime|storage|supabase_functions|supabase_migrations|cron|dbdev|graphql|graphql_public|net|pgmq|pgsodium|pgsodium_masks|pgtle|repack|tiger|tiger_data|timescaledb_*|_timescaledb_*|topology|vault)\"/-- &/" \
| sed -E 's/^(CREATE EXTENSION IF NOT EXISTS "pg_tle").+/\1;/' \
| sed -E 's/^(CREATE EXTENSION IF NOT EXISTS "pgsodium").+/\1;/' \
| sed -E 's/^(CREATE EXTENSION IF NOT EXISTS "pgmq").+/\1;/' \
| sed -E 's/^COMMENT ON EXTENSION (.+)/-- &/' \
| sed -E 's/^CREATE POLICY "cron_job_/-- &/' \
| sed -E 's/^ALTER TABLE "cron"/-- &/' \
| sed -E 's/^SET transaction_timeout = 0;/-- &/' \
| sed -E "/^--/d"
