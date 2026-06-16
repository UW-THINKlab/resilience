#!/usr/bin/env bash

# Restore the resilience DB from backup

project="resilience"
container_name="supabase_db_$project"

sql_file=$1
if [ ! -f "$sql_file" ]; then
    echo "Expected file not found: $sql_file"
    exit 1
fi

export PGUSER=${PGUSER:-supabase_admin}

#supabase db reset --local

gunzip -c $sql_file | docker exec -i $container_name bash -c "psql -U $PGUSER postgres"
