import argparse
import sys
import json
import uuid
from pathlib import Path
from geomet import wkt

from utils import local_supabase, load_geojson

from supabase import  Client


def load_pois(db:Client, poi_file:str):
    geojson = load_geojson(poi_file)

    check_fields = {
        "display": "name",
        "NAME": "name",
        "ADDRESS": "address",
        "type": "point_type_name",
    }

    for feature in geojson.features:
        point_of_interest = {
            "id": str(uuid.uuid4()),
            "geom": feature.geometry, # TODO check it's a POINT
            "address": "n/a",
            "point_type_name": "community center", # TODO better default?
        }

        for k, v in check_fields.items():
            prop = feature.properties.get(k)
            if prop:
                point_of_interest[v] = prop

        db.table("point_of_interests").insert(point_of_interest).execute()

    print("Loaded", len(geojson.features), "points of interest")


def load_clusters(db:Client, cluster_file:str) -> dict:
    geojson = load_geojson(cluster_file)

    check_fields = {
        "Name": "name",
    }

    clusters = {} # name: id

    for feature in geojson.features:
        if feature.geometry.type == "Polygon":
            cluster = {
                "id": str(uuid.uuid4()),
                "geom": feature.geometry,
            }

            for k, v in check_fields.items():
                prop = feature.properties.get(k)
                if prop:
                    cluster[v] = prop

            response = db.table("clusters").insert(cluster).execute()

            # capture new cluster id
            clusters[response.data[0]['name']] = response.data[0]['id']

    print("Loaded", len(geojson.features), "clusters")
    return clusters


def load_households(db:Client, cluster_ids:dict, household_file:str):
    geojson = load_geojson(household_file)

    check_fields = {
        "TAXPAYER N": "name",
        "ADDRESS": "address",
        "CLUSTER": "cluster_num",
    }

    for feature in geojson.features:
        # SRID hack for db constraint
        if feature.geometry:
            db_geom_str = "SRID=4326;" + wkt.dumps(feature.geometry)
        else:
            print(f"No geometry for {feature.properties['ADDRESS']}")

        household = {
            "id": str(uuid.uuid4()),
            "geom": db_geom_str,
        }

        for k, v in check_fields.items():
            prop = feature.properties.get(k)
            if prop:
                household[v] = prop

        cluster_name = f"c_{household['cluster_num']}"
        cluster_id = cluster_ids.get(cluster_name)
        if cluster_id is None:
            print("No cluster set for", household)
        else:
            household["cluster_id"] = cluster_id
            del household["cluster_num"]
            db.table("households").insert(household).execute()

    print("Loaded", len(geojson.features), "households")


def load_checklists(db:Client, checklist_file:str):
    """
    Populate checklists to the database.
    """
    with open(checklist_file) as f:
        data = json.load(f)

    for ch in data['checklists']:

        # Add frequency for checklist
        result = db.table("frequency").insert({
            "name": ch['frequency']['name'],
            "num_days": ch['frequency']['num_days'],
        }).execute()
        # get id
        frequency_id = result[0].id

        result = db.table("checklists").insert({
            "title": ch['title'],
            "description": ch['purpose'],
            "frenquency_id": frequency_id,
        }).execute()
        # get id
        checklist_id = result[0].id

        # Add steps for checklist
        for idx, st in enumerate(ch['steps']):
            result = db.table("checklist_steps").insert({
                "checklist_id": checklist_id,
                "description": ch['description']
            }).execute()
            # get id
            step_id = result[0].id

            db.table("checklist_steps_order").insert({
                "checklist_id": checklist_id,
                "checklist_step_id": step_id,
                "priority": idx,
            }).execute()
            # get id
            #step_order_id = result[0].id


def load_neighborhood_geojson(supabase:Client, neighborhood_dir:Path) -> list:
    processed = []

    pois = Path(neighborhood_dir, "points-of-interest.geojson").resolve()
    if pois.exists():
        load_pois(supabase, pois)
        processed.append(pois.name)

    clusters = Path(neighborhood_dir, "clusters.geojson").resolve()
    if clusters.exists():
        clusters = load_clusters(supabase, clusters)
        processed.append(clusters)

    else:
        clusters = {}

    households = Path(neighborhood_dir, "households.geojson").resolve()
    if households.exists():
        load_households(supabase, clusters, households)
        processed.append(households.name)

    leftovers = []
    files = neighborhood_dir.glob("*.geojson")

    for file in files:
        file = file.resolve()
        if file.name not in processed:
            leftovers.append(file)

    return leftovers


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument("--pois", help="Points-of-interest GEOJSON file")
    parser.add_argument("--clusters", help="Neighborhood cluster GEOJSON file")
    parser.add_argument("--households", help="Neighborhood households GEOJSON file")
    parser.add_argument("--checklists", help="Emergency preparedness checklist JSON file")
    parser.add_argument("-p", "--project", default=None, help="Project directory with neighboorhood and geojson files")
    args = parser.parse_args()

    supabase = local_supabase()

    if args.project:
        load_neighborhood_geojson(supabase, Path(args.project))

    if args.pois:
        load_pois(supabase, args.pois)

    if args.clusters:
        clusters = load_clusters(supabase, args.clusters)

    if args.households:
        load_households(supabase, clusters, args.households)

    if args.checklists:
        load_checklists(supabase, args.checklists)

    return 0


if __name__ == '__main__':
    sys.exit(main())