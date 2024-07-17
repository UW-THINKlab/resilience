import os
import platform
import urllib.request
from urllib.request import urlretrieve
import json
import shutil
from pathlib import Path
from tempfile import TemporaryDirectory
import subprocess
from rich import print

CONDA_PREFIX = Path(os.environ.get('CONDA_PREFIX'))
PIXI_PROJECT_ROOT = Path(os.environ.get('PIXI_PROJECT_ROOT'))

# Setup the flutter directory
FLUTTER_DIR = PIXI_PROJECT_ROOT / '.flutter'

SYSTEM_MAP = {
    'Linux': 'linux',
    'Darwin': 'macos',
}
PLATFORM_UNAME = platform.uname()
PLATFORM_SYSTEM = PLATFORM_UNAME.system
PLATFORM_ARCH = PLATFORM_UNAME.machine
OS_NAME = SYSTEM_MAP.get(PLATFORM_SYSTEM, None)
if OS_NAME is None:
    raise Exception(f"Unsupported platform: {PLATFORM_SYSTEM}")

MANIFEST_BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"
MANIFEST_JSON_PATH=f"releases_{OS_NAME}.json"
MANIFEST_URL = f"{MANIFEST_BASE_URL}/{MANIFEST_JSON_PATH}"

# Bin directory destination
destination = (CONDA_PREFIX / "bin").resolve()
if not (destination / "flutter").exists():
    FLUTTER_DIR.mkdir()
    # Get the latest stable release
    print(f"1) Fetching latest stable release from {MANIFEST_URL}")
    with urllib.request.urlopen(MANIFEST_URL) as url:
        manifest_data = json.load(url)
        latest_stable_hash = manifest_data['current_release']['stable']

        # Get all the latest stable releases
        latest_releases = [release for release in manifest_data['releases'] if release['hash'] == latest_stable_hash]
        if len(latest_releases) == 0:
            raise Exception(f"Could not find latest stable release with hash {latest_stable_hash}")
        
        # Get the latest release for the current platform
        if PLATFORM_ARCH == 'arm64':
            latest_release = next(release for release in latest_releases if release['dart_sdk_arch'] == 'arm64')
        else:
            latest_release = next(release for release in latest_releases if release['dart_sdk_arch'] == 'x64')
        latest_archive = f"{manifest_data['base_url']}/{latest_release['archive']}"
    
    print(f"2) Downloading latest stable release from {latest_archive}")
    # Download the latest release
    with TemporaryDirectory() as tempdir:
        temp_path = Path(tempdir)
        filename = os.path.basename(latest_archive)
        path, headers = urlretrieve(latest_archive, (temp_path / filename).resolve())
        if filename.endswith('.zip'):
            import zipfile
            with zipfile.ZipFile(path, 'r') as zip_ref:
                zip_ref.extractall(FLUTTER_DIR)
        
        # Remove the downloaded file
        Path.unlink(path)

    print("3) Setting up flutter")
    # Create a symlink to the flutter directory
    source = (FLUTTER_DIR / "flutter" / "bin").resolve()

    # Make all the files executable
    subprocess.Popen(["chmod", "-L", "-R", "+x", str(source)])
    
    print(f"4) Creating symlink from {source} to {destination}")
    # Create the symlink
    subprocess.Popen(["cp", "-rs", "-n", str(source) + '/', str(destination) + '/'])

    print("5) Flutter setup complete :rocket:")
else:
    print(":white_check_mark: Flutter already installed. Skipping installation.")
