import argparse
import json
import os
import sys
import pprint
import geojson
import uuid
from supabase import create_client, Client
from dotenv import load_dotenv


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


def init_supabase() -> Client:
    load_dotenv()
    url = os.environ.get("SUPABASE_URL")
    if url is None:
        print("Cannot find SUPABASE_URL")

    key = os.environ.get("SUPABASE_ANON_KEY")
    if key is None:
        print("Cannot find SUPABASE_ANON_KEY")

    return create_client(url, key)


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument("poi_file", default="points-of-interest.geojson", help="Points-of-interest GEOJSON file")
    args = parser.parse_args()

    supabase = init_supabase()

    geojson = load_geojson(args.poi_file)

    for feature in geojson.features:
        #print(feature.properties)
        category = feature.properties["AssetCate"]
        point_type = _ASSET_CATEGORIES.get(category, _ASSET_CATEGORIES.get("_"))
        point_of_interest = {
            "id": str(uuid.uuid4()),
            "name": feature.properties.get("OWNER"),
            "address": feature.properties.get("SITUS", feature.properties.get("ADDRESS")),
            "geom": feature.geometry,
            "point_type_name": point_type,
        }
        print(point_of_interest)
        #supabase.table("point_of_interests").insert(point_of_interest)

    return 0


if __name__ == '__main__':
    sys.exit(main())