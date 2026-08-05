#!/usr/bin/env bash

# To dump a clean copy of resilience database use: pixi run -e backend seed-db
#
# This uses "dump-seed-db.sh" to dump the data needed to initialize a new system,
# with no user data.

script_dir=$(dirname "$0")
dump_script='dump-seed-db.sh'

dump_file="seed.sql.gz"

# Kubernetes version - runs in DB pod
pod_name=$(kubectl get pods | grep supabase-supabase-db | grep Running | cut -f1 -d' ')

echo Creating $dump_file from $pod_name

# Copy the file
# TODO: Might need to resolve file path to script
kubectl cp $script_dir/$dump_script $pod_name:/tmp/$dump_script

# Execute the script on the POD, gzip the results to the file
kubectl exec $pod_name -- /tmp/$dump_script | gzip > $dump_file
