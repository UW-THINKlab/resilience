#!/usr/bin/env bash

# To backup the resilience database use: pixi run -e backend db-backup

# This script is intended to be run by cron job. It creates a new backup, and deletes older backups based on ...
# Currently, intended to run daily and keep a weeks' worth of backups.

# Expected crontab config:
# 0 2 * * * /opt/resilience/scripts/rotate-backup-cron.sh >> /var/log/db-backup.log 2>&1

# 0 2 * * * /opt/pixi/bin/pixi run -m /opt/resilience -e backend db-backup >> /var/log/db-backup.log 2>&1

cat > /etc/cron.daily/db-backup <<EOF
/opt/pixi/bin/pixi run -m /opt/resilience -e backend db-backup >> /var/log/db-backup.log 2>&1
EOF


cat > /etc/logrotate.d/db-backup <<EOF
/opt/resilience/backups/* {
  rotate 7
  daily
  nocompress
  missingok
  notifempty
}
EOF


# run db-backup with pixi
/opt/pixi/bin/pixi run -m /opt/resilience -e backend db-backup
