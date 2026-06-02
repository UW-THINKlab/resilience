-- Configure replication
CREATE USER replicator
WITH REPLICATION
ENCRYPTED PASSWORD 'replicator';

ALTER SYSTEM SET wal_level TO 'hot_standby';
ALTER SYSTEM SET archive_mode TO 'ON';
ALTER SYSTEM SET max_wal_senders TO '3';
ALTER SYSTEM SET wal_keep_segments TO '10';
ALTER SYSTEM SET listen_addresses TO '*';
ALTER SYSTEM SET hot_standby TO 'ON';
ALTER SYSTEM SET archive_command TO 'test ! -f /root/archivedir/%f && cp %p /root/archivedir/%f';
