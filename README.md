# Earth Systems Explorer: Immersive Visualization of Global Climate Processes for Liquid Galaxy

[![GSoC 2026](https://img.shields.io/badge/GSoC-2026-blue.svg)](https://summerofcode.withgoogle.com/)
[![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter)](https://flutter.dev)

**Earth Systems Explorer** is a Flutter-based mobile control interface for Liquid Galaxy designed to visualize and explore complex global climate systems. By combining high-resolution geospatial data with immersive multi-screen visualization, it provides a powerful platform for understanding planetary-scale atmospheric and oceanic processes.

## 🌍 Core Experience

The application serves as a command center for a Liquid Galaxy rig, allowing users to:
- **Trigger Guided Tours:** Select climate phenomena to initiate synchronized geospatial tours.
- **Visualize Climate Layers:** Deploy dynamic KML layers representing ocean currents, wind patterns, and thermal anomalies.
- **AI Narration:** Experience interactive storytelling powered by the Gemini API, explaining the science behind the visuals.
- **Precision Control:** Navigate with "Fly-to" instructions and manage the Liquid Galaxy rig (Logo display, KML clearing, Reboot/Shutdown).

## 📊 Key Climate Visualizations

- **Ocean Dynamics:** Visualization of the Gulf Stream, Kuroshio Current, and global thermohaline circulation.
- **Atmospheric Circulation:** Real-time representation of Trade Winds, Westerlies, and Jet Streams.
- **ENSO States:** Comparison of Normal, El Niño, and La Niña conditions in the Pacific.
- **Regional Impacts:** Detailed analysis of the Indian Monsoon and specific city-level weather impacts (e.g., flooding in Mumbai).

## 🛠️ Technical Stack

- **Frontend:** [Flutter](https://flutter.dev) (Dart)
- **Communication:** SSH via [dartssh2](https://pub.dev/packages/dartssh2) for Liquid Galaxy integration.
- **Visualization:** KML (Keyhole Markup Language) rendered on Google Earth.
- **AI Integration:** 
  - **Gemini API:** For dynamic story generation and climate explanations.
  - **Deepgram:** For voice commands and text-to-speech narration.
- **Data Sources:** NOAA, NASA Earth Observations (NEO), and atmospheric circulation models.

## 📂 Project Structure

- `lg_connection_final/`: The main Flutter project directory.
  - `lib/connections/`: SSH logic and KML generation services.
  - `lib/screens/`: UI components for Explore, Data, Control, and Settings.
  - `lib/components/`: Reusable Glassmorphism-style UI elements.
  - `kmls/`: Static and template KML assets.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.1.5)
- A Liquid Galaxy rig setup (or a compatible environment with Google Earth and SSH access).
- SSH credentials for the master rig.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/shrinivas-v/AI-Assisted-Climate-Weather-Exploration-for-Liquid-Galaxy.git
   ```
2. Navigate to the project directory:
   ```bash
   cd lg_connection_final
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## 📝 Credits & Acknowledgments

This project was developed as part of the **Google Summer of Code 2026** program for the **Liquid Galaxy project**.

- **Organization:** [Liquid Galaxy Project](https://www.liquidgalaxy.eu/)
- **Data Providers:** NOAA & NASA
- **Icons:** Cupertino and Google Fonts (Outfit)

---
*Precision planetary monitoring and immersive data visualization.*
