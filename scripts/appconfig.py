import argparse
import json
import os
import sys
from dotenv import load_dotenv

## params
# -o outputfile
# --json (default)
# --dart - generate dart code
# intended use: generate new appconfig from someplace.json
# appconfig someplace.json --dart -o src/support_sphere/lib/constants/appconfig.dart

# Manage the application configuration
# assumes supabase is installed

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


def load_publishable_key() -> str:
  ## FIXME
  # Using the supabase command (or perhaps a grep of .env)
  # the publishable key can be gotten from a running/configured system
  # get the publishable key
  #env_cmd = "supabase status -o env | grep PUBLISHABLE_KEY | cut -d '=' -f 2"
  #supa_json = os.popen(env_cmd).read()
  #print(supa_json)
  #config['supabaseAnonKey'] = supa_json['PUBLISHABLE_KEY']
  #return "jh34kj5h34kjh....fi834kreuhv7378g"
  pass


def load_from_env():
  load_dotenv()

  # build a config structure from ENV VARS
  location = os.environ.get('NEIGHBORHOOD_LOCATION')
  if location:
    long_lat = location.split(',')
    location_pair = [float(long_lat[0].strip()), float(long_lat[1].strip())]

  name = os.environ.get('NEIGHBORHOOD_NAME')
  url = os.environ.get('SUPABASE_URL')
  key = os.environ.get('SUPABASE_ANON_KEY')

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


def main() -> int:
  # parse args
  parser = argparse.ArgumentParser()
  parser.add_argument("-f", "--neighborhood_file", default="neighborhood.json", help="Neighborhood metatdata JSON file.")
  parser.add_argument("-o", "--output", default=None, help="Write output to a specific file")
  parser.add_argument("--dart", action="store_true", help="Generate Dart output")
  parser.add_argument("--from_env", action="store_true", help="Load neighborhood metatdata from env vars: NEIGHBORHOOD_NAME, NEIGHBORHOOD_LOCATION, SUPABASE_URL, SUPABASE_ANON_KEY")
  args = parser.parse_args()

  if args.from_env:
    config = load_from_env()
  else:
    with open(args.neighborhood_file) as f:
      config = json.load(f)

  if args.dart:
    output = emit_dart_code(config)
  else:
    output = json.dumps(config, indent=4)

  if args.output:
    with open(args.output, 'w') as outfile:
      outfile.write(output)
    print(f"Generated dart output to {args.output}")
  else:
    print(output)

  return 0


if __name__ == '__main__':
    sys.exit(main())