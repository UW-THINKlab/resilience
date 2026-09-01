#!/usr/bin/env bash

set -euo pipefail

# uses supabase CLI - https://supabase.com/docs/guides/local-development/cli/getting-started

# Source - https://stackoverflow.com/a/677212
CLI="supabase"

if ! command -v $CLI >/dev/null 2>&1
then
    echo "$CLI could not be found. See https://supabase.com/docs/guides/local-development/cli/getting-started"
    exit 1
fi

project_dir=$(dirname $(dirname "$0"))
backup_file="data.sql"

# Source - https://stackoverflow.com/a/13864829
# Posted by Lionel, modified by community. See post 'Timeline' for change history
# Retrieved 2026-06-15, License - CC BY-SA 4.0
if [ -z ${1+x} ]; then
  backup_file="data.sql"
else
  backup_file=$1
fi

# dump schema
$CLI --workdir $project_dir db dump --local > "$backup_file"

# dump data
$CLI --workdir $project_dir db dump --local --use-copy --data-only >> "$backup_file"

# zip it
gzip "$backup_file"
