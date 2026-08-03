from pathlib import Path
import json
import math
import time

import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.pyplot as plt
import numpy as np
import xarray as xr
from scipy.interpolate import RegularGridInterpolator


# ============================================================
# PATHS
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

DATA_FILE = (
    PROJECT_ROOT
    / "data"
    / "era5"
    / "monsoon_850hpa_2025.nc"
)

OUTPUT_DIR = (
    PROJECT_ROOT
    / "data"
    / "processed"
    / "monsoon"
)

JSON_FILE = OUTPUT_DIR / "monsoon_paths_2025.json"

PLOT_FILE = OUTPUT_DIR / "jjas_2025_selected_paths.png"


# ============================================================
# DOMAIN / INTEGRATION
# ============================================================

WEST = 50.0
EAST = 100.0
SOUTH = -10.0
NORTH = 35.0

STREAMLINE_STEP = 0.15
MAX_STREAMLINE_STEPS = 450
MIN_WIND_SPEED = 0.5

SIMPLIFIED_POINTS = 45


# ============================================================
# DENSE CANDIDATE SEEDS
# ============================================================
#
# 14 longitudes x 16 latitudes = 224 Arabian seeds
# 14 longitudes x 16 latitudes = 224 Bay seeds
#
# Total = 448 seeds.
#
# Each seed is integrated both upstream and downstream.
# ============================================================

ARABIAN_SEED_LONGITUDES = np.arange(
    51.0,
    65.0,
    1.0,
)

ARABIAN_SEED_LATITUDES = np.arange(
    5.0,
    21.0,
    1.0,
)

BAY_SEED_LONGITUDES = np.arange(
    80.0,
    94.0,
    1.0,
)

BAY_SEED_LATITUDES = np.arange(
    5.0,
    21.0,
    1.0,
)


# ============================================================
# TARGET REGIONS
# ============================================================

TARGET_REGIONS = {

    "arabian_south": {
        "west": 52.0,
        "east": 70.0,
        "south": 5.0,
        "north": 11.5,
    },

    "arabian_central": {
        "west": 52.0,
        "east": 70.0,
        "south": 10.0,
        "north": 16.0,
    },

    "west_coast": {
        "west": 72.0,
        "east": 76.5,
        "south": 8.0,
        "north": 21.0,
    },

    "south_india": {
        "west": 74.0,
        "east": 81.0,
        "south": 8.0,
        "north": 15.0,
    },

    "central_india": {
        "west": 73.0,
        "east": 84.0,
        "south": 15.0,
        "north": 23.0,
    },

    "punjab_haryana": {
        "west": 73.0,
        "east": 77.5,
        "south": 27.5,
        "north": 32.0,
    },

    "upper_gangetic_plain": {
        "west": 77.0,
        "east": 82.0,
        "south": 25.0,
        "north": 30.5,
    },

    "central_gangetic_plain": {
        "west": 81.0,
        "east": 87.0,
        "south": 24.0,
        "north": 28.5,
    },

    "bay_south": {
        "west": 82.0,
        "east": 94.0,
        "south": 5.0,
        "north": 13.0,
    },

    "bay_central": {
        "west": 82.0,
        "east": 94.0,
        "south": 10.0,
        "north": 19.0,
    },

    "east_india": {
        "west": 82.0,
        "east": 89.5,
        "south": 17.0,
        "north": 24.5,
    },

    "northeast_india": {
        "west": 88.0,
        "east": 96.5,
        "south": 21.0,
        "north": 29.0,
    },
}


# ============================================================
# FINAL VISUAL ROLES
# ============================================================
#
# Five final ribbons:
#
#   Arabian / peninsular: 3
#   Northern India:       1
#   Bay of Bengal:        1
#
# east_northeast has intentionally been removed.
# ============================================================

FINAL_ROLES = [

    {
        "id": "arabian_south",

        "source": "arabian",

        "target": "arabian_south",

        "preferred_latitude": 8.0,

        "clip": {
            "west": 52.0,
            "east": 78.0,
            "south": 4.0,
            "north": 14.0,
        },

        "minimum_target_samples": 8,

        "group": "arabian",
    },
        {
        "id": "punjab_up",

        "source": None,

        "target": "upper_gangetic_plain",

        "preferred_latitude": 20.0,

        "clip": {
            "west": 66.0,
            "east": 89.0,
            "south": 22.0,
            "north": 32.0,
        },

        "minimum_target_samples": 6,

        "group": "north_gangetic",
    },

    {
        "id": "arabian_central",

        "source": "arabian",

        "target": "arabian_central",

        "preferred_latitude": 13.0,

        "clip": {
            "west": 52.0,
            "east": 80.0,
            "south": 9.0,
            "north": 18.0,
        },

        "minimum_target_samples": 8,

        "group": "arabian",
    },

    {
        "id": "central_india",

        "source": None,

        "target": "central_india",

        "preferred_latitude": 17.0,

        "clip": {
            "west": 58.0,
            "east": 92.0,
            "south": 13.0,
            "north": 24.0,
        },

        "minimum_target_samples": 12,

        "group": "central",
    },

    {
        "id": "northwest_india",

        "source": None,

        "target": "punjab_haryana",

        "preferred_latitude": 18.0,

        "clip": {
            "west": 62.0,
            "east": 88.0,
            "south": 19.0,
            "north": 33.0,
        },

        "minimum_target_samples": 6,

        "group": "north",
    },

    {
        "id": "bay_south",

        "source": "bay",

        "target": "bay_south",

        "preferred_latitude": 7.0,

        "clip": {
            "west": 77.0,
            "east": 97.0,
            "south": 4.0,
            "north": 16.0,
        },

        "minimum_target_samples": 8,

        "group": "bay",
    },
]


# ============================================================
# DATASET INSPECTION
# ============================================================

def inspect_dataset(ds: xr.Dataset) -> None:
    """Validate and summarize the ERA5 source."""

    print("\n=== ERA5 DATASET ===")
    print(ds)

    if "u" not in ds or "v" not in ds:
        raise ValueError(
            "Expected ERA5 variables 'u' and 'v' were not found."
        )

    print("\n=== DATA VARIABLES ===")

    for name, variable in ds.data_vars.items():
        print(
            f"{name}: "
            f"dims={variable.dims}, "
            f"shape={variable.shape}"
        )

    speed = np.hypot(
        ds["u"],
        ds["v"],
    )

    print("\n=== ALL MONTHS WIND ===")

    print(
        f"U range: "
        f"{float(ds['u'].min()):.2f} to "
        f"{float(ds['u'].max()):.2f} m/s"
    )

    print(
        f"V range: "
        f"{float(ds['v'].min()):.2f} to "
        f"{float(ds['v'].max()):.2f} m/s"
    )

    print(
        f"Wind speed range: "
        f"{float(speed.min()):.2f} to "
        f"{float(speed.max()):.2f} m/s"
    )


# ============================================================
# DAY-WEIGHTED JJAS MEAN
# ============================================================

def calculate_jjas_mean(ds: xr.Dataset):
    """
    Calculate the day-weighted June-September 2025 mean.

    June      = 30 days
    July      = 31 days
    August    = 31 days
    September = 30 days
    """

    u = ds["u"].sel(
        pressure_level=850
    )

    v = ds["v"].sel(
        pressure_level=850
    )

    times = ds["valid_time"]

    expected_months = {
        6,
        7,
        8,
        9,
    }

    actual_months = set(
        int(month)
        for month in times.dt.month.values
    )

    if not expected_months.issubset(
        actual_months
    ):
        raise ValueError(
            "Dataset does not contain all JJAS months. "
            f"Found months: {sorted(actual_months)}"
        )

    jjas_mask = times.dt.month.isin(
        [6, 7, 8, 9]
    )

    u = u.where(
        jjas_mask,
        drop=True,
    )

    v = v.where(
        jjas_mask,
        drop=True,
    )

    days = (
        u["valid_time"]
        .dt
        .days_in_month
    )

    weights = (
        days
        /
        days.sum()
    )

    print("\n=== JJAS WEIGHTS ===")

    for (
        timestamp,
        day_count,
        weight,
    ) in zip(
        u["valid_time"].values,
        days.values,
        weights.values,
    ):

        timestamp_string = np.datetime_as_string(
            timestamp,
            unit="D",
        )

        print(
            f"{timestamp_string}: "
            f"{int(day_count)} days "
            f"| weight={float(weight):.4f}"
        )

    u_mean = (
        u
        *
        weights
    ).sum(
        dim="valid_time"
    )

    v_mean = (
        v
        *
        weights
    ).sum(
        dim="valid_time"
    )

    speed_mean = np.hypot(
        u_mean,
        v_mean,
    )

    print(
        "\n=== DAY-WEIGHTED JJAS 2025 MEAN ==="
    )

    print(
        f"U range: "
        f"{float(u_mean.min()):.2f} to "
        f"{float(u_mean.max()):.2f} m/s"
    )

    print(
        f"V range: "
        f"{float(v_mean.min()):.2f} to "
        f"{float(v_mean.max()):.2f} m/s"
    )

    print(
        f"Wind speed range: "
        f"{float(speed_mean.min()):.2f} to "
        f"{float(speed_mean.max()):.2f} m/s"
    )

    return (
        u_mean,
        v_mean,
        speed_mean,
    )


# ============================================================
# FAST WIND FIELD
# ============================================================

class WindField:
    """Fast bilinear interpolation of the JJAS mean U/V field."""

    def __init__(
        self,
        u_field: xr.DataArray,
        v_field: xr.DataArray,
    ) -> None:

        latitude = np.asarray(
            u_field["latitude"].values,
            dtype=float,
        )

        longitude = np.asarray(
            u_field["longitude"].values,
            dtype=float,
        )

        u_values = np.asarray(
            u_field.values,
            dtype=float,
        )

        v_values = np.asarray(
            v_field.values,
            dtype=float,
        )

        if latitude[0] > latitude[-1]:

            latitude = latitude[::-1]

            u_values = u_values[::-1, :]
            v_values = v_values[::-1, :]

        if longitude[0] > longitude[-1]:

            longitude = longitude[::-1]

            u_values = u_values[:, ::-1]
            v_values = v_values[:, ::-1]

        self.latitude = latitude
        self.longitude = longitude

        self.south = float(latitude[0])
        self.north = float(latitude[-1])

        self.west = float(longitude[0])
        self.east = float(longitude[-1])

        self.u_interpolator = RegularGridInterpolator(
            (
                latitude,
                longitude,
            ),
            u_values,
            method="linear",
            bounds_error=False,
            fill_value=np.nan,
        )

        self.v_interpolator = RegularGridInterpolator(
            (
                latitude,
                longitude,
            ),
            v_values,
            method="linear",
            bounds_error=False,
            fill_value=np.nan,
        )

    def contains(
        self,
        lon: float,
        lat: float,
    ) -> bool:

        return (
            self.west <= lon <= self.east
            and
            self.south <= lat <= self.north
        )

    def interpolate(
        self,
        lon: float,
        lat: float,
    ):

        if not self.contains(
            lon,
            lat,
        ):
            return None

        point = np.array(
            [
                lat,
                lon,
            ],
            dtype=float,
        )

        u = float(
            np.asarray(
                self.u_interpolator(
                    point
                )
            )[()]
        )

        v = float(
            np.asarray(
                self.v_interpolator(
                    point
                )
            )[()]
        )

        if not (
            np.isfinite(u)
            and
            np.isfinite(v)
        ):
            return None

        return (
            u,
            v,
        )

    def wind_data(
        self,
        lon: float,
        lat: float,
    ):

        wind = self.interpolate(
            lon,
            lat,
        )

        if wind is None:
            return None

        u, v = wind

        speed = math.hypot(
            u,
            v,
        )

        return {
            "u": float(u),
            "v": float(v),
            "speed": float(speed),
        }


# ============================================================
# STREAMLINE DIRECTION
# ============================================================

def streamline_direction(
    wind_field: WindField,
    lon: float,
    lat: float,
    direction: int = 1,
):

    wind = wind_field.interpolate(
        lon,
        lat,
    )

    if wind is None:
        return None

    u, v = wind

    speed = math.hypot(
        u,
        v,
    )

    if speed < MIN_WIND_SPEED:
        return None

    cos_lat = math.cos(
        math.radians(
            lat
        )
    )

    if abs(cos_lat) < 1e-6:
        return None

    dlon = (
        direction
        *
        u
        /
        cos_lat
    )

    dlat = (
        direction
        *
        v
    )

    magnitude = math.hypot(
        dlon,
        dlat,
    )

    if magnitude < 1e-12:
        return None

    return (
        dlon / magnitude,
        dlat / magnitude,
    )


# ============================================================
# RK4 INTEGRATION
# ============================================================

def rk4_step(
    wind_field: WindField,
    lon: float,
    lat: float,
    step_size: float,
    direction: int,
):

    def field(
        x: float,
        y: float,
    ):

        return streamline_direction(
            wind_field,
            x,
            y,
            direction,
        )

    k1 = field(
        lon,
        lat,
    )

    if k1 is None:
        return None

    k2 = field(
        lon + 0.5 * step_size * k1[0],
        lat + 0.5 * step_size * k1[1],
    )

    if k2 is None:
        return None

    k3 = field(
        lon + 0.5 * step_size * k2[0],
        lat + 0.5 * step_size * k2[1],
    )

    if k3 is None:
        return None

    k4 = field(
        lon + step_size * k3[0],
        lat + step_size * k3[1],
    )

    if k4 is None:
        return None

    next_lon = lon + (
        step_size
        /
        6.0
        *
        (
            k1[0]
            +
            2.0 * k2[0]
            +
            2.0 * k3[0]
            +
            k4[0]
        )
    )

    next_lat = lat + (
        step_size
        /
        6.0
        *
        (
            k1[1]
            +
            2.0 * k2[1]
            +
            2.0 * k3[1]
            +
            k4[1]
        )
    )

    return (
        float(next_lon),
        float(next_lat),
    )


# ============================================================
# STREAMLINE TRACING
# ============================================================

def trace_streamline(
    wind_field: WindField,
    start_lon: float,
    start_lat: float,
    direction: int,
):

    points = [
        (
            float(start_lon),
            float(start_lat),
        )
    ]

    lon = float(start_lon)
    lat = float(start_lat)

    for _ in range(
        MAX_STREAMLINE_STEPS
    ):

        next_point = rk4_step(
            wind_field,
            lon,
            lat,
            STREAMLINE_STEP,
            direction,
        )

        if next_point is None:
            break

        next_lon, next_lat = next_point

        if not wind_field.contains(
            next_lon,
            next_lat,
        ):
            break

        movement = math.hypot(
            next_lon - lon,
            next_lat - lat,
        )

        if movement < 1e-5:
            break

        points.append(
            (
                next_lon,
                next_lat,
            )
        )

        lon = next_lon
        lat = next_lat

    return points


def trace_full_streamline(
    wind_field: WindField,
    seed_lon: float,
    seed_lat: float,
):

    backward = trace_streamline(
        wind_field,
        seed_lon,
        seed_lat,
        direction=-1,
    )

    forward = trace_streamline(
        wind_field,
        seed_lon,
        seed_lat,
        direction=1,
    )

    upstream = list(
        reversed(
            backward
        )
    )

    if upstream and forward:
        upstream = upstream[:-1]

    return (
        upstream
        +
        forward
    )


# ============================================================
# GEOGRAPHIC UTILITIES
# ============================================================

def point_in_region(
    point,
    region,
) -> bool:

    lon, lat = point

    return (
        region["west"]
        <= lon
        <= region["east"]

        and

        region["south"]
        <= lat
        <= region["north"]
    )


def count_points_in_region(
    points,
    region,
) -> int:

    return sum(
        1
        for point in points
        if point_in_region(
            point,
            region,
        )
    )


def longest_contiguous_segment(
    points,
    clip,
):

    segments = []
    current = []

    for point in points:

        if point_in_region(
            point,
            clip,
        ):

            current.append(
                point
            )

        else:

            if current:

                segments.append(
                    current
                )

                current = []

    if current:
        segments.append(
            current
        )

    if not segments:
        return []

    return max(
        segments,
        key=len,
    )


# ============================================================
# PATH GEOMETRY
# ============================================================

def path_length_degrees(
    points,
) -> float:

    if len(points) < 2:
        return 0.0

    array = np.asarray(
        points,
        dtype=float,
    )

    delta = np.diff(
        array,
        axis=0,
    )

    return float(
        np.hypot(
            delta[:, 0],
            delta[:, 1],
        ).sum()
    )


def longitude_span(
    points,
) -> float:

    if not points:
        return 0.0

    longitudes = [
        point[0]
        for point in points
    ]

    return float(
        max(longitudes)
        -
        min(longitudes)
    )


def latitude_span(
    points,
) -> float:

    if not points:
        return 0.0

    latitudes = [
        point[1]
        for point in points
    ]

    return float(
        max(latitudes)
        -
        min(latitudes)
    )


# ============================================================
# GEOGRAPHIC COVERAGE
# ============================================================

def count_crossed_regions(
    points,
) -> int:

    coverage_regions = [
        "arabian_south",
        "arabian_central",
        "west_coast",
        "south_india",
        "central_india",
        "punjab_haryana",
        "upper_gangetic_plain",
        "central_gangetic_plain",
        "bay_south",
        "bay_central",
        "east_india",
        "northeast_india",
    ]

    crossed = 0

    for region_name in coverage_regions:

        region = TARGET_REGIONS[
            region_name
        ]

        if count_points_in_region(
            points,
            region,
        ) > 0:

            crossed += 1

    return crossed


# ============================================================
# SEED GENERATION
# ============================================================

def generate_seed_grid(
    source: str,
):

    if source == "arabian":

        return [
            (
                float(lon),
                float(lat),
            )
            for lon in ARABIAN_SEED_LONGITUDES
            for lat in ARABIAN_SEED_LATITUDES
        ]

    if source == "bay":

        return [
            (
                float(lon),
                float(lat),
            )
            for lon in BAY_SEED_LONGITUDES
            for lat in BAY_SEED_LATITUDES
        ]

    raise ValueError(
        f"Unknown source: {source}"
    )


# ============================================================
# CANDIDATE GENERATION
# ============================================================

def generate_candidates(
    wind_field: WindField,
):

    candidates = []

    sources = [
        "arabian",
        "bay",
    ]

    total_expected = sum(
        len(
            generate_seed_grid(
                source
            )
        )
        for source in sources
    )

    processed = 0

    start_time = (
        time.perf_counter()
    )

    print(
        "\n=== GENERATING DENSE CANDIDATE LIBRARY ==="
    )

    print(
        f"Expected seeds: "
        f"{total_expected}"
    )

    for source in sources:

        seeds = generate_seed_grid(
            source
        )

        for seed_lon, seed_lat in seeds:

            processed += 1

            points = trace_full_streamline(
                wind_field,
                seed_lon,
                seed_lat,
            )

            if len(points) >= 10:

                candidates.append(
                    {
                        "source": source,

                        "seed": (
                            seed_lon,
                            seed_lat,
                        ),

                        "points": points,
                    }
                )

            if (
                processed == 1
                or
                processed % 25 == 0
                or
                processed == total_expected
            ):

                elapsed = (
                    time.perf_counter()
                    -
                    start_time
                )

                print(
                    f"{processed:>3}/"
                    f"{total_expected} "
                    f"seeds processed "
                    f"| candidates="
                    f"{len(candidates)} "
                    f"| {elapsed:.1f}s"
                )

    elapsed = (
        time.perf_counter()
        -
        start_time
    )

    print(
        f"\nGenerated "
        f"{len(candidates)} "
        f"candidate trajectories "
        f"in {elapsed:.2f}s."
    )

    return candidates


# ============================================================
# TARGET SCORING
# ============================================================

def candidate_target_score(
    candidate,
    role,
):

    required_source = role[
        "source"
    ]

    if (
        required_source is not None
        and
        candidate["source"]
        != required_source
    ):
        return -math.inf

    points = candidate[
        "points"
    ]

    target = TARGET_REGIONS[
        role["target"]
    ]

    inside_count = (
        count_points_in_region(
            points,
            target,
        )
    )

    minimum_samples = role.get(
        "minimum_target_samples",
        1,
    )

    if inside_count < minimum_samples:
        return -math.inf

    visible = (
        longest_contiguous_segment(
            points,
            role["clip"],
        )
    )

    if len(visible) < 8:
        return -math.inf

    visible_length = (
        path_length_degrees(
            visible
        )
    )

    lon_span = longitude_span(
        visible
    )

    lat_span = latitude_span(
        visible
    )

    crossed_regions = (
        count_crossed_regions(
            visible
        )
    )

    seed_lat = candidate[
        "seed"
    ][1]

    latitude_penalty = abs(
        seed_lat
        -
        role["preferred_latitude"]
    )

    score = (
        inside_count
        *
        4.0

        +

        min(
            visible_length,
            40.0,
        )
        *
        1.8

        +

        min(
            lon_span,
            35.0,
        )
        *
        2.2

        +

        min(
            lat_span,
            15.0,
        )
        *
        0.8

        +

        crossed_regions
        *
        10.0

        -

        latitude_penalty
        *
        0.8
    )

    return float(
        score
    )


# ============================================================
# PATH SIMILARITY
# ============================================================

def sample_path(
    points,
    sample_count=25,
):

    if len(points) <= sample_count:

        return np.asarray(
            points,
            dtype=float,
        )

    indices = np.linspace(
        0,
        len(points) - 1,
        sample_count,
    )

    indices = np.unique(
        np.round(
            indices
        ).astype(int)
    )

    return np.asarray(
        [
            points[index]
            for index in indices
        ],
        dtype=float,
    )


def directed_path_distance(
    path_a,
    path_b,
) -> float:

    a = sample_path(
        path_a
    )

    b = sample_path(
        path_b
    )

    distances = []

    for point in a:

        delta = (
            b
            -
            point
        )

        nearest = np.min(
            np.hypot(
                delta[:, 0],
                delta[:, 1],
            )
        )

        distances.append(
            nearest
        )

    return float(
        np.mean(
            distances
        )
    )


def path_similarity_distance(
    path_a,
    path_b,
) -> float:

    return (
        directed_path_distance(
            path_a,
            path_b,
        )

        +

        directed_path_distance(
            path_b,
            path_a,
        )
    ) / 2.0


# ============================================================
# VISUAL OVERLAP PENALTY
# ============================================================

def trajectory_overlap_penalty(
    candidate_path,
    selected_paths,
    candidate_group,
) -> float:

    penalty = 0.0

    for selected in selected_paths:

        distance = (
            path_similarity_distance(
                candidate_path,
                selected["points"],
            )
        )

        same_group = (
            candidate_group
            ==
            selected["group"]
        )

        if distance < 0.65:
            penalty += 400.0

        elif distance < 1.25:
            penalty += 180.0

        elif distance < 2.0:
            penalty += 70.0

        elif distance < 3.0:
            penalty += 20.0

        if same_group:

            if distance < 1.5:
                penalty += 180.0

            elif distance < 2.5:
                penalty += 70.0

            elif distance < 3.5:
                penalty += 20.0

    return penalty


# ============================================================
# FINAL SELECTION
# ============================================================

def select_final_paths(
    candidates,
):

    selected = []

    print(
        "\n=== FINAL VISUAL PATH SELECTION ==="
    )

    for role in FINAL_ROLES:

        ranked = []

        for candidate in candidates:

            base_score = (
                candidate_target_score(
                    candidate,
                    role,
                )
            )

            if not np.isfinite(
                base_score
            ):
                continue

            visible_path = (
                longest_contiguous_segment(
                    candidate["points"],
                    role["clip"],
                )
            )

            if len(visible_path) < 8:
                continue

            diversity_penalty = (
                trajectory_overlap_penalty(
                    visible_path,
                    selected,
                    role["group"],
                )
            )

            final_score = (
                base_score
                -
                diversity_penalty
            )

            ranked.append(
                {
                    "score": final_score,

                    "base_score": (
                        base_score
                    ),

                    "diversity_penalty": (
                        diversity_penalty
                    ),

                    "candidate": (
                        candidate
                    ),

                    "visible_path": (
                        visible_path
                    ),
                }
            )

        if not ranked:

            print(
                f"{role['id']}: "
                f"NO SUITABLE PATH"
            )

            continue

        ranked.sort(
            key=lambda item: item["score"],
            reverse=True,
        )

        best = ranked[0]

        candidate = best[
            "candidate"
        ]

        visible_path = best[
            "visible_path"
        ]

        target_count = (
            count_points_in_region(
                candidate["points"],
                TARGET_REGIONS[
                    role["target"]
                ],
            )
        )

        lon_span = (
            longitude_span(
                visible_path
            )
        )

        crossed_regions = (
            count_crossed_regions(
                visible_path
            )
        )

        selected_path = {

            "id": role["id"],

            "group": (
                role["group"]
            ),

            "source": (
                candidate["source"]
            ),

            "target": (
                role["target"]
            ),

            "seed": (
                candidate["seed"]
            ),

            "score": float(
                best["score"]
            ),

            "base_score": float(
                best["base_score"]
            ),

            "diversity_penalty": float(
                best["diversity_penalty"]
            ),

            "target_samples": (
                target_count
            ),

            "longitude_span": (
                lon_span
            ),

            "crossed_regions": (
                crossed_regions
            ),

            "points": (
                visible_path
            ),
        }

        selected.append(
            selected_path
        )

        start = visible_path[0]
        end = visible_path[-1]

        print(
            f"\n{role['id']}"
        )

        print(
            f"  source: "
            f"{candidate['source']}"
        )

        print(
            f"  seed: "
            f"{candidate['seed']}"
        )

        print(
            f"  start: "
            f"({start[0]:.2f}, "
            f"{start[1]:.2f})"
        )

        print(
            f"  end: "
            f"({end[0]:.2f}, "
            f"{end[1]:.2f})"
        )

        print(
            f"  target samples: "
            f"{target_count}"
        )

        print(
            f"  longitude span: "
            f"{lon_span:.1f}°"
        )

        print(
            f"  regions crossed: "
            f"{crossed_regions}"
        )

        print(
            f"  base score: "
            f"{best['base_score']:.1f}"
        )

        print(
            f"  diversity penalty: "
            f"{best['diversity_penalty']:.1f}"
        )

        print(
            f"  final score: "
            f"{best['score']:.1f}"
        )

    print(
        f"\nSelected "
        f"{len(selected)} "
        f"final visual ribbons."
    )

    return selected


# ============================================================
# SIMPLIFICATION
# ============================================================

def simplify_path(
    points,
    target_points=SIMPLIFIED_POINTS,
):

    if len(points) <= target_points:
        return list(
            points
        )

    indices = np.linspace(
        0,
        len(points) - 1,
        target_points,
    )

    indices = np.unique(
        np.round(
            indices
        ).astype(int)
    )

    simplified = [
        points[index]
        for index in indices
    ]

    simplified[0] = points[0]
    simplified[-1] = points[-1]

    return simplified


# ============================================================
# WIND DATA ALONG FINAL PATH
# ============================================================

def enrich_path_with_wind(
    wind_field: WindField,
    points,
):

    enriched = []

    for lon, lat in points:

        wind = (
            wind_field.wind_data(
                lon,
                lat,
            )
        )

        if wind is None:
            continue

        enriched.append(
            {
                "lon": round(
                    float(lon),
                    5,
                ),

                "lat": round(
                    float(lat),
                    5,
                ),

                "u": round(
                    wind["u"],
                    3,
                ),

                "v": round(
                    wind["v"],
                    3,
                ),

                "speed": round(
                    wind["speed"],
                    3,
                ),
            }
        )

    return enriched


# ============================================================
# JSON EXPORT
# ============================================================

def export_paths_json(
    paths,
    wind_field: WindField,
):

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    document = {

        "metadata": {

            "source": "ERA5",

            "year": 2025,

            "period": "JJAS",

            "pressure_level_hpa": 850,

            "seasonal_mean": (
                "day-weighted monthly mean"
            ),

            "variables": [
                "u_component_of_wind",
                "v_component_of_wind",
            ],

            "trajectory_integration": (
                "RK4"
            ),

            "integration_direction": (
                "bidirectional"
            ),

            "streamline_step_degrees": (
                STREAMLINE_STEP
            ),

            "interpolation": (
                "RegularGridInterpolator "
                "linear interpolation"
            ),

            "candidate_selection": (
                "448 dense seed trajectories, "
                "geographic coverage scoring, "
                "visual diversity penalty"
            ),

            "visual_ribbon_target":6,
        },

        "paths": [],
    }

    for path in paths:

        simplified = simplify_path(
            path["points"]
        )

        enriched = (
            enrich_path_with_wind(
                wind_field,
                simplified,
            )
        )

        if enriched:

            speeds = [
                point["speed"]
                for point in enriched
            ]

            mean_speed = float(
                np.mean(
                    speeds
                )
            )

            max_speed = float(
                np.max(
                    speeds
                )
            )

            min_speed = float(
                np.min(
                    speeds
                )
            )

        else:

            mean_speed = 0.0
            max_speed = 0.0
            min_speed = 0.0

        document[
            "paths"
        ].append(
            {
                "id": (
                    path["id"]
                ),

                "group": (
                    path["group"]
                ),

                "candidate_source": (
                    path["source"]
                ),

                "target_region": (
                    path["target"]
                ),

                "seed": {

                    "lon": round(
                        float(
                            path["seed"][0]
                        ),
                        3,
                    ),

                    "lat": round(
                        float(
                            path["seed"][1]
                        ),
                        3,
                    ),
                },

                "selection_score": round(
                    path["score"],
                    3,
                ),

                "base_score": round(
                    path["base_score"],
                    3,
                ),

                "diversity_penalty": round(
                    path["diversity_penalty"],
                    3,
                ),

                "target_samples": (
                    path["target_samples"]
                ),

                "longitude_span": round(
                    path["longitude_span"],
                    3,
                ),

                "crossed_regions": (
                    path["crossed_regions"]
                ),

                "wind_summary": {

                    "mean_speed": round(
                        mean_speed,
                        3,
                    ),

                    "min_speed": round(
                        min_speed,
                        3,
                    ),

                    "max_speed": round(
                        max_speed,
                        3,
                    ),

                    "units": "m/s",
                },

                "points": (
                    enriched
                ),
            }
        )

    with open(
        JSON_FILE,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            document,
            file,
            indent=2,
        )

    print(
        f"\nJSON exported to:\n"
        f"{JSON_FILE}"
    )


# ============================================================
# DIAGNOSTIC PLOT
# ============================================================

def plot_selected_paths(
    ds: xr.Dataset,
    u_mean: xr.DataArray,
    v_mean: xr.DataArray,
    speed_mean: xr.DataArray,
    candidates,
    selected,
):

    longitude = np.asarray(
        ds["longitude"].values,
        dtype=float,
    )

    latitude = np.asarray(
        ds["latitude"].values,
        dtype=float,
    )

    u_values = np.asarray(
        u_mean.values,
        dtype=float,
    )

    v_values = np.asarray(
        v_mean.values,
        dtype=float,
    )

    speed_values = np.asarray(
        speed_mean.values,
        dtype=float,
    )

    if latitude[0] > latitude[-1]:

        latitude = latitude[::-1]

        u_values = (
            u_values[::-1, :]
        )

        v_values = (
            v_values[::-1, :]
        )

        speed_values = (
            speed_values[::-1, :]
        )

    projection = (
        ccrs.PlateCarree()
    )

    fig, ax = plt.subplots(
        figsize=(17, 12),

        subplot_kw={
            "projection": projection
        },
    )

    ax.set_extent(
        [
            WEST,
            EAST,
            SOUTH,
            NORTH,
        ],
        crs=projection,
    )

    contour = ax.contourf(
        longitude,
        latitude,
        speed_values,
        levels=20,
        alpha=0.32,
        transform=projection,
        zorder=1,
    )

    fig.colorbar(
        contour,
        ax=ax,
        label="850 hPa wind speed (m/s)",
        shrink=0.82,
        pad=0.03,
    )

    ax.streamplot(
        longitude,
        latitude,
        u_values,
        v_values,
        density=1.35,
        linewidth=0.6,
        arrowsize=0.75,
        transform=projection,
        zorder=2,
    )

    for candidate in candidates:

        points = np.asarray(
            candidate["points"],
            dtype=float,
        )

        ax.plot(
            points[:, 0],
            points[:, 1],
            linewidth=0.4,
            alpha=0.025,
            transform=projection,
            zorder=3,
        )

    for _, region in (
        TARGET_REGIONS.items()
    ):

        width = (
            region["east"]
            -
            region["west"]
        )

        height = (
            region["north"]
            -
            region["south"]
        )

        rectangle = plt.Rectangle(
            (
                region["west"],
                region["south"],
            ),

            width,
            height,

            fill=False,

            linewidth=0.55,

            alpha=0.12,

            transform=projection,

            zorder=4,
        )

        ax.add_patch(
            rectangle
        )

    ax.add_feature(
        cfeature.COASTLINE,
        linewidth=1.1,
        zorder=7,
    )

    ax.add_feature(
        cfeature.BORDERS,
        linewidth=0.75,
        zorder=7,
    )

    for path in selected:

        points = np.asarray(
            path["points"],
            dtype=float,
        )

        ax.plot(
            points[:, 0],
            points[:, 1],
            linewidth=4.2,
            transform=projection,
            zorder=10,
        )

        ax.scatter(
            [
                points[0, 0]
            ],
            [
                points[0, 1]
            ],
            s=45,
            transform=projection,
            zorder=11,
        )

        ax.scatter(
            [
                points[-1, 0]
            ],
            [
                points[-1, 1]
            ],
            marker=">",
            s=100,
            transform=projection,
            zorder=11,
        )

        midpoint = points[
            len(points) // 2
        ]

        ax.text(
            midpoint[0],
            midpoint[1] + 0.45,
            path["id"],
            fontsize=8,
            transform=projection,
            zorder=12,
        )

    gridlines = ax.gridlines(
        crs=projection,
        draw_labels=True,
        linewidth=0.5,
        alpha=0.35,
        linestyle="--",
    )

    gridlines.top_labels = False
    gridlines.right_labels = False

    ax.set_title(
        "ERA5-Derived Representative "
        "Indian Summer Monsoon Flow — "
        "Day-Weighted JJAS 2025",
        fontsize=16,
        pad=15,
    )

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    fig.savefig(
        PLOT_FILE,
        dpi=180,
        bbox_inches="tight",
    )

    print(
        f"\nSelected-path plot saved to:\n"
        f"{PLOT_FILE}"
    )

    plt.show()

    plt.close(
        fig
    )


# ============================================================
# MAIN
# ============================================================

def main() -> None:

    if not DATA_FILE.exists():

        raise FileNotFoundError(
            f"ERA5 file not found: "
            f"{DATA_FILE}"
        )

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    total_start = (
        time.perf_counter()
    )

    print(
        f"\nReading ERA5 data from:\n"
        f"{DATA_FILE}"
    )

    with xr.open_dataset(
        DATA_FILE
    ) as ds:

        # 1. Validate ERA5 source.
        inspect_dataset(
            ds
        )

        # 2. Calculate day-weighted JJAS mean.
        (
            u_mean,
            v_mean,
            speed_mean,
        ) = calculate_jjas_mean(
            ds
        )

        # 3. Build interpolation field.
        print(
            "\nBuilding fast wind interpolators..."
        )

        wind_field = WindField(
            u_mean,
            v_mean,
        )

        print(
            "Wind interpolators ready."
        )

        # 4. Generate dense candidate library.
        candidates = (
            generate_candidates(
                wind_field
            )
        )

        if not candidates:

            raise RuntimeError(
                "No candidate trajectories "
                "were generated."
            )

        # 5. Select five representative ribbons.
        selected = (
            select_final_paths(
                candidates
            )
        )

        if not selected:

            raise RuntimeError(
                "No representative trajectories "
                "could be selected."
            )

        # 6. Create diagnostic plot.
        plot_selected_paths(
            ds,
            u_mean,
            v_mean,
            speed_mean,
            candidates,
            selected,
        )

        # 7. Export final paths.
        export_paths_json(
            selected,
            wind_field,
        )

    elapsed = (
        time.perf_counter()
        -
        total_start
    )

    print(
        "\n=== COMPLETE ==="
    )

    print(
        f"Candidates: "
        f"{len(candidates)}"
    )

    print(
        f"Selected paths: "
        f"{len(selected)}"
    )

    print(
        f"Total runtime: "
        f"{elapsed:.2f}s"
    )

    print(
        f"\nPNG:\n"
        f"{PLOT_FILE}"
    )

    print(
        f"\nJSON:\n"
        f"{JSON_FILE}"
    )


if __name__ == "__main__":
    main()