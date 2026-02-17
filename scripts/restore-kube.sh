#!/usr/bin/env bash

# Restore the resilience DB from backup

pod_name=$(kubectl get pods | grep supabase-supabase-db | cut -f1 -d' ')
backup_file=$1
user=supabase_admin

echo Restoring $pod_name from $backup_file

gunzip -c $backup_file | kubectl exec -it $pod_name -- bash -c "psql -U $user $PGDATABASE"
