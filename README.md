# Earth Systems Explorer: Immersive Visualization of Global Climate Processes for Liquid Galaxy

[![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter)](https://flutter.dev)

**Earth Systems Explorer** is a high-performance Flutter-based control interface for the Liquid Galaxy multi-display system. It allows users to explore complex global climate systems through immersive 3D geospatial tours, dynamic KML visualization layers, and real-time AI-powered narration.

## 🌍 Core Experience

Designed as a planetary command center, the application enables:
- **Trigger Guided Tours:** Select climate phenomena to initiate synchronized geospatial voyages across the Liquid Galaxy rig nodes.
- **Visualize Climate Layers:** Deploy dynamic KML layers representing ocean currents, wind patterns, and thermal anomalies.
- **AI-Powered Narration:** Experience interactive storytelling via the **Gemini API**, explaining the science behind global weather impacts in real-time.
- **Orbit & Navigation:** Execute automated 360-degree orbital camera movements and synchronize the rig's view with an integrated Google Map viewport.
- **Precision Rig Control:** Full management of the rig state, including camera "Fly-to" instructions, Logo overlays, and system maintenance (Reboot/Shutdown).

## ✨ UI & UX Highlights

- **Localized Glow Aesthetic:** An ultra-modern, high-contrast pure black interface (`#020617`) where interactive elements feature vibrant, localized glow effects. This maximizes focus on data and controls while providing a sleek, distraction-free experience.
- **Synced Navigation:** An integrated viewport that synchronizes mobile map interactions in real-time with the Liquid Galaxy rig's perspective.
- **Temporal Analysis:** Integrated timeline controls allowing users to visualize and simulate climate data changes across different years (2000–2026).
- **Glassmorphism Design:** Reusable UI components utilizing advanced transparency and background blur for a futuristic, premium feel.
- **Adaptive Layout:** Fully responsive design optimized for both phone and tablet form factors in portrait and landscape.

## 📊 Primary Climate Visualizations

- **Ocean Dynamics:** In-depth visualization of the Gulf Stream, Kuroshio Current, and global thermohaline circulation.
- **Atmospheric Circulation:** High-res representation of Trade Winds, Westerlies, and Jet Streams using vector-optimized paths.
- **ENSO States:** Interactive comparisons of Normal, El Niño, and La Niña conditions across the Pacific.
- **Regional Impacts:** Detailed analysis of the Indian Monsoon and specific city-level weather phenomena like Mumbai rainfall.

## 🛠️ Technical Stack

- **Frontend:** [Flutter](https://flutter.dev) (Dart)
- **Communication:** SSH via [dartssh2](https://pub.dev/packages/dartssh2) for secure cluster management.
- **Visualization:** KML (Keyhole Markup Language) rendered on Google Earth.
- **Intelligence:** 
  - **Gemini API:** Dynamic story generation and scientific data interpretation.
  - **Deepgram:** Voice-to-command processing and narrated text-to-speech.
- **Data Sources:** NOAA, NASA Earth Observations (NEO), and atmospheric models.

## 📂 Project Structure

- `lib/`: Main source code.
  - `lib/connections/`: SSH services and KML generation logic.
  - `lib/screens/`: High-level views (Explore, Data, Control, Settings).
  - `lib/components/`: Reusable Glassmorphic UI widgets.
- `kmls/`: Static and template geospatial assets.
- `assets/`: Images and static resources.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.1.5)
- Access to a Liquid Galaxy rig (or compatible environment with SSH).

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/shrinivas-v/AI-Assisted-Climate-Weather-Exploration-for-Liquid-Galaxy.git
   ```
2. Navigate to the project directory:
   ```bash
   cd AI-Assisted-Climate-Weather-Exploration-for-Liquid-Galaxy
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```


