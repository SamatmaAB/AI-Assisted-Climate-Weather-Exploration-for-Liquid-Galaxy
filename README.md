# Earth Systems Explorer 🌍

> **AI-Assisted Climate & Weather Exploration Engine for Liquid Galaxy**

[![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.1+-0175C2?logo=dart)](https://dart.dev)
[![Python](https://img.shields.io/badge/Python-v3.10+-3776AB?logo=python)](https://python.org)
[![Data Source](https://img.shields.io/badge/Data-ECMWF%20ERA5-003366)](https://cds.climate.copernicus.eu/)
[![AI Engine](https://img.shields.io/badge/AI-Gemini%20AI-orange?logo=google)](https://deepmind.google/technologies/gemini/)

**Earth Systems Explorer** is a high-performance control and visualization engine engineered for the **Liquid Galaxy** multi-display cluster. It combines scientific ECMWF ERA5 climate reanalysis processing, procedural 3D KML vector ribbon generation, automated geospatial camera itineraries, bidirectional map synchronicity, and Gemini AI-driven telemetry cards.

---

## 🌟 Key Features

- 🌍 **Liquid Galaxy Cluster Control**: Encrypted SSH/SFTP multi-display management, logo overlays, dynamic slave re-rendering, and master camera control.
- 🌧️ **Scientific Climate Pipeline**: Ingests ECMWF ERA5 reanalysis data (850 hPa wind fields) and performs streamline numerical integration for major climate systems (Indian Monsoon, El Niño, La Niña, Gulf Stream, Kuroshio).
- 🏹 **Procedural 3D KML Ribbon Synthesizer**: Converts flow trajectories into smooth 3D vector ribbon arrows with color gradients, boundary normal offsets, and polygon arrowheads.
- 🔄 **Bidirectional Map Synchronization**: Real-time sync between mobile 2D map viewports and Liquid Galaxy 3D viewports with scale conversion and gesture debouncing.
- 🤖 **AI Intelligence & Voice Narration**: Gemini AI structured telemetry cards paired with synchronized text-to-speech (TTS) audio narration during guided tours.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      1. Scientific Climate Pipeline                     │
│  [ ECMWF CDS API ] ──> ERA5 NetCDF4 Data ──> Streamline Integration     │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ JSON Trajectories
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                   2. Arrow-Generator Procedural Engine                  │
│  Trajectory Nodes ──> Normal Offsets ──> Color Gradients ──> 3D KML     │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ KML Ribbons & Tour Playlists
                                     ▼
┌─────────────────────────┐   SSH / SFTP   ┌──────────────────────────────┐
│ 3. Flutter Mobile App   │ ─────────────> │ 4. Liquid Galaxy Multi-Rig   │
│ - Remote Rig Controls   │  (Port 22)     │ - Master Node (lg1): Earth   │
│ - Live Map Sync Service │                │ - Slave Nodes (lgX): Overlays│
│ - Gemini AI & TTS Queue │                └──────────────────────────────┘
└─────────────────────────┘
```

---

## 🔍 In-Depth: Arrow-Generator Engine (`Arrow-Generator-main/`)

Located in `Arrow-Generator-main/`, this procedural engine transforms raw coordinate trajectories into high-definition, 3D KML vector ribbon layers and automated camera tours for Google Earth and Liquid Galaxy.

```
  [ Raw Trajectory Points ]
             │
             ▼
   compute_boundary_vertices() ──> Segment normals & averaged vertex normals
             │
             ▼
   interpolate_color(t)        ──> Color gradient (Deep Ocean Blue -> Bright Cyan)
             │
             ▼
   create_quad_polygon()       ──> 3D KML <Polygon> Quad Ribbon Sections
             │
             ▼
   create_arrowhead()          ──> Solid Joined Polygon Arrowhead at Path Tip
             │
             ▼
   tour_generator.py           ──> Automated <gx:Tour> Camera Viewport Playlists
```

### Core Pipeline Components

1. **Curve Trajectory Generation**
   - **Bezier Flow Curves**: Generates smooth parametric curves $B(t) = (1-t)^2 P_0 + 2(1-t)t P_1 + t^2 P_2$ for idealized current models.
   - **ERA5 Streamline Nodes**: Reads 45-point resampled coordinate trajectories $(\lambda_i, \phi_i, u_i, v_i, \text{speed}_i)$ computed from raw atmospheric reanalysis.

2. **Normal Vector Boundary Construction (`compute_boundary_vertices`)**
   - Calculates direction vectors $(\Delta x, \Delta y)$ and unit normal vectors $\mathbf{n} = (- \Delta y / L, \Delta x / L)$ for each segment.
   - Averages adjacent segment normals at each vertex ($\mathbf{n}_{\text{prev}} + \mathbf{n}_{\text{next}}$) to guarantee smooth ribbon boundaries without sharp miter tearing.
   - Offsets left and right boundary coordinates by ribbon width $w = 0.35^\circ$ to form quad polygons.

3. **Color Gradient Interpolation (`interpolate_color`)**
   - Calculates color transitions along normalized path parameter $t \in [0.0, 1.0]$ from ocean origin to landfall.
   - Converts RGB transitions (e.g., Deep Ocean Blue to Bright Cyan) into KML alpha-blue-green-red hex strings (`aabbggrr`).

4. **Polygon Arrowhead Construction (`create_arrowhead`)**
   - Determines vector orientation angle $\theta = \text{atan2}(\Delta y, \Delta x)$ at path termination.
   - Computes left and right arrowhead wing coordinates at sweep angle $\pm 30^\circ$.
   - Binds the arrowhead base directly to the ribbon shaft vertices to eliminate visual gaps or z-fighting.

5. **Automated Tour Playlist Generator (`tour_generator.py`)**
   - Programmatically builds Google Earth `<gx:Tour>` XML playlists (`indianmonsoon_tour.kml`, `el_nino_tour.kml`, `la_nina_tour.kml`, etc.).
   - Sets multi-stop camera itineraries with tuned `latitude`, `longitude`, `range`, `tilt`, `heading`, `duration`, and smooth `flyToMode` transitions.

---

## 📁 Repository Structure

- 📱 **`lib/`**: Flutter mobile app source code (SSH client, map sync, AI service, TTS narration, and UI views).
- 🐍 **`tools/monsoon/`**: Python scripts for downloading ERA5 NetCDF climate datasets (`download_era5.py`) and calculating streamlines (`process_monsoon.py`).
- 🏹 **`Arrow-Generator-main/`**: Procedural KML vector ribbon engine and tour generator scripts.
- 🎨 **`assets/`**: App branding, icons, sample KMLs, and UI assets.

---

## 🚀 Quick Start Guide

### 1. Flutter Mobile Controller App

#### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.24 or higher)
- [Dart SDK](https://dart.dev/get-started) (v3.1 or higher)

#### Run Command
```bash
# Clone repository & install dependencies
git clone https://github.com/SamatmaAB/AI-Assisted-Climate-Weather-Exploration-for-Liquid-Galaxy.git
cd AI-Assisted-Climate-Weather-Exploration-for-Liquid-Galaxy
flutter pub get

# Launch app
flutter run
```

---

### 2. Climate Pipeline & KML Synthesizer

#### Prerequisites
- Python 3.10+
- [Copernicus Climate Data Store (CDS)](https://cds.climate.copernicus.eu/) account for raw ERA5 data access.

#### Execution Steps
```bash
# 1. Install required packages
pip install cdsapi xarray scipy numpy cartopy

# 2. Download ERA5 850 hPa Monsoon NetCDF4 Data
python tools/monsoon/download_era5.py

# 3. Perform Streamline Numerical Integration
python tools/monsoon/process_monsoon.py

# 4. Generate 3D Vector Ribbons & Camera Tours
cd Arrow-Generator-main
python indianmonsoon.py
python tour_generator.py
```

---

## ⚙️ Technical Stack Summary

| Module | Core Dependencies | Primary Function |
| :--- | :--- | :--- |
| **Mobile Controller** | Flutter, Dart (`dartssh2`, `google_maps_flutter`) | Multi-display cluster SSH control, live map sync, UI navigation. |
| **AI Intelligence & TTS** | `google_generative_ai`, `flutter_tts` | Gemini AI telemetry generation & synchronized audio tours. |
| **ERA5 Data Pipeline** | Python (`cdsapi`, `xarray`, `scipy`, `numpy`) | NetCDF4 downloading, 850 hPa wind vector interpolation, streamline integration. |
| **Arrow Generator Engine** | Python (`Arrow-Generator-main`) | Ribbon boundary geometry, color gradients, arrowhead polygons, `<gx:Tour>` playlists. |
| **Cluster Infrastructure** | Liquid Galaxy Rig (Ubuntu Linux) | Google Earth 3D master display node & slave overlay screens. |

---

## 🤝 Contributing & License

Contributions and pull requests are welcome! Feel free to open an issue for questions or feature requests.
