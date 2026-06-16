#!/usr/bin/env bash

# Restore the resilience DB from backup

project="resilience"
container_name="supabase_db_$project"

# Source - https://stackoverflow.com/a/677212
CLI="supabase"

if ! command -v $CLI >/dev/null 2>&1
then
    echo "$CLI could not be found. See https://supabase.com/docs/guides/local-development/cli/getting-started"
    exit 1
fi

# check script paramater for sql file name
if [ -z ${1+x} ]; then
  sql_file="data.sql.gz"
else
  sql_file=$1
fi

if [ ! -f "$sql_file" ]; then
    echo "Expected file not found: $sql_file"
    exit 1
fi

export PGUSER=${PGUSER:-supabase_admin}

supabase db reset --local

gunzip -c $sql_file | docker exec -i $container_name bash -c "psql -U $PGUSER postgres"
