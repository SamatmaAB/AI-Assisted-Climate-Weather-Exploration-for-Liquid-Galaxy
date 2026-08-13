import math
import os

def xml_escape(text):
    """Escape special characters so placemark names stay valid XML."""
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )

RAIN_ICON = "https://i.imgur.com/CBHL5zR.png"
DROUGHT_ICON = "https://i.imgur.com/J4my1UV.png"
FLOOD_ICON = "https://i.imgur.com/4qzQsht.png"

MONSOON_ICON = "https://i.imgur.com/CBHL5zR.png"
STORM_ICON = "https://i.imgur.com/5r49jF2.png"
WARM_ICON = "https://i.imgur.com/FIIwqqB.png"

SHAFT_WIDTH = 0.45
HEAD_LENGTH = 2.2
HEAD_WIDTH = 1.15
CITY_SCALE = 3

def rgb_to_kml(r, g, b, alpha="ff"):
    return f"{alpha}{b:02x}{g:02x}{r:02x}"

def interpolate_color(start_rgb, end_rgb, t):
    r = int(start_rgb[0] + (end_rgb[0] - start_rgb[0]) * t)
    g = int(start_rgb[1] + (end_rgb[1] - start_rgb[1]) * t)
    b = int(start_rgb[2] + (end_rgb[2] - start_rgb[2]) * t)

    return rgb_to_kml(r, g, b)

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

def compute_boundary_vertices(points, shaft_width=SHAFT_WIDTH):
    n = len(points)
    if n < 2:
        return [], []

    seg_normals = []
    for i in range(n - 1):
        dx = points[i + 1][0] - points[i][0]
        dy = points[i + 1][1] - points[i][1]
        length = math.hypot(dx, dy)
        if length > 0:
            nx = -dy / length
            ny = dx / length
        else:
            nx, ny = 0.0, 0.0
        seg_normals.append((nx, ny))

    vertex_normals = []
    for i in range(n):
        if i == 0:
            vertex_normals.append(seg_normals[0])
        elif i == n - 1:
            vertex_normals.append(seg_normals[-1])
        else:
            n_prev = seg_normals[i - 1]
            n_next = seg_normals[i]
            nx_sum = n_prev[0] + n_next[0]
            ny_sum = n_prev[1] + n_next[1]
            norm = math.hypot(nx_sum, ny_sum)
            if norm > 0:
                vertex_normals.append((nx_sum / norm, ny_sum / norm))
            else:
                vertex_normals.append(n_prev)

    left_boundary = []
    right_boundary = []
    for i in range(n):
        nx, ny = vertex_normals[i]
        left_boundary.append((
            points[i][0] + nx * shaft_width,
            points[i][1] + ny * shaft_width
        ))
        right_boundary.append((
            points[i][0] - nx * shaft_width,
            points[i][1] - ny * shaft_width
        ))

    return left_boundary, right_boundary

def create_quad_polygon(left1, left2, right2, right1, color):
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

def create_shaft(points, start_rgb, end_rgb, shaft_width=SHAFT_WIDTH):
    left_boundary, right_boundary = compute_boundary_vertices(points, shaft_width)

    kml = ""
    total = len(points) - 1

    if total <= 0:
        return "", (0, 0), (0, 0)

    for i in range(total):
        t = i / total

        color = interpolate_color(
            start_rgb,
            end_rgb,
            t
        )

        kml += create_quad_polygon(
            left_boundary[i],
            left_boundary[i + 1],
            right_boundary[i + 1],
            right_boundary[i],
            color
        )

    return kml, left_boundary[-1], right_boundary[-1]

def create_head(base, tip, color, shaft_left_end=None, shaft_right_end=None):

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

    if shaft_left_end and shaft_right_end:
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
{shaft_left_end[0]},{shaft_left_end[1]},0
{shaft_right_end[0]},{shaft_right_end[1]},0
{right[0]},{right[1]},0
{tip[0]},{tip[1]},0

</coordinates>
</LinearRing>
</outerBoundaryIs>

</Polygon>
</Placemark>
"""

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

    shaft, shaft_left_end, shaft_right_end = create_shaft(
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
        head_color,
        shaft_left_end,
        shaft_right_end
    )

    return shaft + head

def city(name, lon, lat, icon=WARM_ICON):
    name = xml_escape(name)
    return f"""
<Placemark>

<name>{name}</name>

<Style>
<IconStyle>
<scale>{CITY_SCALE}</scale>

<Icon>
<href>{icon}</href>
</Icon>

</IconStyle>
</Style>

<Point>
<coordinates>{lon},{lat},0</coordinates>
</Point>

</Placemark>
"""

def gulf_stream():

    kml = ""

    kml += create_arrow(
        start=(-86, 22),
        control=(-83.5, 24),
        end=(-80, 27),
        start_rgb=(255, 0, 0),
        end_rgb=(255, 80, 0)
    )

    kml += create_arrow(
        start=(-78.5, 28),
        control=(-75, 34),
        end=(-72, 36),
        start_rgb=(255, 80, 0),
        end_rgb=(255, 180, 0)
    )

    kml += create_arrow(
        start=(-70, 37),
        control=(-61, 45),
        end=(-52, 46),
        start_rgb=(255, 180, 0),
        end_rgb=(255, 255, 0)
    )

    kml += create_arrow(
        start=(-49, 47),
        control=(-27, 60),
        end=(-8, 58),
        start_rgb=(255, 255, 0),
        end_rgb=(0, 220, 255)
    )

    kml += create_arrow(
        start=(-5, 59),
        control=(4, 65),
        end=(12, 66),
        start_rgb=(0, 220, 255),
        end_rgb=(0, 100, 255)
    )

    kml += city("Miami", -80.19, 25.76, WARM_ICON)
    kml += city("New York", -74.00, 40.71, STORM_ICON)
    kml += city("St. John's", -52.71, 47.56, RAIN_ICON)
    kml += city("London", -0.12, 51.50, RAIN_ICON)
    kml += city("Bergen", 5.32, 60.39, FLOOD_ICON)

    kml += city("Florida Straits Heat Flow", -81.5, 24.0, WARM_ICON)
    kml += city("Hatteras Storm Corridor", -75.0, 35.5, STORM_ICON)
    kml += city("Mid-Atlantic Storm Track", -76.0, 36.8, STORM_ICON)
    kml += city("Georges Bank Fog &amp; Rain", -67.0, 41.5, RAIN_ICON)
    kml += city("Grand Banks Front Storms", -50.0, 43.5, STORM_ICON)
    kml += city("Sargasso Warm Pool", -65.0, 30.0, WARM_ICON)
    kml += city("North Atlantic Drift", -35.0, 50.0, WARM_ICON)
    kml += city("Irish Sea Heavy Rain", -6.0, 53.5, RAIN_ICON)
    kml += city("Norwegian Fjords Flood Zone", 6.0, 62.5, FLOOD_ICON)
    kml += city("Spitsbergen Arctic Warming", 16.0, 78.0, WARM_ICON)
    kml += city("Icelandic Low Storm Basin", -18.0, 64.0, STORM_ICON)

    return kml

def wrap(content):

    return f"""<?xml version="1.0" encoding="UTF-8"?>

<kml xmlns="http://www.opengis.net/kml/2.2">

<Document>

<name>Gulf Stream Current</name>

{content}

</Document>

</kml>
"""

def main():

    final_kml = wrap(
        gulf_stream()
    )

    filename = "gulf_stream.kml"
    with open(
        filename,
        "w",
        encoding="utf-8"
    ) as f:

        f.write(final_kml)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    assets_dir = os.path.abspath(os.path.join(script_dir, "..", "assets", "kml"))
    os.makedirs(assets_dir, exist_ok=True)
    asset_path = os.path.join(assets_dir, filename)
    with open(asset_path, "w", encoding="utf-8") as f:
        f.write(final_kml)

    print(f"gulf_stream.kml generated successfully in current directory and {asset_path}")

if __name__ == "__main__":
    main()