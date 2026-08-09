import subprocess
import json
import geojson
from supabase import create_client, Client


def local_supabase_config() -> dict:
    supabase_fields = {
        "PUBLISHABLE_KEY": "supabaseAnonKey",
        "SECRET_KEY": "secret_key",
        "API_URL": "supabaseUrl",
    }
    # get the supabase env
    status_cmd = 'supabase status -o json'
    result = subprocess.check_output(status_cmd, shell=True)
    # parse the json
    fields = json.loads(result)
    # pick out supabase_fields
    return {v: fields[k] for k, v in supabase_fields.items()}


def local_supabase() -> Client:
    config = local_supabase_config()

    url = config.get("supabaseUrl")
    if url is None:
        print("Cannot find supabaseUrl")

    key = config.get("secret_key")
    if key is None:
        print("Cannot find secret_key in config")

    return create_client(url, key)


def load_geojson(geojson_file):
    with open(geojson_file) as f:
        return geojson.load(f)


def load_json(filename:str) -> dict:
    with open(filename) as f:
        return json.load(f)