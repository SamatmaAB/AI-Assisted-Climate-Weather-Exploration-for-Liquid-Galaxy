import math
import random
import os

RAIN_ICON = "https://i.imgur.com/qoXQjzD.png"
DROUGHT_ICON = "https://i.imgur.com/p7WHxlT.png"
FLOOD_ICON = "https://i.imgur.com/FE0MzOA.jpeg"

MONSOON_ICON = "https://i.imgur.com/qoXQjzD.png"
STORM_ICON = "https://i.imgur.com/UbtYVUx.png"
WARM_ICON = "https://i.imgur.com/RXrha0q.png"

ICON_SCALE = 5.5

SHAFT_WIDTH = 0.51
HEAD_LENGTH = 2.04
HEAD_WIDTH = 1.02

BEZIER_STEPS = 120

LANE_TOP_SEGMENTS = [
    ((-90,  2.0), (-100,  6.5), (-110,  3.5)),
    ((-112, 3.5), (-125,  8.0), (-140,  5.0)),
    ((-143, 5.0), (-158,  9.5), (-170,  6.5)),
    ((-173, 6.5), (-179, 10.0), (173,   6.8)),
    ((170,  6.8), (158,   9.2), (148,   5.5)),
    ((145,  5.5), (138,   8.0), (130,   4.5))
]

LANE_MIDDLE_SEGMENTS = [
    ((-90, -0.5), (-100,  2.8), (-110, -0.2)),
    ((-112, -0.2), (-125,  3.2), (-140,  0.2)),
    ((-143,  0.2), (-158,  3.0), (-170,  0.3)),
    ((-173,  0.3), (-179,  3.5), (173,   0.4)),
    ((170,   0.4), (158,   3.0), (148,   0.1)),
    ((145,   0.1), (138,   2.8), (130,  -0.8))
]

LANE_BOTTOM_SEGMENTS = [
    ((-90, -3.5), (-100,  -7.0), (-110,  -4.5)),
    ((-112, -4.5), (-125, -8.5), (-140,  -6.0)),
    ((-143, -6.0), (-158, -9.8), (-170,  -7.2)),
    ((-173, -7.2), (-179, -10.5), (173,  -7.0)),
    ((170,  -7.0), (158,  -9.0), (148,   -5.8)),
    ((145,  -5.8), (138,  -7.5), (130,   -6.2))
]

ALL_LANES = [
    LANE_BOTTOM_SEGMENTS,
    LANE_MIDDLE_SEGMENTS,
    LANE_TOP_SEGMENTS
]

NINA_PALETTE = [
    (0,  50, 220),
    (0, 200, 255),
    (255, 220,  0),
    (255, 120,  0),
    (220,  30, 30)
]

def normalize_lon(lon):
    """
    Ensure longitude is strictly bounded within [-180.0, 180.0] for Google Earth.
    """
    while lon > 180.0:
        lon -= 360.0
    while lon < -180.0:
        lon += 360.0
    return lon

def unwrap_lon(ref_lon, target_lon):
    """
    Unwrap target_lon relative to ref_lon for continuous curve calculations.
    """
    diff = target_lon - ref_lon
    while diff > 180.0:
        target_lon -= 360.0
        diff = target_lon - ref_lon
    while diff < -180.0:
        target_lon += 360.0
        diff = target_lon - ref_lon
    return target_lon

def has_antimeridian_jump(coords):
    """
    Prevent polygons from spanning > 180 deg longitude across the globe.
    """
    n = len(coords)
    for i in range(n):
        lon1 = coords[i][0]
        lon2 = coords[(i + 1) % n][0]
        if abs(lon2 - lon1) > 180.0:
            return True
    return False

def rgb_to_kml(r, g, b, alpha="ff"):
    return f"{alpha}{b:02x}{g:02x}{r:02x}"

def interpolate_rgb(start_rgb, end_rgb, t):
    r = int(start_rgb[0] + (end_rgb[0] - start_rgb[0]) * t)
    g = int(start_rgb[1] + (end_rgb[1] - start_rgb[1]) * t)
    b = int(start_rgb[2] + (end_rgb[2] - start_rgb[2]) * t)
    return (r, g, b)

def interpolate_color(start_rgb, end_rgb, t):
    r, g, b = interpolate_rgb(start_rgb, end_rgb, t)
    return rgb_to_kml(r, g, b)

def get_nina_palette_color(t):
    """
    Interpolate from NINA_PALETTE given normalized progress t in [0, 1].
    t=0 → deep blue (cold east), t=1 → hot red (warm west).
    """
    t = max(0.0, min(1.0, t))
    n_intervals = len(NINA_PALETTE) - 1
    scaled = t * n_intervals
    idx = int(scaled)
    if idx >= n_intervals:
        return NINA_PALETTE[-1]
    local_t = scaled - idx
    return interpolate_rgb(NINA_PALETTE[idx], NINA_PALETTE[idx + 1], local_t)

def bezier_curve(start, control, end, steps=BEZIER_STEPS):
    pts = []
    s_lon, s_lat = start[0], start[1]
    c_lon = unwrap_lon(s_lon, control[0])
    c_lat = control[1]
    e_lon = unwrap_lon(c_lon, end[0])
    e_lat = end[1]

    for i in range(steps + 1):
        t = i / steps
        lon = (
            ((1 - t) ** 2) * s_lon
            + 2 * (1 - t) * t * c_lon
            + (t ** 2) * e_lon
        )
        lat = (
            ((1 - t) ** 2) * s_lat
            + 2 * (1 - t) * t * c_lat
            + (t ** 2) * e_lat
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
            normalize_lon(points[i][0] + nx * shaft_width),
            points[i][1] + ny * shaft_width
        ))
        right_boundary.append((
            normalize_lon(points[i][0] - nx * shaft_width),
            points[i][1] - ny * shaft_width
        ))

    return left_boundary, right_boundary

def create_quad_polygon(left1, left2, right2, right1, color):
    ring_coords = [left1, left2, right2, right1, left1]
    if has_antimeridian_jump(ring_coords):
        return ""

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

def create_head(base, tip, color, head_length=HEAD_LENGTH, head_width=HEAD_WIDTH,
                shaft_left_end=None, shaft_right_end=None):
    angle = math.atan2(
        tip[1] - base[1],
        tip[0] - base[0]
    )

    back_x = tip[0] - head_length * math.cos(angle)
    back_y = tip[1] - head_length * math.sin(angle)

    nx = -math.sin(angle)
    ny = math.cos(angle)

    tip_kml = (normalize_lon(tip[0]), tip[1])
    left = (
        normalize_lon(back_x + nx * head_width),
        back_y + ny * head_width
    )
    right = (
        normalize_lon(back_x - nx * head_width),
        back_y - ny * head_width
    )

    if shaft_left_end and shaft_right_end:
        ring_coords = [tip_kml, left, shaft_left_end, shaft_right_end, right, tip_kml]
        if has_antimeridian_jump(ring_coords):
            return ""

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

{tip_kml[0]},{tip_kml[1]},0
{left[0]},{left[1]},0
{shaft_left_end[0]},{shaft_left_end[1]},0
{shaft_right_end[0]},{shaft_right_end[1]},0
{right[0]},{right[1]},0
{tip_kml[0]},{tip_kml[1]},0

</coordinates>

</LinearRing>
</outerBoundaryIs>

</Polygon>

</Placemark>
"""

    ring_coords = [tip_kml, left, right, tip_kml]
    if has_antimeridian_jump(ring_coords):
        return ""

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

{tip_kml[0]},{tip_kml[1]},0
{left[0]},{left[1]},0
{right[0]},{right[1]},0
{tip_kml[0]},{tip_kml[1]},0

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
    end_rgb,
    steps=BEZIER_STEPS,
    shaft_width=SHAFT_WIDTH,
    head_length=HEAD_LENGTH,
    head_width=HEAD_WIDTH
):
    curve = bezier_curve(
        start,
        control,
        end,
        steps=steps
    )

    shaft_curve = truncate_for_head(
        curve,
        head_length
    )

    shaft, shaft_left_end, shaft_right_end = create_shaft(
        shaft_curve,
        start_rgb,
        end_rgb,
        shaft_width=shaft_width
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
        head_length=head_length,
        head_width=head_width,
        shaft_left_end=shaft_left_end,
        shaft_right_end=shaft_right_end
    )

    return shaft + head

def climate_icon(name, lon, lat, icon_url, scale=ICON_SCALE):
    norm_lon = normalize_lon(lon)
    return f"""
<Placemark>

<name>{name}</name>

<Style>

<IconStyle>

<scale>{scale}</scale>

<Icon>
<href>{icon_url}</href>
</Icon>

</IconStyle>

</Style>

<Point>
<coordinates>{norm_lon},{lat},0</coordinates>
</Point>

</Placemark>
"""

def generate_nina_flow():
    kml = ""

    rng = random.Random(29)

    for lane_idx, lane_segments in enumerate(ALL_LANES):
        num_segments = len(lane_segments)

        for seg_idx, (start, control, end) in enumerate(lane_segments):
            s_pt = (start[0], start[1])
            e_pt = (end[0], end[1])

            c_lat_jitter = rng.uniform(-1.8, 1.8)
            c_lon_jitter = rng.uniform(-0.8, 0.8)
            c_pt = (control[0] + c_lon_jitter, control[1] + c_lat_jitter)

            t_start = seg_idx / float(num_segments)
            t_end = (seg_idx + 1) / float(num_segments)

            start_rgb = get_nina_palette_color(t_start)
            end_rgb = get_nina_palette_color(t_end)

            kml += create_arrow(
                start=s_pt,
                control=c_pt,
                end=e_pt,
                start_rgb=start_rgb,
                end_rgb=end_rgb,
                steps=BEZIER_STEPS,
                shaft_width=SHAFT_WIDTH,
                head_length=HEAD_LENGTH,
                head_width=HEAD_WIDTH
            )

    return kml

def generate_peru_upwelling():
    kml = ""

    upwelling_arrows = [

        (-84, -16, (-85.5), -7,  (-84),  2),
        (-80, -10, (-81.5), -2,  (-80),  6),
        (-76,  -4, (-77.5),  4,  (-76), 10),
    ]

    up_shaft_width = 0.36
    up_head_length = 1.8
    up_head_width = 0.90

    for (slon, slat, clon, clat, elon, elat) in upwelling_arrows:
        start_rgb = (0, 220, 255)
        end_rgb   = (0,  80, 200)

        kml += create_arrow(
            start=(slon, slat),
            control=(clon, clat),
            end=(elon, elat),
            start_rgb=start_rgb,
            end_rgb=end_rgb,
            steps=BEZIER_STEPS,
            shaft_width=up_shaft_width,
            head_length=up_head_length,
            head_width=up_head_width
        )

    return kml

def generate_climate_icons():
    kml = ""

    rain_west = [
        ("Indonesia Heavy Rain",         118,  -3),
        ("Western Indonesia Rain",       108,  -6),
        ("Papua New Guinea Rain",        145,  -6),
        ("Philippines Monsoon",          122,  13),
        ("Philippine Sea Storms",        130,  18),
    ]
    for name, lon, lat in rain_west:
        kml += climate_icon(name, lon, lat, RAIN_ICON)

    monsoon_asia = [
        ("India Strong Monsoon",         78,  20),
        ("Sri Lanka Heavy Rain",         80,   7),
        ("Bangladesh Flooding",          90,  24),
        ("Myanmar Heavy Rain",           96,  20),
    ]
    for name, lon, lat in monsoon_asia:
        kml += climate_icon(name, lon, lat, RAIN_ICON)

    rain_australia = [
        ("Northern Australia Rain",     133, -16),
        ("Eastern Australia Rain",      149, -26),
        ("Queensland Flooding",         145, -20),
    ]
    for name, lon, lat in rain_australia:
        kml += climate_icon(name, lon, lat, RAIN_ICON)

    flood_regions = [
        ("Indonesia Flooding",          115,  -8),
        ("Papua New Guinea Flooding",   147,  -8),
        ("Northern Australia Flooding", 131, -14),
        ("Bangladesh Flooding",          92,  23),
    ]
    for name, lon, lat in flood_regions:
        kml += climate_icon(name, lon, lat, FLOOD_ICON)

    drought_east = [
        ("Peru Drought",               -76, -12),
        ("Ecuador Drought",            (-79),  -1),
        ("Northern Chile Drought",     (-70), -28),
        ("California Drought",        (-120),  37),
        ("Southern USA Drought",       (-98),  32),
        ("Northern Mexico Drought",   (-104),  27),
    ]
    for name, lon, lat in drought_east:
        kml += climate_icon(name, lon, lat, DROUGHT_ICON)

    west_pacific_storms = [
        ("Western Pacific Typhoon Zone",  155,  18),
        ("Central Pacific Reduced Rain", -160,  10),
        ("Tropical Western Pacific",      148,   8),
    ]
    for name, lon, lat in west_pacific_storms:
        kml += climate_icon(name, lon, lat, RAIN_ICON)

    return kml

def wrap(content):
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
<name>La Niña — Pacific Trade Wind &amp; Cold Upwelling Visualization</name>

{content}

</Document>
</kml>
"""

def main():
    content = (
        generate_nina_flow()
        + generate_peru_upwelling()
        + generate_climate_icons()
    )
    final_kml = wrap(content)

    filename = "la_nina.kml"
    with open(filename, "w", encoding="utf-8") as f:
        f.write(final_kml)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    assets_dir = os.path.abspath(os.path.join(script_dir, "..", "assets", "kml"))
    os.makedirs(assets_dir, exist_ok=True)
    asset_path = os.path.join(assets_dir, filename)
    with open(asset_path, "w", encoding="utf-8") as f:
        f.write(final_kml)

    print(f"la_nina.kml generated successfully in current directory and {asset_path}")

if __name__ == "__main__":
    main()
