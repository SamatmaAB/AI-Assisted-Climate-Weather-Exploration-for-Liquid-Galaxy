"""
tour_generator.py

Standalone tour generator script and reusable module for generating Google Earth gx:Tour KML files.
Provides functions for creating scientific LookAt exploration stops and complete gx:Playlist tours.
"""

import os

EL_NINO_TOUR_STOPS = [
    {
        "name": "Pacific Overview",
        "latitude": 0.0,
        "longitude": -160.0,
        "altitude": 0.0,
        "range": 12000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    },
    {
        "name": "Western Pacific Warm Pool & Indonesia Drought",
        "latitude": -3.0,
        "longitude": 120.0,
        "altitude": 0.0,
        "range": 3500000.0,
        "tilt": 50.0,
        "heading": 30.0,
        "duration": 9.0
    },
    {
        "name": "Equatorial Pacific Heat Conveyor",
        "latitude": 0.0,
        "longitude": -140.0,
        "altitude": 0.0,
        "range": 5000000.0,
        "tilt": 55.0,
        "heading": 90.0,
        "duration": 11.0
    },
    {
        "name": "Peru Upwelling & Coastal Flooding",
        "latitude": -9.0,
        "longitude": -78.0,
        "altitude": 0.0,
        "range": 2500000.0,
        "tilt": 60.0,
        "heading": 45.0,
        "duration": 9.0
    },
    {
        "name": "North American Teleconnections",
        "latitude": 32.0,
        "longitude": -105.0,
        "altitude": 0.0,
        "range": 4500000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 9.0
    },
    {
        "name": "Pacific Basin Conclusion",
        "latitude": 0.0,
        "longitude": -160.0,
        "altitude": 0.0,
        "range": 12000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    }
]

GULF_STREAM_TOUR_STOPS = [
    {
        "name": "North Atlantic Basin Overview",
        "latitude": 35.0,
        "longitude": -45.0,
        "altitude": 0.0,
        "range": 9000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    },
    {
        "name": "Gulf of Mexico & Florida Straits Origin",
        "latitude": 24.0,
        "longitude": -83.0,
        "altitude": 0.0,
        "range": 2000000.0,
        "tilt": 55.0,
        "heading": 45.0,
        "duration": 9.0
    },
    {
        "name": "Cape Hatteras Coastal Separation",
        "latitude": 35.0,
        "longitude": -73.0,
        "altitude": 0.0,
        "range": 2000000.0,
        "tilt": 50.0,
        "heading": 60.0,
        "duration": 9.0
    },
    {
        "name": "North Atlantic Drift Crossing",
        "latitude": 50.0,
        "longitude": -35.0,
        "altitude": 0.0,
        "range": 3500000.0,
        "tilt": 55.0,
        "heading": 75.0,
        "duration": 11.0
    },
    {
        "name": "European Warming Drift to Norway",
        "latitude": 60.0,
        "longitude": 5.0,
        "altitude": 0.0,
        "range": 2500000.0,
        "tilt": 50.0,
        "heading": 30.0,
        "duration": 9.0
    },
    {
        "name": "North Atlantic Basin Conclusion",
        "latitude": 35.0,
        "longitude": -45.0,
        "altitude": 0.0,
        "range": 9000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    }
]

KUROSHIO_TOUR_STOPS = [
    {
        "name": "Western Pacific Overview",
        "latitude": 28.0,
        "longitude": 135.0,
        "altitude": 0.0,
        "range": 6000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    },
    {
        "name": "Taiwan & Luzon Strait Origin",
        "latitude": 22.0,
        "longitude": 122.0,
        "altitude": 0.0,
        "range": 1800000.0,
        "tilt": 50.0,
        "heading": 30.0,
        "duration": 9.0
    },
    {
        "name": "Okinawa & East China Sea Path",
        "latitude": 27.0,
        "longitude": 128.0,
        "altitude": 0.0,
        "range": 1800000.0,
        "tilt": 55.0,
        "heading": 45.0,
        "duration": 9.0
    },
    {
        "name": "Kuroshio Extension off Japan & Tokyo",
        "latitude": 35.0,
        "longitude": 140.0,
        "altitude": 0.0,
        "range": 2000000.0,
        "tilt": 50.0,
        "heading": 60.0,
        "duration": 11.0
    },
    {
        "name": "North Pacific Drift Outer Reach",
        "latitude": 45.0,
        "longitude": 158.0,
        "altitude": 0.0,
        "range": 3500000.0,
        "tilt": 45.0,
        "heading": 75.0,
        "duration": 9.0
    },
    {
        "name": "Western Pacific Conclusion",
        "latitude": 28.0,
        "longitude": 135.0,
        "altitude": 0.0,
        "range": 6000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    }
]

LA_NINA_TOUR_STOPS = [
    {
        "name": "Pacific Basin Overview",
        "latitude": 0.0,
        "longitude": -160.0,
        "altitude": 0.0,
        "range": 12000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    },
    {
        "name": "Cold Upwelling off South America",
        "latitude": -10.0,
        "longitude": -80.0,
        "altitude": 0.0,
        "range": 2500000.0,
        "tilt": 55.0,
        "heading": 315.0,
        "duration": 9.0
    },
    {
        "name": "Strong Equatorial Trade Winds",
        "latitude": 0.0,
        "longitude": -150.0,
        "altitude": 0.0,
        "range": 5500000.0,
        "tilt": 50.0,
        "heading": 270.0,
        "duration": 11.0
    },
    {
        "name": "Western Pacific Warm Pool & Heavy Rain",
        "latitude": -2.0,
        "longitude": 125.0,
        "altitude": 0.0,
        "range": 3500000.0,
        "tilt": 50.0,
        "heading": 240.0,
        "duration": 9.0
    },
    {
        "name": "Australian Wet Zone & Asian Monsoon",
        "latitude": -18.0,
        "longitude": 140.0,
        "altitude": 0.0,
        "range": 4000000.0,
        "tilt": 45.0,
        "heading": 330.0,
        "duration": 9.0
    },
    {
        "name": "Pacific Basin Conclusion",
        "latitude": 0.0,
        "longitude": -160.0,
        "altitude": 0.0,
        "range": 12000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    }
]

INDIAN_MONSOON_TOUR_STOPS = [
    {
        "name": "South Asian Monsoon Overview",
        "latitude": 20.0,
        "longitude": 78.0,
        "altitude": 0.0,
        "range": 5000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    },
    {
        "name": "Arabian Sea Branch & Western Ghats",
        "latitude": 14.0,
        "longitude": 70.0,
        "altitude": 0.0,
        "range": 2200000.0,
        "tilt": 55.0,
        "heading": 45.0,
        "duration": 10.0
    },
    {
        "name": "Bay of Bengal Branch Inflow",
        "latitude": 16.0,
        "longitude": 88.0,
        "altitude": 0.0,
        "range": 2500000.0,
        "tilt": 50.0,
        "heading": 15.0,
        "duration": 10.0
    },
    {
        "name": "Northeast India & Cherrapunji Heavy Rain",
        "latitude": 25.5,
        "longitude": 91.5,
        "altitude": 0.0,
        "range": 1800000.0,
        "tilt": 60.0,
        "heading": 315.0,
        "duration": 9.0
    },
    {
        "name": "Gangetic Plain Monsoon Trough & Low Pressure",
        "latitude": 27.0,
        "longitude": 76.0,
        "altitude": 0.0,
        "range": 2000000.0,
        "tilt": 50.0,
        "heading": 270.0,
        "duration": 9.0
    },
    {
        "name": "South Asian Monsoon Conclusion",
        "latitude": 20.0,
        "longitude": 78.0,
        "altitude": 0.0,
        "range": 5000000.0,
        "tilt": 45.0,
        "heading": 0.0,
        "duration": 11.0
    }
]

TOURS_CONFIG = [
    {
        "stops": EL_NINO_TOUR_STOPS,
        "output_path": "el_nino_tour.kml",
        "tour_name": "El Niño Guided Tour"
    },
    {
        "stops": GULF_STREAM_TOUR_STOPS,
        "output_path": "gulf_stream_tour.kml",
        "tour_name": "Gulf Stream Guided Tour"
    },
    {
        "stops": KUROSHIO_TOUR_STOPS,
        "output_path": "kuroshio_tour.kml",
        "tour_name": "Kuroshio Current Guided Tour"
    },
    {
        "stops": LA_NINA_TOUR_STOPS,
        "output_path": "la_nina_tour.kml",
        "tour_name": "La Niña Guided Tour"
    },
    {
        "stops": INDIAN_MONSOON_TOUR_STOPS,
        "output_path": "indianmonsoon_tour.kml",
        "tour_name": "Indian Monsoon Guided Tour"
    },
]

def generate_lookat_flyto(stop):
    """
    Generates a gx:FlyTo KML XML element for a continuous, smooth LookAt camera transition.
    """
    name = stop.get("name", "")
    lat = stop.get("latitude", 0.0)
    lon = stop.get("longitude", 0.0)
    alt = stop.get("altitude", 0.0)
    rng = stop.get("range", 10000000.0)
    tilt = stop.get("tilt", 45.0)
    heading = stop.get("heading", 0.0)
    duration = stop.get("duration", 10.0)
    fly_mode = stop.get("fly_to_mode", "smooth")
    alt_mode = stop.get("altitude_mode", "relativeToGround")

    comment = f"<!-- Scientific Stop: {name} -->\n        " if name else ""

    return f"""{comment}<gx:FlyTo>
          <gx:duration>{duration}</gx:duration>
          <gx:flyToMode>{fly_mode}</gx:flyToMode>
          <LookAt>
            <longitude>{lon}</longitude>
            <latitude>{lat}</latitude>
            <altitude>{alt}</altitude>
            <heading>{heading}</heading>
            <tilt>{tilt}</tilt>
            <range>{rng}</range>
            <altitudeMode>{alt_mode}</altitudeMode>
          </LookAt>
        </gx:FlyTo>"""

def calculate_tour_duration(tour_stops):
    """Calculates the total duration of all scientific FlyTo stops."""
    return sum(float(stop.get("duration", 8.0)) for stop in tour_stops)

def generate_tour_playlist(tour_stops):
    """Generates a playlist containing only scientific LookAt FlyTo stops."""
    return "\n\n        ".join(
        generate_lookat_flyto(stop) for stop in tour_stops
    )

def generate_tour_kml(tour_stops, output_path, tour_name=None):
    """
    Generates a Google Earth gx:Tour KML file from scientific tour stops.

    Parameters:
    - tour_stops (list of dict): Scientific LookAt tour stops.
    - output_path (str): File path for generated KML.
    - tour_name (str, optional): Title for the tour.

    Returns:
    - str: Absolute path of generated tour KML file.
    """
    if not tour_name:
        base = os.path.basename(output_path).replace(".kml", "").replace("_", " ").title()
        tour_name = f"{base} Guided Tour"

    playlist_content = generate_tour_playlist(tour_stops)
    total_duration = calculate_tour_duration(tour_stops)

    kml_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:gx="http://www.google.com/kml/ext/2.2"
     xmlns:kml="http://www.opengis.net/kml/2.2"
     xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
  <name>{tour_name}</name>
  <open>1</open>
  <gx:Tour>
    <name>{tour_name}</name>
    <gx:Playlist>

        {playlist_content}

    </gx:Playlist>
  </gx:Tour>
</Document>
</kml>
"""

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(kml_content)

    print(f"Generated tour KML: {output_path} (Total Duration: {total_duration:.1f}s)")
    return os.path.abspath(output_path)

def generate_all_tours(output_dir=None):
    """Generates tour KML files for all configured scientific tours."""
    print("Generating all tour KML files...")
    results = []

    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    for config in TOURS_CONFIG:
        out_path = config["output_path"]
        if output_dir:
            out_path = os.path.join(output_dir, os.path.basename(out_path))

        path = generate_tour_kml(
            config["stops"],
            out_path,
            tour_name=config["tour_name"]
        )
        duration = calculate_tour_duration(config["stops"])

        results.append({
            "tour_name": config["tour_name"],
            "path": path,
            "duration": duration
        })

    return results

def main():
    generate_all_tours()

if __name__ == "__main__":
    main()
