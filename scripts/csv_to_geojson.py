import argparse
import sys
import csv
import json
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

_Categories = {
    "Natural": "park",
    "State park": "park",
    "Church": "church",
    "Wildlife refuge": "park",
    "State Park": "park",
    "Business": "business",
    "Beach": "beach",
    "Park": "park",
    "Campground": "camping",
    "Bus Stop": "bus_map_pin",
    "Regional bus hub": "bus_map_pin",
    "Transportation service": "bus_map_pin",
    "Fire Station and EMS": "local_fire_department",
    "Fire Station": "local_fire_department",
    "Grocery store": "grocery",
    "Gasoline and convenience store": "local_convenience_store",
    "Visitor center": "rest_area",
    "Water treatment plant": "water_do",
    " Water utility ": "water_do",
    "Medical clinic": "medical-services",
    "Police Station": "local_police",
    "Garden": "nature",
    "School": "school",
    "Community service": "community-center",
    "Public Library": "library",
    "Library": "library",
    "School and Evacuation Structure": "emergency_home",
    "Evacuation Structure": "emergency_home",
    "Coastal Infrastructure / Shoreline Protection": "emergency_home",
    "Museum": "museum",
    "Event Hall": "account_balance",
    "Waterfront": "beach_access",
    "Historic lighthouse": "lightbulb_circle",
    "City Hall": "location_city",
    "City Park": "park",
    "Athletic Field": "shoe_cleats",
    "Gym": "fitness_center",
    "Hospital": "hospital",
    "Food Bank": "food_bank",
    "Outpatient Clinic": "medical-services",
    "Recycling / waste management": "recycling",
    "Waste management": "delete",
    "Day care": "child_care",
    "Tourist attraction": "attractions",
    "Social services": "help_clinic",
    "Social and Health Services": "help_clinic",
    "Electric utility": "electric_bolt",
    "Waterfront viewing tower": "",

}



def type_from_properties(properties:dict) -> str:
    # check Notes, Subcategory, Category
    result = _Categories.get(properties['Notes'],
        _Categories.get(properties['Subcategory'],
            _Categories.get(properties['Category'], "default")))

    if result == "default":
        print("Unknown type:", properties['Notes'], properties['Subcategory'], properties['Category'])

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
            # create a feature with the point and leftover properties
            feature = Feature(geometry=point, properties=row)
            features.append(feature)

    collection = FeatureCollection(features)
    #print(json.dumps(collection, indent=4))
    return 0


if __name__ == '__main__':
    sys.exit(main())