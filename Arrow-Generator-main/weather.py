import random
import simplekml
import os

CITY_NAME = "Mumbai"
LAT = 18.921984
LON = 72.834654

RAIN_ICON = "https://i.imgur.com/qoXQjzD.png"
LOW_PRESSURE_ICON = "https://i.imgur.com/VJIrVJN.png"

NUM_CLOUDS = 10

kml = simplekml.Kml(name=f"{CITY_NAME} Weather")

kml.document.camera = simplekml.Camera(
    latitude=LAT,
    longitude=LON,
    altitude=4000,
    heading=0,
    tilt=65,
    roll=0
)

for i in range(NUM_CLOUDS):

    dlat = random.uniform(-0.02, 0.02)
    dlon = random.uniform(-0.03, 0.03)

    pnt = kml.newpoint(
        name="Rain",
        coords=[(LON + dlon, LAT + dlat)]
    )

    pnt.style.iconstyle.icon.href = RAIN_ICON
    pnt.style.iconstyle.scale = random.uniform(1.2, 1.8)

low = kml.newpoint(
    name="Low Pressure System",
    coords=[(72.65, 18.95)]
)

low.style.iconstyle.icon.href = LOW_PRESSURE_ICON
low.style.iconstyle.scale = 2.5

label = kml.newpoint(
    name="Large Low\nPressure\nSystem",
    coords=[(72.67, 18.92)]
)

label.style.labelstyle.scale = 1.5
label.style.iconstyle.scale = 0

kml.save("mumbai_monsoon.kml")

script_dir = os.path.dirname(os.path.abspath(__file__))
assets_dir = os.path.abspath(os.path.join(script_dir, "..", "assets", "kml"))
os.makedirs(assets_dir, exist_ok=True)
asset_path = os.path.join(assets_dir, "mumbai_monsoon.kml")
kml.save(asset_path)

print(f"Generated mumbai_monsoon.kml in current directory and {asset_path}")