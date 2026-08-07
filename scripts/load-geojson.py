import argparse
import os
import sys
import geojson
import uuid
import json
import subprocess
from supabase import create_client, Client


_ASSET_CATEGORIES = {
    "Coast Guard": ["life-ring", "blue"],
    "Food": ["utensils", "green"],
    "Hotels": ["hotel", "green"],
    "Lighthouse": ["lightbulb", "yellow"],
    "Parks": ["tree", "green"],
    "After School": ["school", "blue"],
    "Shoalwater": ["water", "green"],
    "Library": ["book-open-reader", "blue"],
    "Brady's Oysters": ["utensils", "green"],
    "_": ["question", "yellow"]
}


def load_geojson(geojson_file):
    with open(geojson_file) as f:
        return geojson.load(f)


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
    key = os.environ.get("secret_key")
    if key is None:
        print("Cannot find secret_key in config")
    return create_client(url, key)


def load_neighborhood(filename:str) -> dict:
    with open(filename) as f:
        return json.load(f)


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument("--poi_file", default="points-of-interest.geojson", help="Points-of-interest GEOJSON file")
    parser.add_argument("--neighborhood_file", default="neighborhood.json", help="Neighboorhood file")
    parser.add_argument("-p", "--project", default=None, help="Project directory with neighboorhood and geojson files")
    args = parser.parse_args()

    #supabase = local_supabase()

    geojson = load_geojson(args.poi_file)

    check_fields = {
        "display": "name",
        "NAME": "name",
        "ADDRESS": "address",
        "type": "point_type_name",
    }

    for feature in geojson.features:
        #print(feature.properties)

        point_of_interest = {
            "id": str(uuid.uuid4()),
            "geom": feature.geometry,
        }

        for k, v in check_fields.items():
            prop = feature.properties.get(k)
            if prop:
                point_of_interest[v] = prop

        print(point_of_interest)
        #supabase.table("point_of_interests").insert(point_of_interest)

    return 0


if __name__ == '__main__':
    sys.exit(main())