#!/usr/bin/env bash

# To backup the resilience database use: pixi run -e backend db-backup

# Backup the resilience DB

script_dir=$(dirname "$0")
backup_script='backup-on-db2.sh'

#echo backup script: $script_dir/$backup_script

# FIXME: Name file based on neighborhood. from... ENV?
# Currently, Neighborhood is hardcoded in code.
neighborhood=Laurelhurst
backup_dir=./backups

mkdir -p $backup_dir
backup_file="$backup_dir/backup-$neighborhood-`date +%Y-%m-%d-%H%M`.sql.gz"

# Kubernetes version - runs in DB pod
pod_name=$(kubectl get pods | grep supabase-supabase-db | grep Running | cut -f1 -d' ')

echo Creating $backup_file from $pod_name

# Copy the file
# TODO: Might need to resolve file path to script
kubectl cp $script_dir/$backup_script $pod_name:/tmp/$backup_script

# Execute the script on the POD, gzip the results to the file
kubectl exec $pod_name -- /tmp/$backup_script | gzip > $backup_file
