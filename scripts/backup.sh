#!/usr/bin/env bash

# Backup the resilience DB using supabase tool

script_dir=$(dirname "$0")
backup_script='backup-on-db.sh'

echo backup script: $script_dir/$backup_script

# FIXME: Name file based on neighborhood. from... ENV?
# Currently, Neighborhood is hardcoded in code.
neighborhood=Laurelhurst

backup_file="backup-$neighborhood-`date +%Y-%m-%d-%H%M`.sql.gz"

# Kubernetes version - runs in DB pod
pod_name=$(kubectl get pods | grep supabase-supabase-db | grep Running | cut -f1 -d' ')

echo Creating $backup_file from $pod_name

# Copy the file
# TODO: Might need to resolve file path to script
kubectl cp $script_dir/$backup_script $pod_name:/tmp/$backup_script

# Execute the script on the POD, gzip the results to the file
kubectl exec $pod_name -- /tmp/$backup_script | gzip > $backup_file
