import argparse
import json
import os
import pprint

## params
# -o outputfile
# --json (default)
# --dart - generate dart code
# intended use: generate new appconfig from someplace.json
# appconfig someplace.json --dart -o src/support_sphere/lib/constants/appconfig.dart

# Manage the application configuration
# assumes supabase is installed


# get the publishable key
env_cmd = "supabase status -o env"

dart_code = """
import 'package:latlong2/latlong.dart' show LatLng;

// INTENTION: AppConfig _instance should be generated with a specific build script, from config.

class AppConfig {
  static const String neighborhood = "{neighborhood}";
  static const LatLng location = LatLng({location[0]}, {location[1]});
  static const String supabaseUrl = "http://{supabaseUrl}";
  static const String supabaseAnonKey = "{supabaseAnonKey}";
}
"""

# load expected config file
file_name = "neighborhood.json";
# TODO: cmd arg

with open(file_name) as f:
    config = json.load(f)
    #print(config)

    #supa_json = os.popen(env_cmd).read()
    #print(supa_json)

    #config['supabaseAnonKey'] = supa_json['PUBLISHABLE_KEY']

    #pprint.pprint(config)