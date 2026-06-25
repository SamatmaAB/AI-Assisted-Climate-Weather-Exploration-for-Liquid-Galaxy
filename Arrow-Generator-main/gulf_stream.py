import math

# =====================================================
# CONFIG
# =====================================================

CITY_ICON = "https://i.imgur.com/CNAwh6Z.png"

SHAFT_WIDTH = 0.45
HEAD_LENGTH = 2.2
HEAD_WIDTH = 1.15
CITY_SCALE = 2.0

# =====================================================
# COLOR UTILITIES
# =====================================================

def rgb_to_kml(r, g, b, alpha="ff"):
    return f"{alpha}{b:02x}{g:02x}{r:02x}"


def interpolate_color(start_rgb, end_rgb, t):
    r = int(start_rgb[0] + (end_rgb[0] - start_rgb[0]) * t)
    g = int(start_rgb[1] + (end_rgb[1] - start_rgb[1]) * t)
    b = int(start_rgb[2] + (end_rgb[2] - start_rgb[2]) * t)

    return rgb_to_kml(r, g, b)


# =====================================================
# BEZIER CURVE
# =====================================================

def bezier_curve(start, control, end, steps=80):
    pts = []

    for i in range(steps + 1):
        t = i / steps

        lon = (
            ((1 - t) ** 2) * start[0]
            + 2 * (1 - t) * t * control[0]
            + (t ** 2) * end[0]
        )

        lat = (
            ((1 - t) ** 2) * start[1]
            + 2 * (1 - t) * t * control[1]
            + (t ** 2) * end[1]
        )

        pts.append((lon, lat))

    return pts


# =====================================================
# TRUNCATE CURVE
# =====================================================

def truncate_for_head(points, head_length):
    accumulated = 0

    for i in range(len(points) - 2, -1, -1):

        p1 = points[i]
        p2 = points[i + 1]

        seg = math.hypot(
            p2[0] - p1[0],
            p2[1] - p1[1]
        )

        if accumulated + seg >= head_length:

            remain = head_length - accumulated
            ratio = remain / seg

            x = p2[0] - ratio * (p2[0] - p1[0])
            y = p2[1] - ratio * (p2[1] - p1[1])

            return points[:i + 1] + [(x, y)]

        accumulated += seg

    return points


# =====================================================
# SHAFT SEGMENT
# =====================================================

def create_segment_polygon(p1, p2, color):
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]

    length = math.hypot(dx, dy)

    if length == 0:
        return ""

    nx = -dy / length
    ny = dx / length

    left1 = (
        p1[0] + nx * SHAFT_WIDTH,
        p1[1] + ny * SHAFT_WIDTH
    )

    right1 = (
        p1[0] - nx * SHAFT_WIDTH,
        p1[1] - ny * SHAFT_WIDTH
    )

    left2 = (
        p2[0] + nx * SHAFT_WIDTH,
        p2[1] + ny * SHAFT_WIDTH
    )

    right2 = (
        p2[0] - nx * SHAFT_WIDTH,
        p2[1] - ny * SHAFT_WIDTH
    )

    return f"""
<Placemark>
<Style>
<LineStyle>
<width>0</width>
</LineStyle>

<PolyStyle>
<color>{color}</color>
<outline>0</outline>
</PolyStyle>
</Style>

<Polygon>
<tessellate>1</tessellate>

<outerBoundaryIs>
<LinearRing>
<coordinates>

{left1[0]},{left1[1]},0
{left2[0]},{left2[1]},0
{right2[0]},{right2[1]},0
{right1[0]},{right1[1]},0
{left1[0]},{left1[1]},0

</coordinates>
</LinearRing>
</outerBoundaryIs>
</Polygon>
</Placemark>
"""


# =====================================================
# SHAFT
# =====================================================

def create_shaft(points, start_rgb, end_rgb):
    kml = ""

    total = len(points) - 1

    for i in range(total):
        t = i / total

        color = interpolate_color(
            start_rgb,
            end_rgb,
            t
        )

        kml += create_segment_polygon(
            points[i],
            points[i + 1],
            color
        )

    return kml


# =====================================================
# ARROWHEAD
# =====================================================

def create_head(base, tip, color):

    angle = math.atan2(
        tip[1] - base[1],
        tip[0] - base[0]
    )

    back_x = tip[0] - HEAD_LENGTH * math.cos(angle)
    back_y = tip[1] - HEAD_LENGTH * math.sin(angle)

    nx = -math.sin(angle)
    ny = math.cos(angle)

    left = (
        back_x + nx * HEAD_WIDTH,
        back_y + ny * HEAD_WIDTH
    )

    right = (
        back_x - nx * HEAD_WIDTH,
        back_y - ny * HEAD_WIDTH
    )

    return f"""
<Placemark>

<Style>
<LineStyle>
<width>0</width>
</LineStyle>

<PolyStyle>
<color>{color}</color>
<outline>0</outline>
</PolyStyle>
</Style>

<Polygon>
<tessellate>1</tessellate>

<outerBoundaryIs>
<LinearRing>
<coordinates>

{tip[0]},{tip[1]},0
{left[0]},{left[1]},0
{right[0]},{right[1]},0
{tip[0]},{tip[1]},0

</coordinates>
</LinearRing>
</outerBoundaryIs>

</Polygon>
</Placemark>
"""


# =====================================================
# COMPLETE ARROW
# =====================================================

def create_arrow(
        start,
        control,
        end,
        start_rgb,
        end_rgb):

    curve = bezier_curve(
        start,
        control,
        end,
        80
    )

    shaft_curve = truncate_for_head(
        curve,
        HEAD_LENGTH
    )

    shaft = create_shaft(
        shaft_curve,
        start_rgb,
        end_rgb
    )

    head_color = interpolate_color(
        start_rgb,
        end_rgb,
        1.0
    )

    head = create_head(
        shaft_curve[-1],
        curve[-1],
        head_color
    )

    return shaft + head


# =====================================================
# CITY MARKERS
# =====================================================

def city(name, lon, lat):
    return f"""
<Placemark>

<name>{name}</name>

<Style>
<IconStyle>
<scale>{CITY_SCALE}</scale>

<Icon>
<href>{CITY_ICON}</href>
</Icon>

</IconStyle>
</Style>

<Point>
<coordinates>{lon},{lat},0</coordinates>
</Point>

</Placemark>
"""


# =====================================================
# GULF STREAM
# =====================================================

# =====================================================
# GULF STREAM
# =====================================================

def gulf_stream():

    kml = ""

    # Gulf of Mexico -> Florida
    kml += create_arrow(
        start=(-86, 22),
        control=(-83.5, 24),
        end=(-80, 27),
        start_rgb=(255, 0, 0),
        end_rgb=(255, 80, 0)
    )

    # Florida -> Cape Hatteras
    kml += create_arrow(
        start=(-78.5, 28),
        control=(-75, 34),
        end=(-72, 36),
        start_rgb=(255, 80, 0),
        end_rgb=(255, 180, 0)
    )

    # Cape Hatteras -> Newfoundland
    kml += create_arrow(
        start=(-70, 37),
        control=(-61, 45),
        end=(-52, 46),
        start_rgb=(255, 180, 0),
        end_rgb=(255, 255, 0)
    )

    # Newfoundland -> British Isles
    kml += create_arrow(
        start=(-49, 47),
        control=(-27, 60),
        end=(-8, 58),
        start_rgb=(255, 255, 0),
        end_rgb=(0, 220, 255)
    )

    # British Isles -> Norway
    kml += create_arrow(
        start=(-5, 59),
        control=(4, 65),
        end=(12, 66),
        start_rgb=(0, 220, 255),
        end_rgb=(0, 100, 255)
    )

    # Cities
    kml += city("Miami", -80.19, 25.76)
    kml += city("New York", -74.00, 40.71)
    kml += city("St. John's", -52.71, 47.56)
    kml += city("London", -0.12, 51.50)
    kml += city("Bergen", 5.32, 60.39)

    return kml

# =====================================================
# WRAP KML
# =====================================================

def wrap(content):

    return f"""<?xml version="1.0" encoding="UTF-8"?>

<kml xmlns="http://www.opengis.net/kml/2.2">

<Document>

<name>Gulf Stream Current</name>

{content}

</Document>

</kml>
"""


# =====================================================
# MAIN
# =====================================================

def main():

    final_kml = wrap(
        gulf_stream()
    )

    with open(
        "gulf_stream.kml",
        "w",
        encoding="utf-8"
    ) as f:

        f.write(final_kml)

    print("gulf_stream.kml generated successfully")


if __name__ == "__main__":
    main()