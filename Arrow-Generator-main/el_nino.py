import math
import random

# =====================================================
# CONFIG & ICONS
# =====================================================

RAIN_ICON = "https://i.imgur.com/qoXQjzD.png"
DROUGHT_ICON = "https://i.imgur.com/BNMYBFx.png"
FLOOD_ICON = "https://i.imgur.com/hJkMlqT.png"

MONSOON_ICON = RAIN_ICON
STORM_ICON = RAIN_ICON
WARM_ICON = DROUGHT_ICON

ICON_SCALE = 4.5

# Arrow configuration for main ENSO flow  (-15% from previous)
SHAFT_WIDTH = 0.51
HEAD_LENGTH = 2.04
HEAD_WIDTH = 1.02

BEZIER_STEPS = 120

# Oceanographically refined lane geometries (3 distinct branches)

# Top Lane: Northern Branch (-20% curvature from previous)
LANE_TOP_SEGMENTS = [
    ((130, 4.5), (140, 9.2),  (150, 6.0)),
    ((153, 6.0), (163, 10.4), (173, 7.2)),
    ((-173, 7.2), (-163, 10.8), (-153, 6.8)),
    ((-150, 6.8), (-138, 8.8), (-127, 5.2)),
    ((-124, 5.2), (-114, 7.6), (-104, 3.5)),
    ((-101, 3.5), (-95,  5.6), (-90,  2.0))
]

# Middle Lane: Equatorial Core (-20% curvature from previous)
LANE_MIDDLE_SEGMENTS = [
    ((130, -0.8), (140, 3.2),  (150, -0.2)),
    ((153, -0.2), (163, 3.6),  (173, 0.4)),
    ((-173, 0.4), (-163, 3.2), (-153, 0.4)),
    ((-150, 0.4), (-138, 2.8), (-127, 0.1)),
    ((-124, 0.1), (-114, 2.4), (-104, 0.0)),
    ((-101, 0.0), (-95,  2.0), (-90,  0.0))
]

# Bottom Lane: Southern Branch (-20% curvature from previous)
LANE_BOTTOM_SEGMENTS = [
    ((130, -6.0), (140, -10.4), (150, -6.8)),
    ((153, -6.8), (163, -10.8), (173, -7.0)),
    ((-173, -7.0), (-163, -10.4), (-153, -6.2)),
    ((-150, -6.2), (-138, -8.8),  (-127, -4.5)),
    ((-124, -4.5), (-114, -7.6),  (-104, -3.0)),
    ((-101, -3.0), (-95,  -5.6),  (-90,  -2.0))
]

ALL_LANES = [
    LANE_BOTTOM_SEGMENTS,
    LANE_MIDDLE_SEGMENTS,
    LANE_TOP_SEGMENTS
]

# Warm-water palette: Red -> Orange -> Yellow
WARM_PALETTE = [
    (220, 30, 30),    # hot red
    (255, 100, 0),    # deep orange
    (255, 170, 0),    # orange-yellow
    (255, 220, 0)     # yellow
]


# =====================================================
# GEOMETRY & COORDINATE UTILITIES
# =====================================================

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


# =====================================================
# COLOR SYSTEM & INTERPOLATION
# =====================================================

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


def get_warm_palette_color(t):
    """
    Interpolate an RGB tuple from WARM_PALETTE given normalized progress t in [0, 1].
    """
    t = max(0.0, min(1.0, t))
    n_intervals = len(WARM_PALETTE) - 1
    scaled = t * n_intervals
    idx = int(scaled)
    if idx >= n_intervals:
        return WARM_PALETTE[-1]
    local_t = scaled - idx
    return interpolate_rgb(WARM_PALETTE[idx], WARM_PALETTE[idx + 1], local_t)


# =====================================================
# BEZIER CURVE
# =====================================================

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

def create_segment_polygon(p1, p2, color, shaft_width=SHAFT_WIDTH):
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    length = math.hypot(dx, dy)

    if length == 0:
        return ""

    nx = -dy / length
    ny = dx / length

    left1 = (
        normalize_lon(p1[0] + nx * shaft_width),
        p1[1] + ny * shaft_width
    )
    right1 = (
        normalize_lon(p1[0] - nx * shaft_width),
        p1[1] - ny * shaft_width
    )
    left2 = (
        normalize_lon(p2[0] + nx * shaft_width),
        p2[1] + ny * shaft_width
    )
    right2 = (
        normalize_lon(p2[0] - nx * shaft_width),
        p2[1] - ny * shaft_width
    )

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


# =====================================================
# SHAFT
# =====================================================

def create_shaft(points, start_rgb, end_rgb, shaft_width=SHAFT_WIDTH):
    kml = ""
    total = len(points) - 1

    if total <= 0:
        return ""

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
            color,
            shaft_width=shaft_width
        )

    return kml


# =====================================================
# ARROWHEAD
# =====================================================

def create_head(base, tip, color, head_length=HEAD_LENGTH, head_width=HEAD_WIDTH):
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


# =====================================================
# COMPLETE ARROW
# =====================================================

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

    shaft = create_shaft(
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
        head_width=head_width
    )

    return shaft + head


# =====================================================
# PLACEMARK ICON
# =====================================================

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


# =====================================================
# EL NIÑO MAIN FLOW & PERU UPWELLING & CLIMATE ICONS
# =====================================================

def generate_enso_flow():
    kml = ""
    # Seeded RNG — reproducible organic variation without full chaos
    rng = random.Random(17)

    for lane_idx, lane_segments in enumerate(ALL_LANES):
        num_segments = len(lane_segments)

        for seg_idx, (start, control, end) in enumerate(lane_segments):
            s_pt = (start[0], start[1])
            e_pt = (end[0], end[1])

            # Add ±1.8° lat jitter to control point — each arrow curves differently
            c_lat_jitter = rng.uniform(-1.8, 1.8)
            c_lon_jitter = rng.uniform(-0.8, 0.8)
            c_pt = (control[0] + c_lon_jitter, control[1] + c_lat_jitter)

            # Warm palette gradient (Red -> Orange -> Yellow)
            t_start = seg_idx / float(num_segments)
            t_end = (seg_idx + 1) / float(num_segments)

            start_rgb = get_warm_palette_color(t_start)
            end_rgb = get_warm_palette_color(t_end)

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
    upwelling_lons = [-88, -84, -80]

    # Smaller than main ENSO flow
    small_shaft_width = 0.28
    small_head_length = 1.4
    small_head_width = 0.70

    for lon in upwelling_lons:
        start = (lon, -10)
        control = (lon - 1, -4)
        end = (lon, 2)

        start_rgb = (0, 220, 255)
        end_rgb = (0, 100, 255)

        kml += create_arrow(
            start=start,
            control=control,
            end=end,
            start_rgb=start_rgb,
            end_rgb=end_rgb,
            steps=BEZIER_STEPS,
            shaft_width=small_shaft_width,
            head_length=small_head_length,
            head_width=small_head_width
        )

    return kml


def generate_climate_icons():
    kml = ""

    # Drought Regions
    drought_locations = [
        ("Indonesia Drought", 118, -3),
        ("Western Indonesia Drought", 110, -6),
        ("Papua Drought", 145, -6),
        ("Philippines Drought", 122, 13),
        ("Northern Australia Drought", 135, -18),
        ("Central Australia Drought", 134, -25),
        ("Western Australia Drought", 121, -22),
        ("Coral Sea Warming", 155, -18)
    ]
    for name, lon, lat in drought_locations:
        kml += climate_icon(name, lon, lat, DROUGHT_ICON)

    # Weak Monsoon Regions
    monsoon_locations = [
        ("India Weak Monsoon", 78, 20),
        ("Sri Lanka Weak Monsoon", 80, 7),
        ("Bangladesh Weak Monsoon", 90, 24),
        ("Myanmar Weak Monsoon", 96, 20)
    ]
    for name, lon, lat in monsoon_locations:
        kml += climate_icon(name, lon, lat, RAIN_ICON)

    # Flooding Regions
    flooding_locations = [
        ("Peru Flooding", -77, -10),
        ("Northern Peru Flooding", -79, -5),
        ("Ecuador Flooding", -79, -1),
        ("Northern Chile Flooding", -70, -22),
        ("Central America Flooding", -90, 15)
    ]
    for name, lon, lat in flooding_locations:
        kml += climate_icon(name, lon, lat, FLOOD_ICON)

    # Wetter North America
    wetter_na_locations = [
        ("Southern USA Wetter", -95, 31),
        ("Texas Wetter", -99, 31),
        ("California Wet Winter", -120, 37),
        ("Mexico Pacific Storms", -105, 20)
    ]
    for name, lon, lat in wetter_na_locations:
        kml += climate_icon(name, lon, lat, RAIN_ICON)

    # Pacific Storm Regions
    storm_locations = [
        ("Central Pacific Storms", -145, 10),
        ("Eastern Pacific Storms", -120, 15),
        ("Tropical Pacific Activity", -135, 5)
    ]
    for name, lon, lat in storm_locations:
        kml += climate_icon(name, lon, lat, RAIN_ICON)

    return kml


# =====================================================
# WRAP KML
# =====================================================

def wrap(content):
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
<name>El Niño Pacific Conveyor &amp; Climate Impacts</name>

{content}

</Document>
</kml>
"""


# =====================================================
# MAIN
# =====================================================

def main():
    content = generate_enso_flow() + generate_peru_upwelling() + generate_climate_icons()
    final_kml = wrap(content)

    with open("el_nino.kml", "w", encoding="utf-8") as f:
        f.write(final_kml)

    print("el_nino.kml generated successfully")


if __name__ == "__main__":
    main()
