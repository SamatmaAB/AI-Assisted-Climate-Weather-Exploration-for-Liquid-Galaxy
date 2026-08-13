import math
import os

RAIN_ICON = "https://i.imgur.com/CBHL5zR.png"
DROUGHT_ICON = "https://i.imgur.com/J4my1UV.png"
FLOOD_ICON = "https://i.imgur.com/4qzQsht.png"

MONSOON_ICON = "https://i.imgur.com/CBHL5zR.png"
STORM_ICON = "https://i.imgur.com/5r49jF2.png"
WARM_ICON = "https://i.imgur.com/FIIwqqB.png"

SHAFT_WIDTH = 0.28

HEAD_LENGTH = 1.5
HEAD_WIDTH = 0.75

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

def kuroshio():

    kml = ""

    kml += create_arrow(
        start=(120.0, 18.0),
        control=(122.5, 24.0),
        end=(126.8, 25.8),
        start_rgb=(220, 30, 30),
        end_rgb=(255, 120, 0)
    )

    kml += create_arrow(
        start=(129.0, 27.5),
        control=(131.0, 33.0),
        end=(135.0, 32.5),
        start_rgb=(255, 120, 0),
        end_rgb=(255, 220, 0)
    )

    kml += create_arrow(
        start=(137.0, 33.0),
        control=(138.5, 37.5),
        end=(140.0, 36.0),
        start_rgb=(255, 220, 0),
        end_rgb=(0, 220, 255)
    )

    kml += create_arrow(
        start=(142.0, 37.5),
        control=(150.0, 44.0),
        end=(165.0, 49.0),
        start_rgb=(0, 220, 255),
        end_rgb=(0, 100, 255)
    )

    kml += city(
        "Taipei",
        121.56,
        25.03,
        MONSOON_ICON
    )

    kml += city(
        "Okinawa",
        127.68,
        26.21,
        STORM_ICON
    )

    kml += city(
        "Tokyo",
        139.76,
        35.68,
        WARM_ICON
    )

    kml += city(
        "Sendai",
        140.87,
        38.27,
        RAIN_ICON
    )

    kml += city("Luzon Strait Warm Transport", 121.0, 20.0, WARM_ICON)
    kml += city("East China Sea Heavy Rain", 125.0, 28.5, RAIN_ICON)
    kml += city("Ryukyu Monsoon Corridor", 128.5, 28.0, MONSOON_ICON)
    kml += city("Kyushu Typhoon Alley", 130.5, 31.5, STORM_ICON)
    kml += city("Kii Peninsula Heavy Rain", 135.8, 33.6, RAIN_ICON)
    kml += city("Izu Ridge Storm Eddy", 139.0, 33.0, STORM_ICON)
    kml += city("Kuroshio-Oyashio Front Rain", 145.0, 40.0, RAIN_ICON)
    kml += city("Kuroshio Extension Meander", 152.0, 38.5, STORM_ICON)
    kml += city("North Pacific Drift Warming", 160.0, 42.0, WARM_ICON)

    return kml

def wrap(content):

    return f"""<?xml version="1.0" encoding="UTF-8"?>

<kml xmlns="http://www.opengis.net/kml/2.2">

<Document>

<name>Kuroshio Current</name>

{content}

</Document>

</kml>
"""

def main():

    final_kml = wrap(
        kuroshio()
    )

    filename = "kuroshio_current.kml"
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

    print(f"kuroshio_current.kml generated successfully in current directory and {asset_path}")

if __name__ == "__main__":
    main()