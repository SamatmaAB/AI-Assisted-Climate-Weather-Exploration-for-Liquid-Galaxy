import math

# =====================================================
# CONFIG
# =====================================================

CITY_ICON = "https://i.imgur.com/CNAwh6Z.png"

# Thinner arrows
SHAFT_WIDTH = 0.28

# Smaller, cleaner arrowheads
HEAD_LENGTH = 1.5
HEAD_WIDTH = 0.75

CITY_SCALE = 2.0

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
# TRUNCATE CURVE FOR ARROWHEAD
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
# CITY MARKER
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
# KUROSHIO CURRENT
# =====================================================

def kuroshio():

    kml = ""

    # Taiwan -> Okinawa
    kml += create_arrow(
        start=(120.0, 18.0),
        control=(122.5, 24.0),
        end=(126.8, 25.8),
        start_rgb=(220, 30, 30),
        end_rgb=(255, 120, 0)
    )

    # Okinawa -> South Japan
    kml += create_arrow(
        start=(129.0, 27.5),
        control=(131.0, 33.0),
        end=(135.0, 32.5),
        start_rgb=(255, 120, 0),
        end_rgb=(255, 220, 0)
    )

    # South Japan -> Tokyo
    kml += create_arrow(
        start=(137.0, 33.0),
        control=(138.5, 37.5),
        end=(140.0, 36.0),
        start_rgb=(255, 220, 0),
        end_rgb=(0, 220, 255)
    )

    # Tokyo -> Pacific
    kml += create_arrow(
        start=(142.0, 37.5),
        control=(150.0, 44.0),
        end=(165.0, 49.0),
        start_rgb=(0, 220, 255),
        end_rgb=(0, 100, 255)
    )

    # ------------------------------------------
    # CITY MARKERS
    # ------------------------------------------

    kml += city(
        "Taipei",
        121.56,
        25.03
    )

    kml += city(
        "Okinawa",
        127.68,
        26.21
    )

    kml += city(
        "Tokyo",
        139.76,
        35.68
    )

    kml += city(
        "Sendai",
        140.87,
        38.27
    )

    return kml


# =====================================================
# WRAP KML
# =====================================================

def wrap(content):

    return f"""<?xml version="1.0" encoding="UTF-8"?>

<kml xmlns="http://www.opengis.net/kml/2.2">

<Document>

<name>Kuroshio Current</name>

{content}

</Document>

</kml>
"""


# =====================================================
# MAIN
# =====================================================

def main():

    final_kml = wrap(
        kuroshio()
    )

    with open(
        "kuroshio_current.kml",
        "w",
        encoding="utf-8"
    ) as f:

        f.write(final_kml)

    print("kuroshio_current.kml generated successfully")


if __name__ == "__main__":
    main()