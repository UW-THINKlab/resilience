#!/usr/bin/env bash

# Restore the resilience DB from backup

pod_name=$(kubectl get pods | grep supabase-supabase-db | grep Running | cut -f1 -d' ')

backup_file=$1
if [ ! -f "$backup_file" ]; then
    echo "Expected file not found: $backup_file"
    exit 1
fi

export PGUSER=${PGUSER:-postgres} # supabase_admin?

echo Restoring $pod_name from $backup_file

gunzip -c $backup_file | kubectl exec -it $pod_name -- bash -c "psql -U $PGUSER $PGDATABASE"
