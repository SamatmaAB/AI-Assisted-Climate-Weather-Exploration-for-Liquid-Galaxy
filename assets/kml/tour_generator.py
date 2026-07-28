"""
tour_generator.py

Standalone tour generator script and reusable module for generating Google Earth gx:Tour KML files.
Provides functions for creating LookAt scientific exploration stops, cinematic landmark Camera keyframes,
mathematically calculated partial orbits, gx:Wait duration holds, and complete interleaved continuous gx:Playlist tours.
"""

import math
import os


# ------------------------------------------------------------------------------
# GEODESIC & NAVIGATION MATH HELPERS
# ------------------------------------------------------------------------------

EARTH_RADIUS_M = 6371000.0


def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculates great-circle distance between two points in meters using the Haversine formula.
    """
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2.0) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2.0) ** 2)
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return EARTH_RADIUS_M * c


def calculate_bearing(lat1, lon1, lat2, lon2):
    """
    Calculates initial bearing (heading) in degrees from (lat1, lon1) towards (lat2, lon2).
    """
    y = math.sin(math.radians(lon2 - lon1)) * math.cos(math.radians(lat2))
    x = (math.cos(math.radians(lat1)) * math.sin(math.radians(lat2)) -
         math.sin(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.cos(math.radians(lon2 - lon1)))
    brng = math.degrees(math.atan2(y, x))
    return (brng + 360.0) % 360.0


def destination_point(lat, lon, distance_m, bearing_deg):
    """
    Calculates destination point (lat, lon) given start point, distance in meters, and bearing in degrees.
    """
    d_r = distance_m / EARTH_RADIUS_M
    brng_r = math.radians(bearing_deg)
    lat1_r = math.radians(lat)
    lon1_r = math.radians(lon)

    lat2_r = math.asin(math.sin(lat1_r) * math.cos(d_r) +
                       math.cos(lat1_r) * math.sin(d_r) * math.cos(brng_r))
    lon2_r = lon1_r + math.atan2(math.sin(brng_r) * math.sin(d_r) * math.cos(lat1_r),
                                 math.cos(d_r) - math.sin(lat1_r) * math.sin(lat2_r))

    dest_lat = math.degrees(lat2_r)
    dest_lon = (math.degrees(lon2_r) + 540.0) % 360.0 - 180.0
    return dest_lat, dest_lon


# ------------------------------------------------------------------------------
# SCIENTIFIC TOUR STOPS (LookAt)
# ------------------------------------------------------------------------------

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


# ------------------------------------------------------------------------------
# LANDMARK CONFIGURATIONS (Target + Initial Camera + Orbit Parameters)
# ------------------------------------------------------------------------------

KUROSHIO_LANDMARKS = [
    {
        "name": "Taipei 101 Landmark View",
        "city": "Taipei, Taiwan",
        "after_stop": "Taiwan & Luzon Strait Origin",
        "target_latitude": 25.0339,
        "target_longitude": 121.5645,
        "camera_latitude": 25.0315,
        "camera_longitude": 121.5620,
        "altitude": 150.0,
        "tilt": 80.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    },
    {
        "name": "Tokyo Tower Landmark View",
        "city": "Tokyo, Japan",
        "after_stop": "Kuroshio Extension off Japan & Tokyo",
        "target_latitude": 35.6586,
        "target_longitude": 139.7454,
        "camera_latitude": 35.6578,
        "camera_longitude": 139.7423,
        "altitude": 90.0,
        "tilt": 95.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": True  # Calibrated on physical Liquid Galaxy rig
    }
]

EL_NINO_LANDMARKS = [
    {
        "name": "Monas National Monument View",
        "city": "Jakarta, Indonesia",
        "after_stop": "Western Pacific Warm Pool & Indonesia Drought",
        "target_latitude": -6.1754,
        "target_longitude": 106.8272,
        "camera_latitude": -6.1775,
        "camera_longitude": 106.8250,
        "altitude": 120.0,
        "tilt": 80.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    },
    {
        "name": "Plaza Mayor of Lima View",
        "city": "Lima, Peru",
        "after_stop": "Peru Upwelling & Coastal Flooding",
        "target_latitude": -12.0453,
        "target_longitude": -77.0305,
        "camera_latitude": -12.0470,
        "camera_longitude": -77.0325,
        "altitude": 100.0,
        "tilt": 75.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    },
    {
        "name": "Golden Gate Bridge View",
        "city": "San Francisco, USA",
        "after_stop": "North American Teleconnections",
        "target_latitude": 37.8199,
        "target_longitude": -122.4783,
        "camera_latitude": 37.8170,
        "camera_longitude": -122.4815,
        "altitude": 150.0,
        "tilt": 80.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    }
]

GULF_STREAM_LANDMARKS = [
    {
        "name": "Freedom Tower Landmark View",
        "city": "Miami, USA",
        "after_stop": "Gulf of Mexico & Florida Straits Origin",
        "target_latitude": 25.7781,
        "target_longitude": -80.1895,
        "camera_latitude": 25.7765,
        "camera_longitude": -80.1875,
        "altitude": 110.0,
        "tilt": 75.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    },
    {
        "name": "Statue of Liberty Landmark View",
        "city": "New York City, USA",
        "after_stop": "Cape Hatteras Coastal Separation",
        "target_latitude": 40.6892,
        "target_longitude": -74.0445,
        "camera_latitude": 40.6875,
        "camera_longitude": -74.0465,
        "altitude": 80.0,
        "tilt": 80.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    },
    {
        "name": "Big Ben Landmark View",
        "city": "London, UK",
        "after_stop": "European Warming Drift to Norway",
        "target_latitude": 51.5007,
        "target_longitude": -0.1246,
        "camera_latitude": 51.5020,
        "camera_longitude": -0.1265,
        "altitude": 90.0,
        "tilt": 80.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    }
]

LA_NINA_LANDMARKS = [
    {
        "name": "Plaza Mayor of Lima View",
        "city": "Lima, Peru",
        "after_stop": "Cold Upwelling off South America",
        "target_latitude": -12.0453,
        "target_longitude": -77.0305,
        "camera_latitude": -12.0470,
        "camera_longitude": -77.0325,
        "altitude": 100.0,
        "tilt": 75.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    },
    {
        "name": "Sydney Opera House Landmark View",
        "city": "Sydney, Australia",
        "after_stop": "Australian Wet Zone & Asian Monsoon",
        "target_latitude": -33.8568,
        "target_longitude": 151.2153,
        "camera_latitude": -33.8590,
        "camera_longitude": 151.2130,
        "altitude": 100.0,
        "tilt": 80.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    }
]

INDIAN_MONSOON_LANDMARKS = [
    {
        "name": "Gateway of India Landmark View",
        "city": "Mumbai, India",
        "after_stop": "Arabian Sea Branch & Western Ghats",
        "target_latitude": 18.9220,
        "target_longitude": 72.8347,
        "camera_latitude": 18.9220,
        "camera_longitude": 72.8325,
        "altitude": 70.0,
        "tilt": 80.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "approach_duration": 3.0,
        "orbit_duration": 15.0,
        "orbit_degrees": 120.0,
        "orbit_steps": 6,
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    },
    {
        "name": "India Gate Landmark View",
        "city": "New Delhi, India",
        "after_stop": "Gangetic Plain Monsoon Trough & Low Pressure",
        "target_latitude": 28.6129,
        "target_longitude": 77.2295,
        "camera_latitude": 28.6129,
        "camera_longitude": 77.2270,
        "altitude": 80.0,
        "tilt": 80.0,
        "roll": 0.0,
        "altitude_mode": "relativeToGround",
        "final_hold_duration": 3.0,
        "calibrated": False  # Needs Liquid Galaxy Rig Calibration
    }
]


# ------------------------------------------------------------------------------
# TOUR CONFIGURATION REGISTRY
# ------------------------------------------------------------------------------

TOURS_CONFIG = [
    {
        "stops": EL_NINO_TOUR_STOPS,
        "landmarks": EL_NINO_LANDMARKS,
        "output_path": "el_nino_tour.kml",
        "tour_name": "El Niño Guided Tour"
    },
    {
        "stops": GULF_STREAM_TOUR_STOPS,
        "landmarks": GULF_STREAM_LANDMARKS,
        "output_path": "gulf_stream_tour.kml",
        "tour_name": "Gulf Stream Guided Tour"
    },
    {
        "stops": KUROSHIO_TOUR_STOPS,
        "landmarks": KUROSHIO_LANDMARKS,
        "output_path": "kuroshio_tour.kml",
        "tour_name": "Kuroshio Current Guided Tour"
    },
    {
        "stops": LA_NINA_TOUR_STOPS,
        "landmarks": LA_NINA_LANDMARKS,
        "output_path": "la_nina_tour.kml",
        "tour_name": "La Niña Guided Tour"
    },
    {
        "stops": INDIAN_MONSOON_TOUR_STOPS,
        "landmarks": INDIAN_MONSOON_LANDMARKS,
        "output_path": "indianmonsoon_tour.kml",
        "tour_name": "Indian Monsoon Guided Tour"
    },
]


# ------------------------------------------------------------------------------
# REUSABLE KML GENERATOR HELPERS
# ------------------------------------------------------------------------------

def generate_lookat_flyto(stop):
    """
    Generates a gx:FlyTo KML XML element for a scientific LookAt viewpoint.
    """
    name = stop.get("name", "")
    lat = stop.get("latitude", 0.0)
    lon = stop.get("longitude", 0.0)
    alt = stop.get("altitude", 0.0)
    rng = stop.get("range", 10000000.0)
    tilt = stop.get("tilt", 45.0)
    heading = stop.get("heading", 0.0)
    duration = stop.get("duration", 8.0)
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


def generate_camera_flyto(lat, lon, alt, heading, tilt, roll=0.0, duration=4.0, alt_mode="relativeToGround", comment=None):
    """
    Generates a gx:FlyTo KML XML element for a single Camera position keyframe.
    """
    comment_str = f"<!-- {comment} -->\n        " if comment else ""
    return f"""{comment_str}<gx:FlyTo>
          <gx:duration>{duration}</gx:duration>
          <gx:flyToMode>smooth</gx:flyToMode>
          <Camera>
            <longitude>{lon:.6f}</longitude>
            <latitude>{lat:.6f}</latitude>
            <altitude>{alt:.1f}</altitude>
            <heading>{heading:.1f}</heading>
            <tilt>{tilt:.1f}</tilt>
            <roll>{roll:.1f}</roll>
            <altitudeMode>{alt_mode}</altitudeMode>
          </Camera>
        </gx:FlyTo>"""


def generate_wait(duration, comment=None):
    """
    Generates a gx:Wait KML XML element for holding a viewpoint.
    """
    comment_str = f"<!-- {comment} -->\n        " if comment else ""
    return f"""{comment_str}<gx:Wait>
          <gx:duration>{duration}</gx:duration>
        </gx:Wait>"""


def generate_landmark_orbit_keyframes(landmark):
    """
    Generates a list of Camera keyframe dictionaries for a smooth partial orbit around a landmark target.

    Computes:
    1. Distance/radius from target to initial camera position
    2. Initial bearing from target to camera position
    3. Successive camera positions spaced around the target through `orbit_degrees`
    4. Dynamically calculated heading at each camera position pointing back at the target.
    """
    target_lat = landmark.get("target_latitude")
    target_lon = landmark.get("target_longitude")
    cam_lat = landmark.get("camera_latitude", target_lat)
    cam_lon = landmark.get("camera_longitude", target_lon)

    # If target not specified, use camera coordinates directly (fallback)
    if target_lat is None or target_lon is None:
        target_lat, target_lon = cam_lat, cam_lon

    alt = landmark.get("altitude", 100.0)
    tilt = landmark.get("tilt", 80.0)
    roll = landmark.get("roll", 0.0)
    alt_mode = landmark.get("altitude_mode", "relativeToGround")

    orbit_dur = landmark.get("orbit_duration", 15.0)
    orbit_deg = landmark.get("orbit_degrees", 120.0)
    orbit_steps = landmark.get("orbit_steps", 6)
    step_dur = orbit_dur / float(orbit_steps)

    # 1. Distance & initial bearing relative to target
    radius = calculate_distance(target_lat, target_lon, cam_lat, cam_lon)
    if radius < 5.0:  # Fallback if camera is right at target
        radius = 250.0
        cam_lat, cam_lon = destination_point(target_lat, target_lon, radius, 240.0)

    initial_target_to_cam_bearing = calculate_bearing(target_lat, target_lon, cam_lat, cam_lon)

    keyframes = []

    # Orbit keyframes (from step 1 to orbit_steps)
    for i in range(1, orbit_steps + 1):
        step_angle = initial_target_to_cam_bearing + (orbit_deg * (i / float(orbit_steps)))
        step_lat, step_lon = destination_point(target_lat, target_lon, radius, step_angle)
        heading_to_target = calculate_bearing(step_lat, step_lon, target_lat, target_lon)

        keyframes.append({
            "latitude": step_lat,
            "longitude": step_lon,
            "altitude": alt,
            "heading": heading_to_target,
            "tilt": tilt,
            "roll": roll,
            "duration": step_dur,
            "altitude_mode": alt_mode,
            "step_index": i
        })

    return keyframes


def generate_landmark_sequence(landmark):
    """
    Assembles a complete landmark exploration sequence:
    1. Smooth approach FlyTo to initial Camera viewpoint (~3s)
    2. Partial orbit FlyTos smoothly transitioning around the target (~15s total)
    3. Final settle gx:Wait hold (~3s)
    """
    elements = []
    lm_name = landmark.get("name", "Landmark")
    city = landmark.get("city", "")

    target_lat = landmark.get("target_latitude")
    target_lon = landmark.get("target_longitude")
    cam_lat = landmark.get("camera_latitude", target_lat)
    cam_lon = landmark.get("camera_longitude", target_lon)
    if target_lat is None or target_lon is None:
        target_lat, target_lon = cam_lat, cam_lon

    alt = landmark.get("altitude", 100.0)
    tilt = landmark.get("tilt", 80.0)
    roll = landmark.get("roll", 0.0)
    alt_mode = landmark.get("altitude_mode", "relativeToGround")
    approach_dur = landmark.get("approach_duration", 3.0)
    final_hold_dur = landmark.get("final_hold_duration", 3.0)

    # Initial heading pointing from camera position to target
    initial_heading = landmark.get("heading")
    if initial_heading is None:
        initial_heading = calculate_bearing(cam_lat, cam_lon, target_lat, target_lon)

    # 1. Approach to initial Camera position
    approach_comment = f"Landmark Approach: {lm_name} ({city})"
    elements.append(generate_camera_flyto(
        cam_lat, cam_lon, alt, initial_heading, tilt, roll,
        duration=approach_dur, alt_mode=alt_mode, comment=approach_comment
    ))

    # 2. Smooth Partial Orbit Keyframes
    orbit_keyframes = generate_landmark_orbit_keyframes(landmark)
    for kf in orbit_keyframes:
        kf_comment = f"Partial Orbit Keyframe {kf['step_index']}/{len(orbit_keyframes)}: {lm_name}"
        elements.append(generate_camera_flyto(
            kf["latitude"], kf["longitude"], kf["altitude"], kf["heading"],
            kf["tilt"], kf["roll"], duration=kf["duration"],
            alt_mode=kf["altitude_mode"], comment=kf_comment
        ))

    # 3. Final Settle Hold
    hold_comment = f"Final Settle Hold: {lm_name}"
    elements.append(generate_wait(final_hold_dur, comment=hold_comment))

    return "\n\n        ".join(elements)


def get_landmark_duration(landmark):
    """
    Returns the total duration of a landmark sequence in seconds:
    approach_duration + orbit_duration + final_hold_duration
    """
    approach = float(landmark.get("approach_duration", 3.0))
    orbit = float(landmark.get("orbit_duration", 15.0))
    final_hold = float(landmark.get("final_hold_duration", 3.0))
    return approach + orbit + final_hold


def calculate_tour_duration(tour_stops, landmarks=None):
    """
    Calculates the exact total tour duration in seconds.

    Includes:
    - Scientific FlyTo durations
    - Landmark approach durations
    - Landmark partial orbit FlyTo durations
    - Landmark final hold durations
    """
    total = 0.0
    landmarks_by_after = {}
    if landmarks:
        for lm in landmarks:
            after = lm.get("after_stop")
            if after:
                landmarks_by_after.setdefault(after, []).append(lm)

    for stop in tour_stops:
        total += float(stop.get("duration", 8.0))
        stop_name = stop.get("name")
        if stop_name in landmarks_by_after:
            for lm in landmarks_by_after[stop_name]:
                total += get_landmark_duration(lm)

    return total


def generate_tour_playlist(tour_stops, landmarks=None):
    """
    Assembles playlist XML components by interleaving scientific LookAt FlyTos
    with cinematic landmark Camera orbit sequences and gx:Wait holds.
    """
    elements = []
    landmarks_by_after = {}
    if landmarks:
        for lm in landmarks:
            after = lm.get("after_stop")
            if after:
                landmarks_by_after.setdefault(after, []).append(lm)

    for stop in tour_stops:
        # Scientific LookAt FlyTo
        elements.append(generate_lookat_flyto(stop))

        # Check for matching interleaved landmarks
        stop_name = stop.get("name")
        if stop_name in landmarks_by_after:
            for lm in landmarks_by_after[stop_name]:
                # Landmark Orbit & Settle sequence
                elements.append(generate_landmark_sequence(lm))

    return "\n\n        ".join(elements)


def generate_tour_kml(tour_stops, output_path, tour_name=None, landmarks=None):
    """
    Generates a Google Earth gx:Tour KML file from tour stops and optional landmarks.

    Parameters:
    - tour_stops (list of dict): Scientific LookAt tour stops.
    - output_path (str): File path for generated KML.
    - tour_name (str, optional): Title for the tour.
    - landmarks (list of dict, optional): Landmark Camera presets with `after_stop` insertion points.

    Returns:
    - str: Absolute path of generated tour KML file.
    """
    if not tour_name:
        base = os.path.basename(output_path).replace(".kml", "").replace("_", " ").title()
        tour_name = f"{base} Guided Tour"

    playlist_content = generate_tour_playlist(tour_stops, landmarks)
    total_duration = calculate_tour_duration(tour_stops, landmarks)

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
    """Generates tour KML files for all configured tours."""
    print("Generating all integrated tour KML files...")
    results = []
    for config in TOURS_CONFIG:
        out_path = config["output_path"]
        if output_dir:
            out_path = os.path.join(output_dir, os.path.basename(out_path))

        path = generate_tour_kml(
            config["stops"],
            out_path,
            tour_name=config["tour_name"],
            landmarks=config.get("landmarks")
        )
        duration = calculate_tour_duration(config["stops"], config.get("landmarks"))
        results.append({
            "tour_name": config["tour_name"],
            "path": path,
            "duration": duration,
            "landmarks_count": len(config.get("landmarks", []))
        })
    return results


def main():
    generate_all_tours()


if __name__ == "__main__":
    main()
