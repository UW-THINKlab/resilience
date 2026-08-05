import argparse
import json
import os
import sys
import pprint

### NOT READY YET - needs stable schema and initial data load.


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

  print(f"Not yet implemented. {args.neighborhood_file}")
  return 1


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

  return 1 # shouldn't get here


if __name__ == '__main__':
    sys.exit(main())