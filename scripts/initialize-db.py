import argparse
import json
import sys
import uuid
import subprocess
from pathlib import Path
from supabase import create_client, Client

### NOT READY YET - needs stable schema and initial data load.

# INTENTION
# This is the code that loads the db and initializes a new admin user.
# depends on supabase start
# calls out to script -> scripts/db-load.sh seed.sql.gz -> depends load
# creates admin user from neighborhood.json

default_config = {
  "is_safe": "true",
  "needs_help": "false",
  "nickname": "",
}

prompts = {
  "neighborhood": "What is the name of the neighborhood?",
  "location": "What is the latitude and longitude of the location? lat, long",
  "supabaseUrl": "What is the public URL of the supabase API?",
}

admin_prompts = {
  "given_name": "What is the adminstrator's given name?",
  "family_name": "What is the adminstrator's family name?",
  "email": "What is the adminstrator's email?",
  "password": "What is the adminstrator's initial password?"
}

supabase_fields = {
  "PUBLISHABLE_KEY": "supabaseAnonKey",
  "SECRET_KEY": "secret_key",
  "API_URL": "supabaseUrl",
}


def load_supabase_keys() -> dict:
  # supabase status -o json
  result = subprocess.check_output('supabase status -o json', shell=True)
  # parse the json
  fields = json.loads(result)
  # pick out supabase_fields
  return {v: fields[k] for k, v in supabase_fields.items()}


def overlay_supabase_config(config:dict) -> dict:
  supabase_data = load_supabase_keys()
  supabase_data.update(default_config) # bring in the defaults
  for k, v in supabase_data.items():
    if k not in config:
      config[k] = v
  return config

def prompt_config(config:dict, ask_admin:bool) -> dict:
  for key, prompt in prompts.items():
    # check if key is set in config
    if key not in config:
      # if not, prompt for if
      config[key] = input(prompt + "  ")

  if ask_admin:
    # collect the admin details
    for key, prompt in admin_prompts.items():
      # check if key is set in config
      if key not in config:
        # if not, prompt for if
        config[key] = input(prompt + "  ")

  return config


def baseline_config() -> dict:
  config = {}
  config.update(default_config)
  config.update(load_supabase_keys())
  return config


def load_config(filename:str) -> dict:
  filepath = Path(filename)
  if filepath.exists():
    with open(filepath) as f:
      config = json.load(f)
      return overlay_supabase_config(config)
  else:
    return baseline_config()


def get_supabase(config) -> Client:
  url: str = config.get("supabaseUrl")
  key: str = config.get("secret_key")
  # TODO check and fail fast
  return create_client(url, key)


def load_seed_data(seed_file:str) -> None:
  filepath = Path(seed_file)
  if filepath.exists():
    seed_cmd = f"./scripts/db-load.sh {seed_file}"
    result = subprocess.check_output(seed_cmd, stderr=subprocess.STDOUT, shell=True)
    print("Loaded DB seed data from", filepath.absolute())
  else:
    print("Cannot find expected DB seed file:", filepath.absolute())


def is_true(value:str)->bool:
  return value.lower() in ['true', '1', 't', 'y', 'yes']


def create_admin_user(db:Client, config:dict) -> dict | None:
  email = config["email"]
  password = config["password"]

  response = db.auth.admin.create_user(
    {
        "email": email,
        "password": password,
        "email_confirm": True,
    }
  )

  if response and response.user:
    user = response.user
    user_id = user.id

    # create profile
    response = db.table("user_profiles").insert({
      "id": user_id,
    }).execute()

    # create role
    response = db.table("user_roles").insert({
      "id": str(uuid.uuid4()),
      "user_profile_id": user_id,
      "role": "com_admin", # community admin
    }).execute()

    # create people entry
    people_id = str(uuid.uuid4())
    response = db.table("people").insert({
      "id": people_id,
      "user_profile_id": user_id,
      "given_name": config.get("given_name"),
      "family_name": config.get("family_name"),
      "nickname": config.get("nickname"),
      "is_safe": config.get("is_safe"),
      "needs_help": config.get("needs_help"),
    }).execute()

    person = db.table("people").select().eq("id", people_id).maybe_single().execute()
    return person


appconfig_file = "src/support_sphere/lib/constants/appconfig.dart"

dart_template = """
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

def dart_config_code(config:dict) -> str:
  # fix location from string to array
  loc_str = config['location']
  location = [float(value.strip()) for value in loc_str.split(',')]
  config['location'] = location
  return dart_template.format_map(config)


def main() -> int:
  # parse args
  parser = argparse.ArgumentParser()
  parser.add_argument("-f", "--neighborhood_file", default="neighborhood.json", help="Neighborhood metatdata JSON file")
  parser.add_argument("-w", "--write", action="store_true", help="Write output")
  parser.add_argument("--admin", action="store_true", help="Collect information to initialize")
  parser.add_argument("--seed", default="seed.sql.gz", help="GZipped SQL file to seed the initial database")
  parser.add_argument("--generate", action="store_true", help="If set, generate the Dart binding code for the client.")

  args = parser.parse_args()

  # load config settings
  config = load_config(args.neighborhood_file)

  # prompt user for missing config values
  config = prompt_config(config, args.admin)

  # load seed data
  load_seed_data(args.seed)

  # create admin user
  if args.admin:
    db = get_supabase(config)
    user = create_admin_user(db, config)
    print("Created admin user")

  # write the file
  if args.write:
    with open(args.neighborhood_file, 'w') as f:
      json.dump(config, f, ensure_ascii=False, indent=4)
      print("Wrote neighborhood config values to", args.neighborhood_file)

  if args.generate:
    gen_code = dart_config_code(config)
    with open(appconfig_file, 'w') as outfile:
      outfile.write(gen_code)
    print("Generated dart config constants:", appconfig_file)


  return 0


if __name__ == '__main__':
    sys.exit(main())