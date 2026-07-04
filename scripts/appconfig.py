import argparse
import json
import os
import sys
import pprint

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
//     pixi run -e supabase config <neighborhood.json>

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


def main() -> int:
  # parse args
  parser = argparse.ArgumentParser()
  parser.add_argument("neighborhood_file", default="neighborhood.json", help="Neighborhood metatdata JSON file.")
  parser.add_argument("-o", "--output", default=None, help="Write output to a specific file")
  parser.add_argument("--dart", action="store_true", help="Generate Dart output")
  args = parser.parse_args()

  with open(args.neighborhood_file) as f:
    config = json.load(f)

    if args.dart:
      output = emit_dart_code(config)
      print(f"type:{type(output)}, value:{output}")
    else:
      output = json.dumps(config, indent=4)
      print(f"type:{type(output)}, value:{output}")

    if args.output:
      #with open(args.output, 'w') as output:
      #  f.write(str(output))
      print(f"Generated dart output to {args.output}")
    else:
      print(output)

    return 0

  return 1 # shouldn't get here


if __name__ == '__main__':
    sys.exit(main())