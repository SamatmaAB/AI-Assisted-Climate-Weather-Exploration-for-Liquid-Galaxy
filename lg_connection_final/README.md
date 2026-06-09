# Liquid Galaxy Controller - GSoC Task 2

A basic Flutter application designed to control a Liquid Galaxy rig via SSH. This app allows users to send logos, visualize 3D shapes (KML), and navigate to specific coordinates using "Fly-to" instructions.

## 🚀 Features

-   **SSH Connection:** Seamlessly connects to the Liquid Galaxy master rig using configurable IP, port, and credentials.
-   **Send LG Logo:** Displays the Liquid Galaxy logo as a `ScreenOverlay` on the left screen (Slave 1).
-   **3D Coloured Pyramid:** Generates and sends a 3D KML containing a four-sided pyramid with different coloured faces (Red, Green, Blue, Yellow).
-   **Fly-to Home City:** Automatically navigates the camera to **Mysore, India**, providing a 3D panoramic view of the location.
-   **Clear Actions:** Options to individually clean logos and KMLs from the rig screens.
-   **Adaptive Layout:** Supports both Portrait and Landscape orientations for tablets and phones.

## 📁 Repository Structure

-   `lib/`: Contains the Flutter source code.
    -   `connections/ssh.dart`: Handles all SSH logic and KML generation.
    -   `screens/home_screen.dart`: The main UI with action buttons.
-   `kmls/`: Standalone `.kml` files generated and used by the app.
    -   `slave_1.kml`: The Liquid Galaxy Logo overlay.
    -   `master.kml`: The 3D Coloured Pyramid.
-   `android/`: Android-specific configuration for the release build.

## 🛠️ Requirements

-   **Flutter SDK:** ^3.0.0
-   **Liquid Galaxy Rig:** A standard 3-rig setup (or configurable number of rigs).
-   **SSH Access:** Credentials for the `lg` user on the master rig.

## 📦 How to Build

To create a release build of the APK:

```bash
flutter build apk --release
```

The output APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## 📝 Credits

-   **Logo Source:** Liquid Galaxy Project (hosted via Google Blogger).
-   **Pyramid KML:** Custom-created for this task using triangular polygons.
-   **Home City:** Mysore, India (Coordinates: 12.3051° N, 76.6551° E).

---
*Created as part of the Google Summer of Code (GSoC) selection process for Liquid Galaxy.*