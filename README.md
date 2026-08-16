# Earth Systems Explorer 🌍

> **AI-Assisted Climate & Weather Exploration Engine for Liquid Galaxy**

[![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.1+-0175C2?logo=dart)](https://dart.dev)
[![Python](https://img.shields.io/badge/Python-v3.10+-3776AB?logo=python)](https://python.org)
[![Data Source](https://img.shields.io/badge/Data-ECMWF%20ERA5-003366)](https://cds.climate.copernicus.eu/)
[![AI Engine](https://img.shields.io/badge/AI-Gemini%201.5%20Flash-orange?logo=google)](https://deepmind.google/technologies/gemini/)

**Earth Systems Explorer** is a control and visualization engine engineered for the **Liquid Galaxy** multi-display cluster. The system combines scientific ECMWF ERA5 reanalysis data processing, procedural KML 3D vector ribbon generation, automated geospatial camera tours, bidirectional map synchronization, and Gemini AI-driven telemetry cards.

---

## 🌟 Key Features

- 🌍 **Liquid Galaxy Multi-Display Cluster Control**: Encrypted SSH/SFTP connection for remote display management, logo overlays, dynamic slave re-rendering, and master camera control.
- 🌧️ **Scientific ERA5 Climate Data Pipeline**: Ingests ECMWF ERA5 reanalysis data (850 hPa wind vector fields) and performs streamline numerical integration for major climate phenomena (Indian Monsoon, El Niño, La Niña, Gulf Stream, Kuroshio).
- 🏹 **Procedural 3D KML Ribbon Synthesis**: Generates smooth 3D vector ribbon arrows with color gradients, normal vector boundary construction, and joined polygon arrowheads.
- 🔄 **Bidirectional Map Synchronization**: Keeps mobile 2D map viewports and Liquid Galaxy 3D viewports seamlessly synchronized in real time with exponential scale conversion and gesture debouncing.
- 🤖 **AI Climate Insights & Voice Narration**: Uses Gemini 1.5 Flash to generate structured climate telemetry cards paired with synchronized text-to-speech (TTS) audio narration during tours.

---

## 🏗️ System Architecture

```
   ┌──────────────────────────────────────────────────────────┐
   │                  Scientific Climate Pipeline             │
   │  [ ECMWF CDS API ] ──> NetCDF4 Data ──> Streamline Calc  │
   └─────────────────────────────┬────────────────────────────┘
                                 │ JSON Trajectories
                                 ▼
   ┌──────────────────────────────────────────────────────────┐
   │               Arrow-Generator Procedural Engine          │
   │  Compute Normal Offsets ──> Color Gradients ──> 3D KML   │
   └─────────────────────────────┬────────────────────────────┘
                                 │ KML Ribbons & Tour Playlists
                                 ▼
┌───────────────────────┐   SSH / SFTP   ┌──────────────────────────────┐
│  Flutter Mobile App   │ ─────────────> │ Liquid Galaxy Multi-Display  │
│  - Remote Rig Control │  (Port 22)     │ - Master Node (lg1): Earth   │
│  - Bidirectional Sync │                │ - Slave Nodes (lgX): Overlays│
│  - Gemini AI & TTS    │                └──────────────────────────────┘
└───────────────────────┘
```

---

## 📁 Repository Structure

- 📱 **`lib/`**: Flutter mobile application source code (SSH client, map sync service, AI integration, TTS narration, settings, and UI components).
- 🐍 **`tools/monsoon/`**: Python scripts for downloading ERA5 NetCDF climate datasets and performing streamline trajectory integration.
- 🏹 **`Arrow-Generator-main/`**: Procedural synthesizer for converting wind trajectory JSONs into 3D KML ribbon arrow layers and `<gx:Tour>` playlists.
- 🎨 **`assets/`**: Application icons, branding, sample KMLs, and UI assets.

---

## 🚀 Quick Start Guide

### 1. Flutter Mobile Controller App

#### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.24 or higher)
- [Dart SDK](https://dart.dev/get-started) (v3.1 or higher)
- Android Studio / Xcode for emulators or physical testing devices

#### Installation & Run
```bash
# 1. Clone the repository
git clone https://github.com/SamatmaAB/AI-Assisted-Climate-Weather-Exploration-for-Liquid-Galaxy.git
cd AI-Assisted-Climate-Weather-Exploration-for-Liquid-Galaxy

# 2. Install Flutter dependencies
flutter pub get

# 3. Launch the mobile application
flutter run
```

---

### 2. Climate Data Pipeline & KML Generator

#### Prerequisites
- Python 3.10+
- An account on the [Copernicus Climate Data Store (CDS)](https://cds.climate.copernicus.eu/) for ERA5 access.

#### Setup & Execution

```bash
# 1. Install required Python packages
pip install cdsapi xarray scipy numpy cartopy

# 2. Download ERA5 850 hPa Monsoon Reanalysis Data
python tools/monsoon/download_era5.py

# 3. Run Streamline Numerical Integration
python tools/monsoon/process_monsoon.py

# 4. Synthesize 3D Vector Ribbons & Camera Tours
cd Arrow-Generator-main
python indianmonsoon.py
python tour_generator.py
```

---

## ⚙️ Technical Stack Summary

| Layer | Technologies & Dependencies | Main Responsibility |
| :--- | :--- | :--- |
| **Mobile App (Controller)** | Flutter, Dart (`dartssh2`, `google_maps_flutter`) | Rig connection, SSH cluster protocol, live map sync, UI cards. |
| **AI & Narration** | `google_generative_ai`, `flutter_tts` | Gemini 1.5 Flash telemetry cards & synchronized audio narration. |
| **Data Ingestion** | Python 3.10 (`cdsapi`, `xarray`, `scipy`) | Downloads raw NetCDF4 climate data, calculates 2D velocity fields & streamlines. |
| **KML Synthesis Engine** | Python (`Arrow-Generator-main`) | Computes perpendicular vector offsets, polygon arrowheads, and KML `<gx:Tour>` playlists. |
| **Cluster Hardware** | Liquid Galaxy Rig (Ubuntu Linux) | Google Earth 3D master display and slave overlay screens. |

---

## 🤝 Contributing & License

Contributions, feedback, and issue reports are welcome! Please feel free to open an issue or submit a pull request.
