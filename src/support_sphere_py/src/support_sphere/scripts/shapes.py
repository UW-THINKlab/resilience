import sys
from lxml import etree
import csv

fields = ["name","geom"]


def load_kml_clusters(kmlfile: str):
    """
    Given a (Google Earth) KML file, create a filename.csv with the poly coords pulled from the file
    """
    with open(kmlfile + ".csv", 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fields)
        writer.writeheader()

        root = etree.parse(kmlfile)
        # for each Palcemark tag
        for node in root.iter("{*}Placemark"):
            # parse out a name
            name = ""
            for sub in node.iter("{*}SimpleData"):
                if sub.get("name") == "Name":
                    name = sub.text

            # build a polygon string
            polystr = "POLYGON (("
            for coords in node.iter("{*}coordinates"):
                coords = coords.text.strip()
                for points in coords.split(" "):
                    segs = points.split(",")
                    # NOTE: segs is X,Y,Z. Swap when creating LAT LONG
                    polystr += f"{segs[1]} {segs[0]}, "
            polystr = polystr[:-2] + "))"

            # write the record
            writer.writerow({"name": name, "geom": polystr})


# def load_clusters(shapefile: str):
#     with open(shapefile + ".csv", 'w') as csvfile:
#         clusters = csv.writer(csvfile)
#         #Open the shapefile .shp
#         with fiona.open(shapefile, allow_unsupported_drivers=True) as shapefile:
#             #Iterate over the records
#             for record in shapefile:
#                 # Get the geometry from the record
#                 print(record['geometry'])
#                 name = record['properties']['Name']
#                 geometry = shape(record['geometry'])
#                 clusters.writerow([name, geometry])


def main():
    load_kml_clusters(sys.argv[1])

if __name__ == "__main__":
    main()
