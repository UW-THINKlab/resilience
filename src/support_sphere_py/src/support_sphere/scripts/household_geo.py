from pathlib import Path
import csv
import time
import re

from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut
from geopy.location import Location

DATA_DIRECTORY = Path(__file__).parent / 'resources' / 'data'
PROJECT_NAME = "UW ThinkLabs Resilience Project"

# NOTE: address my contain:
# - APT 1
# - UNIT 1
APT_PATTERN = re.compile(r"\s+(APT|UNIT)\s+\w+")

def lookup_address(address: str) -> Location:
    # Before lookup, need to check if addr string ends with
    address = APT_PATTERN.sub(r"", address)

    try:
        geolocator = Nominatim(user_agent=PROJECT_NAME)
        location = geolocator.geocode(address, timeout=5)
        print(location)
        time.sleep(1)
        return location
    except GeocoderTimedOut:
        print("Can't resolve:", address)
        return None


def location_to_wkt(location: Location) -> str:
    if location:
        # lat - N/S -> y, long - E/W -> x
        # POINT ( LONG, LAT )
        return f"POINT ({location.latitude} {location.longitude})"
    else:
        return ""


def load_households(csv_file: str) -> list[dict[str,str]]:
    households = []
    with open(csv_file) as csvfile:
        csv_reader = csv.DictReader(csvfile)

        for row in csv_reader:
            # Get and set cluster
            cluster = row["CLUSTER"]
            address = row['ADDRESS'] + ", Seattle, WA" # NOTE: Loading local data FIXME apts

            geo_str = row['GEOM']
            if len(geo_str) > 0:
                print("Already have:", geo_str)
            else:
                location = lookup_address(address)
                geo_str = location_to_wkt(location)

            household = {
                "CLUSTER": cluster,
                "ADDRESS": row['ADDRESS'],
                "GEOM": geo_str,
            }
            households.append(household)

    return households


def write_households(households: list[dict], fields: list[str], filename: str):
    with open(filename, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fields)
        writer.writeheader()
        for household in households:
            writer.writerow(household)


def main():
    households = load_households(DATA_DIRECTORY/'households-geo.csv')
    fields = ["CLUSTER", "ADDRESS", "GEOM"]
    write_households(households, fields, DATA_DIRECTORY/'households-geom.csv')


if __name__ == "__main__":
    main()
