import argparse
import sys
import csv
import json
from geojson import Feature, Point, FeatureCollection


_Categories = {
    "Natural": "park",
    "State park": "park",
    "Church": "church",
    "Wildlife refuge": "park",
    "State Park": "park",
    "Business": "store",
    "Beach": "park",
    "Park": "park",
    "Campground": "park",
    "Bus Stop": "visitor-service",
    "Regional bus hub": "visitor-service",
    "Transportation service": "visitor-service",
    "Fire Station and EMS": "fire-department",
    "Fire Station": "fire-department",
    "Grocery store": "store",
    "Gasoline and convenience store": "store",
    "Visitor center": "visitor-service",
    "Water treatment plant": "utility",
    " Water utility ": "utility",
    "Medical clinic": "hospital",
    "Garden": "park",
    "School": "school",
    "Community service": "community center",
    "Public Library": "library",
    "Library": "library",
    "School and Evacuation Structure": "visitor-service",
    "Evacuation Structure": "visitor-service",
    "Coastal Infrastructure / Shoreline Protection": "visitor-service",
    "Museum": "museum",
    "Event Hall": "hall",
    "Waterfront": "park",
    "Historic lighthouse": "museum",
    "City Hall": "hall",
    "City Park": "park",
    "Athletic Field": "park",
    "Hospital": "hospital",
    "Food Bank": "foodbank",
    "Outpatient Clinic": "clinic",
    "Recycling / waste management": "utility",
    "Waste management": "utility",
    "Day care": "school",
    "Tourist attraction": "visitor-service",
    "Social services": "clinic",
    "Social and Health Services": "clinic",
    "Electric utility": "utility",
    "Waterfront viewing tower": "community center",
    "Public works department": "utility"
}


def type_from_properties(properties:dict) -> str:
    # check Notes, Subcategory, Category
    result = _Categories.get(properties['Notes'],
        _Categories.get(properties['Subcategory'],
            _Categories.get(properties['Category'], "other")))

    #if result == "default":
    #    print("Unknown type:", properties['Notes'], properties['Subcategory'], properties['Category'])

    return result


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_file", help="CSV file to convert to GEOJSON file")
    args = parser.parse_args()

    features = []  # list of features

    with open(args.csv_file) as f:
        csv_reader = csv.DictReader(f)

        for row in csv_reader:
            # row: Asset Name,Latitude,Longitude,Category,Subcategory,Status,Tier,Jurisdiction,Notes,Source
            # create the point geometry, and remove those fields from the row
            lat = float(row['Latitude'])
            del(row['Latitude'])
            long = float(row['Longitude'])
            del(row['Longitude'])
            point = Point((long, lat))
            # derive a type from properties
            row['type'] = type_from_properties(row)
            #print(row['type']) # "<-", row['Notes'], row['Subcategory'], row['Category'])
            # create a feature with the point and leftover properties
            feature = Feature(geometry=point, properties=row)
            features.append(feature)

    collection = FeatureCollection(features)
    print(json.dumps(collection, indent=4))
    return 0


if __name__ == '__main__':
    sys.exit(main())