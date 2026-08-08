from pathlib import Path

import cdsapi

DATASET = "reanalysis-era5-pressure-levels-monthly-means"

PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = PROJECT_ROOT / "data" / "era5"
OUTPUT_FILE = OUTPUT_DIR / "monsoon_850hpa_2025.nc"

def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    client = cdsapi.Client()

    request = {
        "product_type": ["monthly_averaged_reanalysis"],
        "variable": [
            "u_component_of_wind",
            "v_component_of_wind",
        ],
        "pressure_level": ["850"],
        "year": ["2025"],
        "month": [
            "06",
            "07",
            "08",
            "09",
        ],
        "time": ["00:00"],

        "area": [
            35,
            50,
            -10,
            100,
        ],
        "data_format": "netcdf",
        "download_format": "unarchived",
    }

    print("Requesting ERA5 850-hPa monsoon winds...")
    print(f"Output: {OUTPUT_FILE}")

    client.retrieve(
        DATASET,
        request,
        str(OUTPUT_FILE),
    )

    print("Download complete.")

if __name__ == "__main__":
    main()