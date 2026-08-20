import argparse
import json
import sys
import subprocess
from pathlib import Path
from supabase import Client
from create_user import user_from_dict
from appconfig import write_dart_code, copy_assets, assets_dir, load_config
from utils import local_supabase_config, local_supabase
from load_geojson import load_neighborhood_geojson

# This is the code that loads the db and initializes a new admin user.
# depends on supabase start
# calls out to script -> scripts/db-load.sh seed.sql.gz -> depends load
# creates admin user from neighborhood.json
# loads geojson project files into the db
# copies other geojson files into assets/geojson

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
    "password": "What is the adminstrator's initial password?",
}


def prompt_config(config: dict, ask_admin: bool) -> dict:
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
    config.update(local_supabase_config())
    return config


def load_seed_data(seed_file: str) -> None:
    filepath = Path(seed_file)
    if filepath.exists():
        seed_cmd = f"./scripts/db-load.sh {seed_file}"
        result = subprocess.check_output(seed_cmd, stderr=subprocess.STDOUT, shell=True)
        print("Loaded DB seed data from", filepath.absolute(), result)
    else:
        print("Cannot find expected DB seed file:", filepath.absolute())


def is_true(value: str) -> bool:
    return value.lower() in ["true", "1", "t", "y", "yes"]


def create_admin_user(db: Client, user: dict) -> dict | None:
    # set the role
    user["role"] = "com_admin"
    return user_from_dict(user)


def load_geojson(neighborhood_file:str):
    # using the neighborhood_file parent directory
    # as the project directory
    neighborhood_dir = Path(neighborhood_file).resolve().parent
    loftovers = load_neighborhood_geojson(local_supabase(), neighborhood_dir)

    # geojson files leftover that aren't loaded to db
    # they're copied to assets
    target = assets_dir + "/geojson"
    copy_assets(loftovers, target)


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f",
        "--neighborhood_file",
        default="neighborhood.json",
        help="Neighborhood metatdata JSON file",
    )
    parser.add_argument("-w", "--write", action="store_true", help="Write output")
    parser.add_argument(
        "--admin", action="store_true", help="Collect information to initialize"
    )
    parser.add_argument(
        "--seed",
        default="seed.sql.gz",
        help="GZipped SQL file to seed the initial database",
    )
    parser.add_argument(
        "--generate",
        action="store_true",
        help="If set, generate the Dart binding code for the client.",
    )
    args = parser.parse_args()

    # load config settings
    config = load_config(args.neighborhood_file)

    # prompt user for missing config values
    config = prompt_config(config, args.admin)

    # write the neighborhood file
    if args.write:
        with open(args.neighborhood_file, "w") as f:
            json.dump(config, f, ensure_ascii=False, indent=4)
            print("Wrote neighborhood config values to", args.neighborhood_file)

    # load seed data
    load_seed_data(args.seed)

    # load geojson data
    load_geojson(args.neighborhood_file)

    # create admin user
    if args.admin:
        db = local_supabase()
        user_id = create_admin_user(db, config)
        print("Created admin user", user_id)

    if args.generate:
        write_dart_code(config)

    return 0


if __name__ == "__main__":
    sys.exit(main())
