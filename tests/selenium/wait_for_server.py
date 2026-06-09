"""Poll until the dev server is accepting connections, then exit 0.

Usage: python3 wait_for_server.py <port> [max_wait_seconds]
"""
import socket
import sys
import time

port = int(sys.argv[1])
timeout = int(sys.argv[2]) if len(sys.argv) > 2 else 30

for _ in range(timeout):
    try:
        socket.create_connection(("127.0.0.1", port), 1).close()
        sys.exit(0)
    except OSError:
        time.sleep(1)

print(f"Server on port {port} did not become ready after {timeout}s", file=sys.stderr)
sys.exit(1)
