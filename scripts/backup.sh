#!/usr/bin/env bash

# Backup the resilience DB using supabase tool

backup_file="resilience-backup-`date +%Y-%m-%d`.sql"
supabase db dump --local --keep-comments > $backup_file
supabase db dump --local --role-only >> $backup_file
supabase db dump --local --data-only >> $backup_file
gzip $backup_file