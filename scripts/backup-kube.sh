#!/usr/bin/env bash

# load the env...
#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#. $SCRIPT_DIR/../.env

# Backup the resilience DB
# FIXME - Load somehow, this is from the sample
PGPASSWORD=example123456

pod_name=$(kubectl get pods | grep supabase-supabase-db | cut -f1 -d' ')
backup_file="resilience-backup-`date +%Y-%m-%d`.sql"

# NOTE: user from values.cloud.yml
db_name=postgres
export PGUSER=postgres


echo Backing up $pod_name into $backup_file ...
kubectl exec -it $pod_name -- bash -c "PGPASSWORD=$DB_PASSWORD pg_dump --schema=public -U $user $db_name" > $backup_file
#kubectl exec -it $pod_name -- bash -c "PGPASSWORD=$DB_PASSWORD pg_dumpall -U $user" > $backup_file
#kubectl exec -it $pod_name -- bash -c "PGPASSWORD=$PGPASSWORD PGUSER=$PGUSER pg_dumpall"

echo done.
