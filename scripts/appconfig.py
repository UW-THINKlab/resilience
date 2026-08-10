import argparse
import json
import os
import sys
from pathlib import Path
from dotenv import load_dotenv

## params
# -o outputfile
# --json (default)
# --dart - generate dart code
# intended use: generate new appconfig from someplace.json
# appconfig someplace.json --dart -o src/support_sphere/lib/constants/appconfig.dart

# Manage the application configuration
# assumes supabase is installed

flutter_project = "src/support_sphere"
appconfig_dart_file = flutter_project + "/lib/constants/appconfig.dart"
assets_dir = flutter_project + "/assets"

_dart_template = """
// WARNING - This is a generated file. Do not edit. Do not commit to source control.
// Generate this file with:
//
//     pixi run -e supabase config -f <neighborhood.json>

import 'package:latlong2/latlong.dart' show LatLng;

class AppConfig {{
  static const String neighborhood = "{neighborhood}";
  static const LatLng location = LatLng({location[1]}, {location[0]});
  static const String supabaseUrl = "{supabaseUrl}";
  static const String supabaseAnonKey = "{supabaseAnonKey}";
}}
"""


def emit_dart_code(config) -> str:
    return _dart_template.format_map(config)


def write_dart_code(config: dict, filename: str = appconfig_dart_file):
    gen_code = emit_dart_code(config)
    with open(filename, 'w') as outfile:
      outfile.write(gen_code)
    print("Generated dart config constants:", filename)


def copy_assets(files:list[Path], target:str):
  for file in files:
    path = Path(target, file.name)
    #shutil.copyfile(file, path)
    print(f"Copied asset from {file} to {path}")


def load_from_env():
    load_dotenv()

    # build a config structure from ENV VARS
    location = os.environ.get("NEIGHBORHOOD_LOCATION")
    if location:
        long_lat = location.split(",")
        location_pair = [float(long_lat[0].strip()), float(long_lat[1].strip())]

    name = os.environ.get("NEIGHBORHOOD_NAME")
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_ANON_KEY")

    assert name is not None
    assert url is not None
    assert key is not None

    config = {
        "neighborhood": name,
        "location": location_pair,
        "supabaseUrl": url,
        "supabaseAnonKey": key,
    }
    return config


def load_config(filename: str) -> dict:
    filepath = Path(filename)
    if filepath.exists():
        with open(filepath) as f:
            config = json.load(f)
            # special case: location might be a string instead of a location array
            # if so, convert to [float]
            config['location'] = location_pair(config['location'])

            return config
    else:
        return {}


def location_pair(location) -> [float]:
    if isinstance(location, str):
        long_lat = location.split(",")
        return [float(long_lat[0].strip()), float(long_lat[1].strip())]
    elif isinstance(location, [float]):
        return location
    else:
        print("Unknown location:", type(location), location)


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f",
        "--neighborhood_file",
        default="neighborhood.json",
        help="Neighborhood metatdata JSON file.",
    )
    parser.add_argument(
        "-o", "--output", default=None, help="Write output to a specific file"
    )
    parser.add_argument("--dart", action="store_true", help="Generate Dart output")
    parser.add_argument(
        "--from_env",
        action="store_true",
        help="Load neighborhood metatdata from env vars: NEIGHBORHOOD_NAME, NEIGHBORHOOD_LOCATION, SUPABASE_URL, SUPABASE_ANON_KEY",
    )
    args = parser.parse_args()

    if args.from_env:
        config = load_from_env()
    else:
        config = load_config(args.neighborhood_file)

    if args.dart:
        output = emit_dart_code(config)
    else:
        output = json.dumps(config, indent=4)

    if args.output:
        with open(args.output, "w") as outfile:
            outfile.write(output)
        print(f"Generated dart output to {args.output}")
    else:
        print(output)

    return 0


if __name__ == "__main__":
    sys.exit(main())
