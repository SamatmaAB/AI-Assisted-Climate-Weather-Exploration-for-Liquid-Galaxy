import math

# -----------------------------
# YOUR ICON LINKS
# -----------------------------
RAIN_ICON = "https://i.imgur.com/qoXQjzD.png"
LOW_ICON = "https://i.imgur.com/VJIrVJN.png"


# -----------------------------
# 1. Bezier Curve
# -----------------------------
def bezier_curve(start, control, end, steps=120):
    points = []

    for i in range(steps + 1):
        t = i / steps

        lon = (
            (1 - t) ** 2 * start[0]
            + 2 * (1 - t) * t * control[0]
            + t ** 2 * end[0]
        )

        lat = (
            (1 - t) ** 2 * start[1]
            + 2 * (1 - t) * t * control[1]
            + t ** 2 * end[1]
        )

        points.append((lon, lat))

    return points


# -----------------------------
# 2. COLOR GRADIENT
# Blue → Cyan → Green → Yellow → Red
# -----------------------------
def interpolate_color(t):
    # Shades of Cyan-Blue: Blue (t=0) -> Cyan (t=1)
    r = 0
    g = int(255 * t)
    b = 255
    # KML format = aabbggrr (using b3 for 70% opacity)
    return f"b3{b:02x}{g:02x}{r:02x}"


# -----------------------------
# 3. ONE RIBBON SEGMENT
# -----------------------------
def create_segment_polygon(
        p1,
        p2,
        color,
        width=0.45):

    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]

    length = math.sqrt(dx * dx + dy * dy)

    if length == 0:
        return ""

    nx = -dy / length
    ny = dx / length

    left1 = (
        p1[0] + nx * width,
        p1[1] + ny * width
    )

    right1 = (
        p1[0] - nx * width,
        p1[1] - ny * width
    )

    left2 = (
        p2[0] + nx * width,
        p2[1] + ny * width
    )

    right2 = (
        p2[0] - nx * width,
        p2[1] - ny * width
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


# -----------------------------
# 4. FULL GRADIENT RIBBON
# -----------------------------
def create_gradient_ribbon(points):

    kml = ""

    total = len(points) - 1

    for i in range(total):

        t = i / total

        color = interpolate_color(t)

        kml += create_segment_polygon(
            points[i],
            points[i + 1],
            color,
            width=0.35
        )

    return kml


# -----------------------------
# 5. ARROWHEAD
# -----------------------------
def create_arrowhead(
        p1,
        p2,
        color,
        size=1.5):

    angle = math.atan2(
        p2[1] - p1[1],
        p2[0] - p1[0]
    )

    left = (
        p2[0] - size * math.cos(angle - math.pi / 6),
        p2[1] - size * math.sin(angle - math.pi / 6)
    )

    right = (
        p2[0] - size * math.cos(angle + math.pi / 6),
        p2[1] - size * math.sin(angle + math.pi / 6)
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

            <outerBoundaryIs>
                <LinearRing>
                    <coordinates>

                        {p2[0]},{p2[1]},0
                        {left[0]},{left[1]},0
                        {right[0]},{right[1]},0
                        {p2[0]},{p2[1]},0

                    </coordinates>
                </LinearRing>
            </outerBoundaryIs>

        </Polygon>

    </Placemark>
    """


# -----------------------------
# 6. ARROW GENERATOR
# -----------------------------
def truncate_curve_by_distance(curve, target_distance):
    cum_dist = 0.0
    for i in range(len(curve) - 2, -1, -1):
        p1 = curve[i]
        p2 = curve[i + 1]
        dx = p2[0] - p1[0]
        dy = p2[1] - p1[1]
        d = math.sqrt(dx * dx + dy * dy)
        if cum_dist + d >= target_distance:
            remaining = target_distance - cum_dist
            t = remaining / d
            bx = p2[0] - t * dx
            by = p2[1] - t * dy
            return list(curve[:i + 1]) + [(bx, by)]
        cum_dist += d
    return [curve[0], curve[-1]]


def generate_arrow(
        start,
        end,
        curvature):

    cx = (start[0] + end[0]) / 2
    cy = (start[1] + end[1]) / 2 + curvature

    curve = bezier_curve(
        start,
        (cx, cy),
        end,
        steps=120
    )

    size = 1.2
    arrowhead_len = size * math.cos(math.pi / 6)
    truncated_curve = truncate_curve_by_distance(curve, arrowhead_len)

    arrow_tip_color = interpolate_color(1.0)

    return (
        create_gradient_ribbon(truncated_curve)
        +
        create_arrowhead(
            truncated_curve[-1],
            curve[-1],
            arrow_tip_color,
            size=size
        )
    )


# -----------------------------
# 7. ICON FUNCTION
# -----------------------------
def create_icon(
        lon,
        lat,
        icon,
        scale=2.0):

    return f"""
    <Placemark>

        <Style>
            <IconStyle>

                <scale>{scale}</scale>

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


# -----------------------------
# 8. MONSOON VISUALIZATION
# -----------------------------
def monsoon():

    kml = ""

    # --- Arabian Sea Branch ---
    # Flow towards Gujarat (Saurashtra) - Shorter & shifted north
    kml += generate_arrow(
        (63, 15),
        (70, 22),
        2
    )
    # Flow towards Mumbai / Maharashtra - Shorter
    kml += generate_arrow(
        (64, 10),
        (72.8, 18.8),
        2.5
    )
    # Flow towards Deccan Plateau / Karnataka - Shorter
    kml += generate_arrow(
        (66, 6),
        (75, 13),
        2.5
    )
    # Flow hitting Kerala - Shorter
    kml += generate_arrow(
        (69, 3),
        (76.2, 9.9),
        2
    )

    # --- Bay of Bengal Branch ---
    # Flow towards Bangladesh / Northeast India - Shorter
    kml += generate_arrow(
        (86, 12),
        (91.5, 22.5),
        2.5
    )
    # Flow towards West Bengal / Kolkata - Shorter
    kml += generate_arrow(
        (84, 10),
        (88.3, 21.5),
        2.5
    )
    # Flow towards Odisha / Visakhapatnam Coast - Shorter
    kml += generate_arrow(
        (81, 7),
        (84.5, 18),
        2
    )
    # Deflected flow along the Gangetic Plain towards North India - Offset to avoid overlap
    kml += generate_arrow(
        (87, 23),
        (78, 27),
        -2
    )

    # Low Pressure Icon (Monsoon trough over Northwest India/Rajasthan Desert)
    kml += create_icon(
        73,
        27,
        LOW_ICON,
        scale=5.0
    )

    # Rain Icons (Geographically placed around major precipitation zones to avoid overlapping with arrowheads)
    rain_points = [
        (76.2, 10.5), # Kerala
        (75.5, 13.5), # Karnataka Coast
        (73.5, 19.2), # Mumbai / Western Ghats
        (79, 21),     # Central India (Nagpur)
        (85.5, 18.5), # Odisha Coast
        (92.5, 25.2), # Northeast India (Cherrapunji / Assam)
        (85, 24.5),   # Gangetic Plain (Bihar/UP)
        (77, 28.5)    # North India (Delhi)
    ]

    for lon, lat in rain_points:
        kml += create_icon(
            lon,
            lat,
            RAIN_ICON,
            scale=3.5
        )

    return kml


# -----------------------------
# 9. WRAP KML
# -----------------------------
def wrap_kml(content):

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">

<Document>

<name>Indian Monsoon Gradient Visualization</name>

{content}

</Document>

</kml>
"""


# -----------------------------
# 10. MAIN
# -----------------------------
def main():

    kml = monsoon()

    final = wrap_kml(kml)

    with open("monsoon_gradient.kml", "w") as f:
        f.write(final)

    print("monsoon_gradient.kml generated successfully!")


if __name__ == "__main__":
    main()