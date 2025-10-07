#!/usr/bin/env bash

# Backup the resilience DB

# load the env...
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. $SCRIPT_DIR/../.env

pod_name=$(kubectl get pods | grep supabase-supabase-db | cut -f1 -d' ')
backup_file=$1
user=supabase_admin

gunzip -c $backup_file | kubectl exec -it $pod_name -- bash -c "PGPASSWORD=$DB_PASSWORD psql -U $user $DB_NAME"
