import argparse
import json
import os
import sys
import pprint
import geojson
import uuid
import csv
from geojson import Feature, Point, FeatureCollection

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


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_file", help="CSV file to convert to GEOJSON file")
    args = parser.parse_args()

    features = [] # list of features

    with open(args.csv_file) as f:
        csv_reader = csv.DictReader(f)

        for row in csv_reader:
            # row: Asset Name,Latitude,Longitude,Category,Subcategory,Status,Tier,Jurisdiction,Notes,Source
            name = row['Asset Name'].strip()
            lat = float(row['Latitude'])
            long = float(row['Longitude'])
            point = Point((long, lat))
            feature = Feature(geometry=point, properties={'display': name})
            features.append(feature)

    print(features)

    return 0


if __name__ == '__main__':
    sys.exit(main())