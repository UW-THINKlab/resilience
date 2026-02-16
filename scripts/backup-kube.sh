#!/usr/bin/env bash

pod_name=$(kubectl get pods | grep supabase-supabase-db | cut -f1 -d' ')
backup_file="resilience-backup-`date +%Y-%m-%d-%H%M`.sql.gz"

# Assumes PGPASSWORD is already set in env, which is true for container instances

# NOTE: admin user is needed for
user=supabase_admin

echo Backing up $pod_name into $backup_file
#kubectl exec -it $pod_name -- bash -c "PGPASSWORD=$DB_PASSWORD pg_dump --schema=public -U $user $db_name" > $backup_file
kubectl exec -it $pod_name -- bash -c "PGUSER=$user pg_dumpall" | gzip > $backup_file

echo done.
