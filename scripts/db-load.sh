#!/usr/bin/env bash

# Restore the resilience DB from backup

project="resilience"
container_name="supabase_db_$project"

# check script paramater for sql file name
if [ -z ${1+x} ]; then
  sql_file="seed.sql.gz"
else
  sql_file=$1
fi

if [ ! -f "$sql_file" ]; then
    echo "Expected file not found: $sql_file"
    exit 1
fi

export PGUSER=${PGUSER:-supabase_admin}

# NOTE: reset is needed to load a fresh backup.
# In the current version, that dependency has been moved to the
# pixi.toml.
#supabase db reset --local

gunzip -c $sql_file | docker exec -i $container_name bash -c "psql -U $PGUSER postgres"
