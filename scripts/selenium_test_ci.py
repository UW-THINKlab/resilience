"""Build the Flutter web app, serve it on a free port, run Selenium tests, then tear down."""
import os
import socket
import subprocess
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
SUPPORT_SPHERE = REPO_ROOT / "src" / "support_sphere"


def free_port() -> int:
    with socket.socket() as s:
        s.bind(("", 0))
        return s.getsockname()[1]


def wait_for_server(port: int, timeout: int = 30) -> bool:
    for _ in range(timeout):
        try:
            socket.create_connection(("127.0.0.1", port), 1).close()
            return True
        except OSError:
            time.sleep(1)
    return False


def main() -> int:
    result = subprocess.run(
        ["flutter", "build", "web", f"--dart-define-from-file={REPO_ROOT / '.env'}"],
        cwd=SUPPORT_SPHERE,
    )
    if result.returncode != 0:
        return result.returncode

    port = free_port()
    server = subprocess.Popen(
        ["python3", "-m", "http.server", str(port), "--directory", str(SUPPORT_SPHERE / "build" / "web")]
    )

    try:
        if not wait_for_server(port):
            print(f"Server on port {port} did not become ready in time", file=sys.stderr)
            return 1

        return subprocess.run(
            ["pytest", "tests/selenium/", "-v", "--html=tests/selenium/report.html", "--self-contained-html"],
            cwd=REPO_ROOT,
            env={**os.environ, "APP_URL": f"http://127.0.0.1:{port}"},
        ).returncode
    finally:
        server.terminate()
        server.wait()


if __name__ == "__main__":
    sys.exit(main())
