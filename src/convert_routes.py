from os.path import join
import json
import argparse

import pandas as pd
import geopandas as gpd
import shapely.geometry as geo

### Command line
parser = argparse.ArgumentParser(description = "LEAD Converter from JSprit to MATSim")

parser.add_argument("--scenario-path", type = str, required = True)
parser.add_argument("--solution-path", type = str, required = True)
parser.add_argument("--output-path", type = str, required = True)
parser.add_argument("--crs", type = str, required = True)
parser.add_argument("--start-time", type = float, required = False, default = 8.0 * 3600.0)

arguments = parser.parse_args()

### Read data
with open(arguments.solution_path, encoding='utf8') as f:
    solution = json.load(f)

with open(arguments.scenario_path, encoding='utf8') as f:
    scenario = json.load(f)

### Convert data
vehicles = []
speeds = {}

start_time = arguments.start_time

for route in solution["routes"]:
    vehicle_type = None
    stops = []

    # Figure out vehicle type and speed
    for vt in scenario["vehicle_types"]:
        if vt["id"] == route["vehicle_type"]:
            vehicle_type = vt
            break

    if vehicle_type is None:
        raise RuntimeError("Vehicle type {} does not exist in scenario".format(route["vehicle_type"]))

    speeds[route["vehicle_type"]] = vehicle_type["speed_km_h"]

    # Convert coordinates
    df = gpd.GeoDataFrame(pd.DataFrame({
        "geometry": [
            geo.Point(stop["lng"], stop["lat"])
            for stop in route["trajectory"]
        ]
    }), crs = "EPSG:4326").to_crs(arguments.crs)

    # Convert stops
    for stop, geometry in zip(route["trajectory"], df["geometry"]):
        stop_type = None

        if stop["type"] in ("start", "end"):
            stop_type = stop["type"]
        elif stop["type"] == "pickupShipment":
            stop_type = "pickup"
        elif stop["type"] == "deliverShipment":
            stop_type = "delivery"
        else:
            raise RuntimeError("Unknown shop type: {}".format(stop["type"]))

        stops.append({
            "type": stop_type,
            "arrival_time": stop["t0"] + start_time,
            "departure_time": stop["t1"] + start_time,
            "location": {
                "x": geometry.x, "y": geometry.y
            }
        })

    vehicles.append({
        "vehicle_type": vehicle_type["id"],
        "stops": stops
    })

### Prepare and write output
vehicle_types = [
    { "id": id, "speed_km_h": speed }
    for id, speed in speeds.items()
]

output = {
    "vehicle_types": vehicle_types,
    "vehicles": vehicles
}

with open(join(arguments.output_path, "traces.json"), "w+", encoding='utf8') as f:
    json.dump(output, f, indent = 2)
