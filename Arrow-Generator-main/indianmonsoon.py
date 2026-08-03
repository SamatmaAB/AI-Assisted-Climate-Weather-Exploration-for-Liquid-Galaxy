import json
import math
import os
from pathlib import Path


# ============================================================
# ICON LINKS
# ============================================================

RAIN_ICON = "https://i.imgur.com/qoXQjzD.png"
LOW_ICON = "https://i.imgur.com/VJIrVJN.png"


# ============================================================
# PATHS
# ============================================================
#
# This file is expected to live in:
#
#   <project>/Arrow-Generator-main/indian_monsoon.py
#
# while the processed ERA5 data lives in:
#
#   <project>/data/processed/monsoon/monsoon_paths_2025.json
#
# We locate the project root dynamically so the generator
# does not depend on the current working directory.
# ============================================================

SCRIPT_DIR = Path(__file__).resolve().parent


def find_project_root() -> Path:
    """
    Find the repository root by walking upward until the processed
    monsoon JSON is found.

    This makes the generator work even if its exact folder depth
    changes later.
    """

    current = SCRIPT_DIR

    while True:
        candidate = (
            current
            / "data"
            / "processed"
            / "monsoon"
            / "monsoon_paths_2025.json"
        )

        if candidate.exists():
            return current

        if current.parent == current:
            break

        current = current.parent

    raise FileNotFoundError(
        "Could not locate the project root containing:\n"
        "data/processed/monsoon/monsoon_paths_2025.json\n\n"
        f"Generator location:\n{SCRIPT_DIR}"
    )


PROJECT_ROOT = find_project_root()

MONSOON_DATA_FILE = (
    PROJECT_ROOT
    / "data"
    / "processed"
    / "monsoon"
    / "monsoon_paths_2025.json"
)


# ============================================================
# VISUAL SETTINGS
# ============================================================

RIBBON_WIDTH = 0.35
ARROWHEAD_SIZE = 1.2
ARROW_GAP = 0.30


# ============================================================
# 1. LOAD ERA5-DERIVED MONSOON PATHS
# ============================================================

def load_monsoon_paths():
    """
    Load the final representative monsoon trajectories generated
    by tools/monsoon/process_monsoon.py.

    Each path contains ordered points with:

        lon
        lat
        u
        v
        speed

    The lon/lat coordinates become the ribbon centerline.
    """

    if not MONSOON_DATA_FILE.exists():
        raise FileNotFoundError(
            "Processed monsoon path file not found:\n"
            f"{MONSOON_DATA_FILE}\n\n"
            "Run tools/monsoon/process_monsoon.py first."
        )

    with MONSOON_DATA_FILE.open(
        "r",
        encoding="utf-8",
    ) as file:
        data = json.load(file)

    paths = data.get("paths")

    if not isinstance(paths, list):
        raise ValueError(
            "Invalid monsoon JSON: expected 'paths' to be a list."
        )

    if not paths:
        raise ValueError(
            "No monsoon paths were found in the processed JSON."
        )

    print(
        f"Loaded {len(paths)} ERA5-derived monsoon paths from:\n"
        f"{MONSOON_DATA_FILE}"
    )

    return data


# ============================================================
# 2. COLOR GRADIENT
# ============================================================
#
# Existing visual style:
#
# Blue -> Cyan
#
# KML color format:
#
#   AABBGGRR
#
# b3 = approximately 70% opacity
# ============================================================

def interpolate_color(t):
    """
    Interpolate from blue at the beginning of the trajectory
    to cyan at the arrow tip.
    """

    t = max(
        0.0,
        min(
            1.0,
            float(t),
        ),
    )

    r = 0
    g = int(255 * t)
    b = 255

    return f"d9{b:02x}{g:02x}{r:02x}"


# ============================================================
# 3. VERTEX BOUNDARY
# ============================================================

def compute_boundary_vertices(
    points,
    width=RIBBON_WIDTH,
):
    """
    Construct the left and right edges of a ribbon around
    an ordered trajectory.

    The input trajectory is the ERA5-derived centerline.
    """

    n = len(points)

    if n < 2:
        return [], []

    seg_normals = []

    for i in range(n - 1):

        dx = (
            points[i + 1][0]
            -
            points[i][0]
        )

        dy = (
            points[i + 1][1]
            -
            points[i][1]
        )

        length = math.hypot(
            dx,
            dy,
        )

        if length > 0:

            nx = -dy / length
            ny = dx / length

        else:

            nx = 0.0
            ny = 0.0

        seg_normals.append(
            (
                nx,
                ny,
            )
        )

    vertex_normals = []

    for i in range(n):

        if i == 0:

            vertex_normals.append(
                seg_normals[0]
            )

        elif i == n - 1:

            vertex_normals.append(
                seg_normals[-1]
            )

        else:

            n_prev = seg_normals[i - 1]
            n_next = seg_normals[i]

            nx_sum = (
                n_prev[0]
                +
                n_next[0]
            )

            ny_sum = (
                n_prev[1]
                +
                n_next[1]
            )

            norm = math.hypot(
                nx_sum,
                ny_sum,
            )

            if norm > 0:

                vertex_normals.append(
                    (
                        nx_sum / norm,
                        ny_sum / norm,
                    )
                )

            else:

                vertex_normals.append(
                    n_prev
                )

    left_boundary = []
    right_boundary = []

    for i in range(n):

        nx, ny = vertex_normals[i]

        left_boundary.append(
            (
                points[i][0] + nx * width,
                points[i][1] + ny * width,
            )
        )

        right_boundary.append(
            (
                points[i][0] - nx * width,
                points[i][1] - ny * width,
            )
        )

    return (
        left_boundary,
        right_boundary,
    )


# ============================================================
# 4. SHAFT QUAD
# ============================================================

def create_quad_polygon(
    left1,
    left2,
    right2,
    right1,
    color,
):

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


# ============================================================
# 5. FULL GRADIENT RIBBON
# ============================================================

def create_gradient_ribbon(
    points,
    width=RIBBON_WIDTH,
):

    if len(points) < 2:
        return "", None, None

    (
        left_boundary,
        right_boundary,
    ) = compute_boundary_vertices(
        points,
        width,
    )

    if not left_boundary or not right_boundary:
        return "", None, None

    kml = ""

    total = len(points) - 1

    for i in range(total):

        t = i / total

        color = interpolate_color(
            t
        )

        kml += create_quad_polygon(
            left_boundary[i],
            left_boundary[i + 1],
            right_boundary[i + 1],
            right_boundary[i],
            color,
        )

    return (
        kml,
        left_boundary[-1],
        right_boundary[-1],
    )


# ============================================================
# 6. ARROWHEAD
# ============================================================

def create_arrowhead(
    p1,
    p2,
    color,
    size=ARROWHEAD_SIZE,
    shaft_left_end=None,
    shaft_right_end=None,
):

    angle = math.atan2(
        p2[1] - p1[1],
        p2[0] - p1[0],
    )

    left = (
        p2[0]
        -
        size
        *
        math.cos(
            angle
            -
            math.pi / 6
        ),

        p2[1]
        -
        size
        *
        math.sin(
            angle
            -
            math.pi / 6
        ),
    )

    right = (
        p2[0]
        -
        size
        *
        math.cos(
            angle
            +
            math.pi / 6
        ),

        p2[1]
        -
        size
        *
        math.sin(
            angle
            +
            math.pi / 6
        ),
    )

    if (
        shaft_left_end is not None
        and
        shaft_right_end is not None
    ):

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
                        {shaft_left_end[0]},{shaft_left_end[1]},0
                        {shaft_right_end[0]},{shaft_right_end[1]},0
                        {right[0]},{right[1]},0
                        {p2[0]},{p2[1]},0
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


# ============================================================
# 7. TRUNCATE PATH FOR ARROWHEAD
# ============================================================

def truncate_curve_by_distance(
    curve,
    target_distance,
):
    """
    Remove a small distance from the end of the ribbon so the
    arrowhead can occupy that space without overlapping the shaft.

    The original final point remains the arrow tip.
    """

    if len(curve) < 2:
        return list(curve)

    cumulative_distance = 0.0

    for i in range(
        len(curve) - 2,
        -1,
        -1,
    ):

        p1 = curve[i]
        p2 = curve[i + 1]

        dx = (
            p2[0]
            -
            p1[0]
        )

        dy = (
            p2[1]
            -
            p1[1]
        )

        distance = math.hypot(
            dx,
            dy,
        )

        if distance <= 0:
            continue

        if (
            cumulative_distance
            +
            distance
            >= target_distance
        ):

            remaining = (
                target_distance
                -
                cumulative_distance
            )

            t = (
                remaining
                /
                distance
            )

            bx = (
                p2[0]
                -
                t * dx
            )

            by = (
                p2[1]
                -
                t * dy
            )

            return (
                list(
                    curve[:i + 1]
                )
                +
                [
                    (
                        bx,
                        by,
                    )
                ]
            )

        cumulative_distance += (
            distance
        )

    # The path is shorter than the requested arrowhead length.
    # Keep enough geometry to construct an arrow.
    return [
        curve[0],
        curve[-1],
    ]


# ============================================================
# 8. TRIM PATH START FOR INTER-ARROW GAP
# ============================================================

def trim_curve_start_by_distance(
    curve,
    target_distance,
):
    """
    Remove a small distance from the beginning of a trajectory.

    Together with a small extra trim at the end, this creates
    visual separation between neighboring arrow paths without
    shifting the ERA5-derived trajectory sideways.
    """

    if len(curve) < 2 or target_distance <= 0:
        return list(curve)

    cumulative_distance = 0.0

    for i in range(len(curve) - 1):
        p1 = curve[i]
        p2 = curve[i + 1]

        dx = p2[0] - p1[0]
        dy = p2[1] - p1[1]

        distance = math.hypot(dx, dy)

        if distance <= 0:
            continue

        if cumulative_distance + distance >= target_distance:
            remaining = target_distance - cumulative_distance
            t = remaining / distance

            new_start = (
                p1[0] + t * dx,
                p1[1] + t * dy,
            )

            return [new_start] + list(curve[i + 1:])

        cumulative_distance += distance

    return list(curve)


# ============================================================
# 9. ERA5 PATH -> GRADIENT ARROW
# ============================================================

def generate_arrow_from_path(
    points,
    width=RIBBON_WIDTH,
    arrowhead_size=ARROWHEAD_SIZE,
):
    """
    Turn an ERA5-derived trajectory directly into the existing
    gradient ribbon + arrowhead visualization.

    No Bezier curve is generated here.

    The JSON trajectory itself is the centerline.
    """

    if len(points) < 2:
        return ""

    # Trim half the configured gap from the beginning.
    # The trajectory itself is not displaced.
    points = trim_curve_start_by_distance(
        points,
        ARROW_GAP / 2,
    )

    if len(points) < 2:
        return ""

    arrowhead_length = (
        arrowhead_size
        *
        math.cos(
            math.pi / 6
        )
    )

    # Reserve the normal arrowhead length plus half the gap
    # at the end of the shaft.
    truncated_curve = (
        truncate_curve_by_distance(
            points,
            arrowhead_length + ARROW_GAP / 2,
        )
    )

    if len(truncated_curve) < 2:
        return ""

    (
        ribbon_kml,
        shaft_left_end,
        shaft_right_end,
    ) = create_gradient_ribbon(
        truncated_curve,
        width=width,
    )

    arrow_tip_color = (
        interpolate_color(
            1.0
        )
    )

    arrowhead_kml = (
        create_arrowhead(
            truncated_curve[-1],
            points[-1],
            arrow_tip_color,
            size=arrowhead_size,
            shaft_left_end=shaft_left_end,
            shaft_right_end=shaft_right_end,
        )
    )

    return (
        ribbon_kml
        +
        arrowhead_kml
    )


# ============================================================
# 10. CONVERT JSON PATH TO COORDINATES
# ============================================================

def extract_coordinates(
    path_data,
):
    """
    Extract (longitude, latitude) tuples from one processed path.
    """

    raw_points = path_data.get(
        "points",
        [],
    )

    coordinates = []

    for point in raw_points:

        if not isinstance(
            point,
            dict,
        ):
            continue

        lon = point.get(
            "lon"
        )

        lat = point.get(
            "lat"
        )

        if (
            lon is None
            or
            lat is None
        ):
            continue

        try:
            lon = float(lon)
            lat = float(lat)

        except (
            TypeError,
            ValueError,
        ):
            continue

        if not (
            math.isfinite(lon)
            and
            math.isfinite(lat)
        ):
            continue

        coordinates.append(
            (
                lon,
                lat,
            )
        )

    return coordinates


# ============================================================
# 11. ICON FUNCTION
# ============================================================

def create_icon(
    lon,
    lat,
    icon,
    scale=2.0,
):

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


# ============================================================
# 12. MONSOON VISUALIZATION
# ============================================================

def monsoon():

    data = load_monsoon_paths()

    paths = data[
        "paths"
    ]

    kml = ""

    print(
        "\n=== GENERATING ERA5 MONSOON RIBBONS ==="
    )

    generated_count = 0

    for path_data in paths:

        path_id = path_data.get(
            "id",
            "unknown",
        )

        coordinates = (
            extract_coordinates(
                path_data
            )
        )

        if len(coordinates) < 2:

            print(
                f"Skipping {path_id}: "
                "fewer than two valid coordinates."
            )

            continue

        start = coordinates[0]
        end = coordinates[-1]

        print(
            f"{path_id}: "
            f"{len(coordinates)} points "
            f"| ({start[0]:.2f}, {start[1]:.2f}) "
            f"-> ({end[0]:.2f}, {end[1]:.2f})"
        )

        kml += (
            generate_arrow_from_path(
                coordinates
            )
        )

        generated_count += 1

    print(
        f"\nGenerated "
        f"{generated_count} "
        f"ERA5-derived gradient ribbons."
    )

    # --------------------------------------------------------
    # LOW PRESSURE ICON
    # --------------------------------------------------------
    #
    # Existing visualization marker retained.
    # --------------------------------------------------------

    kml += create_icon(
        73,
        27,
        LOW_ICON,
        scale=5.0,
    )

    # --------------------------------------------------------
    # RAIN ICONS
    # --------------------------------------------------------
    #
    # Existing precipitation-zone markers retained.
    # These are independent of the ribbon geometry.
    # --------------------------------------------------------

    rain_points = [
        (76.2, 10.5),   # Kerala
        (75.5, 13.5),   # Karnataka Coast
        (73.5, 19.2),   # Mumbai / Western Ghats
        (79, 21),       # Central India
        (85.5, 18.5),   # Odisha Coast
        (92.5, 25.2),   # Northeast India
        (85, 24.5),     # Gangetic Plain
        (77, 28.5),     # North India
    ]

    for lon, lat in rain_points:

        kml += create_icon(
            lon,
            lat,
            RAIN_ICON,
            scale=3.5,
        )

    return kml


# ============================================================
# 13. WRAP KML
# ============================================================

def wrap_kml(
    content,
):

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">

<Document>

<name>Indian Monsoon — ERA5 JJAS 2025</name>

{content}

</Document>

</kml>
"""


# ============================================================
# 14. WRITE FILE
# ============================================================

def write_kml(
    path,
    content,
):

    path = Path(
        path
    )

    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with path.open(
        "w",
        encoding="utf-8",
    ) as file:

        file.write(
            content
        )


# ============================================================
# 15. MAIN
# ============================================================

def main():

    print(
        "\n=== INDIAN MONSOON KML GENERATOR ==="
    )

    print(
        f"\nProject root:\n"
        f"{PROJECT_ROOT}"
    )

    print(
        f"\nERA5 path data:\n"
        f"{MONSOON_DATA_FILE}"
    )

    # --------------------------------------------------------
    # Generate KML content
    # --------------------------------------------------------

    kml = monsoon()

    final = wrap_kml(
        kml
    )

    # --------------------------------------------------------
    # Current directory output
    # --------------------------------------------------------

    current_output = (
        Path.cwd()
        /
        "monsoon_gradient.kml"
    )

    write_kml(
        current_output,
        final,
    )

    # --------------------------------------------------------
    # Existing assets/kml output
    # --------------------------------------------------------
    #
    # Preserve the behavior of the old generator:
    #
    #   <script directory>/../assets/kml/
    #
    # --------------------------------------------------------

    assets_dir = (
        SCRIPT_DIR.parent
        /
        "assets"
        /
        "kml"
    )

    asset_path_gradient = (
        assets_dir
        /
        "monsoon_gradient.kml"
    )

    asset_path_indian = (
        assets_dir
        /
        "indian_monsoon.kml"
    )

    write_kml(
        asset_path_gradient,
        final,
    )

    write_kml(
        asset_path_indian,
        final,
    )

    print(
        "\n=== KML GENERATED SUCCESSFULLY ==="
    )

    print(
        f"\nCurrent-directory copy:\n"
        f"{current_output}"
    )

    print(
        f"\nGradient asset:\n"
        f"{asset_path_gradient}"
    )

    print(
        f"\nIndian monsoon asset:\n"
        f"{asset_path_indian}"
    )


if __name__ == "__main__":
    main()