# Earth Systems Explorer Context

This app is being built from the GSOC 2026 proposal "Earth Systems Explorer: Immersive Visualization of Global Climate Processes using Liquid Galaxy."

## Product Goal

Build a Flutter mobile control interface for Liquid Galaxy that lets users explore global climate systems through guided geospatial tours, KML visualization layers, Google Maps style location synchronization, and narration.

## Core Experience

- User selects or searches for an Earth system phenomenon or location.
- The mobile app triggers a Liquid Galaxy guided tour.
- The rig camera flies to relevant regions.
- KML layers display the selected climate process.
- The app shows explanatory dashboard content.
- Narration explains the climate mechanism and regional weather impact.

## Primary Climate Visualizations

- Global ocean currents, including Gulf Stream and Kuroshio Current.
- Global wind circulation, including trade winds, westerlies, and polar easterlies.
- Jet streams and their role in steering storms.
- ENSO states: normal Pacific conditions, El Nino, and La Nina.
- Regional weather impact demonstrations, including Indian monsoon and city-level impacts such as Mumbai rainfall and flooding.

## Liquid Galaxy Requirements

- Generate and send KML layers to the master rig.
- Use curved colored arrows, ideally generated from Bezier paths, to visualize directional flows.
- Use placemarks/icons for clouds, low pressure, cities, and regional labels.
- Support multi-screen rig presentation with side information panels.
- Provide controls for fly-to views, refresh, clear KML, logo display, reboot, and shutdown.

## Data Sources

- NOAA datasets for ocean circulation and climate patterns.
- NASA Earth Science data for atmospheric and ocean observations.
- Atmospheric circulation datasets for trade winds, westerlies, polar easterlies, and related models.

## Technical Stack From Proposal

- Flutter and Dart for the mobile interface.
- KML and Google Earth rendering for geospatial visualization.
- Python scripts for KML geometry generation.
- SSH integration for Liquid Galaxy control.
- Gemini API for dynamic explanations and story generation.
- Deepgram API for voice command processing and text-to-speech narration.

## Current Workspace Alignment

- The workspace is already a Flutter app named `earth_science_app`.
- Existing app title is `Earth Systems Explorer`.
- Existing services include SSH/Liquid Galaxy control and KML transfer.
- Existing UI includes home, datasets, controls, and settings views.
- Current KML asset coverage appears focused on `assets/monsoon.kml`.
- Current implementation includes Liquid Galaxy connection settings, KML upload, fly-to, refresh, clear KML, logo display, reboot, and shutdown controls.

## Near-Term Build Priorities

- Replace generic placeholder climate categories with proposal-aligned phenomena: Gulf Stream, Kuroshio Current, jet stream, ENSO normal, El Nino, La Nina, Indian monsoon, and regional weather impacts.
- Expand KML assets/generation beyond monsoon.
- Add guided tour sequencing for each phenomenon.
- Add dashboard panels with climate explanation and impact metadata.
- Add map/location synchronization between the mobile app and Liquid Galaxy view.
- Add AI narration only after the core tour and KML flows are stable.
