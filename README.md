# Earth Systems Explorer: Immersive Climate & Weather Exploration Engine for Liquid Galaxy

[![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.1+-0175C2?logo=dart)](https://dart.dev)
[![Python](https://img.shields.io/badge/Python-v3.10+-3776AB?logo=python)](https://python.org)
[![Data Source](https://img.shields.io/badge/Data-ECMWF%20ERA5%20Reanalysis-003366)](https://cds.climate.copernicus.eu/)
[![Pipeline](https://img.shields.io/badge/Data%20Pipeline-Indian%20Monsoon%20%26%20ERA5-FF9933)](#-indian-monsoon--era5-data-processing-pipeline)
[![Protocol](https://img.shields.io/badge/Protocol-SSH2%20%7C%20SFTP-blue)](#-liquid-galaxy-multi-node-cluster-protocol)
[![AI Engine](https://img.shields.io/badge/AI-Gemini%201.5%20Flash-orange?logo=google)](https://deepmind.google/technologies/gemini/)

**Earth Systems Explorer** is a high-performance control and visualization engine engineered for the **Liquid Galaxy** multi-display cluster. The system combines scientific ECMWF ERA5 reanalysis data processing, procedural KML vector ribbon generation, automated 3D geospatial camera itineraries, bidirectional map synchronicity, and Gemini AI-driven telemetry cards across physical multi-node rig clusters.

---

## 🌧️ Indian Monsoon & ERA5 Data Processing Pipeline

The system includes an end-to-end scientific atmospheric pipeline that ingests raw ECMWF ERA5 climate reanalysis data, extracts 850 hPa wind vector fields, computes physical streamlines, and generates 3D vector KML layers for the **Indian Monsoon** ($\text{lat: } 20.5937^\circ\text{N}, \text{lng: } 78.9629^\circ\text{E}$).

```
[ ECMWF CDS API ] ──> ERA5 NetCDF4 (monsoon_850hpa_2025.nc) ──> Streamline Integration (xarray + scipy)
                                                                                  │
                                                                                  ▼
[ Liquid Galaxy Cluster ] <── SFTP Stream <── Arrow-Generator-Main <── JSON Path Vector Field
(Master lg1 & Slaves lgX)                     (KML Gradient Ribbons)      (monsoon_paths_2025.json)
```

### 1. ERA5 Data Acquisition (`tools/monsoon/download_era5.py`)
- **API Transport**: Communicates with the Copernicus Climate Data Store (CDS API, `cdsapi`) to fetch `reanalysis-era5-pressure-levels-monthly-means`.
- **Pressure Level Selection**: Requests 850 hPa pressure level ($u_{10}$ zonal and $v_{10}$ meridional wind components). The 850 hPa isobaric surface (~1.5 km altitude) represents the atmospheric boundary layer where the **Somali Jet (Findlater Jet)** and cross-equatorial monsoon winds flow into South Asia.
- **Temporal & Spatial Scope**: Fetches JJAS (June, July, August, September) 2025 monthly reanalysis bounded within geographical coordinates `[North: 35°N, West: 50°E, South: -10°S, East: 100°E]`, saved as NetCDF4 (`data/era5/monsoon_850hpa_2025.nc`).

### 2. Scientific Streamline Numerical Integration (`tools/monsoon/process_monsoon.py`)
- **Continuous Velocity Interpolation**: Ingests NetCDF4 grid coordinates using `xarray` and constructs 2D spatial velocity field interpolators $u(\lambda, \phi)$ and $v(\lambda, \phi)$ via `scipy.interpolate.RegularGridInterpolator`.
- **Streamline Trajectory Tracking**: Seed points are initialized in the Arabian Sea ($51^\circ\text{--}65^\circ\text{E}, 5^\circ\text{--}21^\circ\text{N}$) and Bay of Bengal ($80^\circ\text{--}94^\circ\text{E}, 5^\circ\text{--}21^\circ\text{N}$). Streamline integration runs with step size $\Delta s = 0.15^\circ$ up to 450 integration steps until wind speed drops below `MIN_WIND_SPEED` $= 0.5\text{ m/s}$ or leaves the spatial domain.
- **Regional Target Filtering**: Streamlines are categorized into distinct meteorological branches (Arabian South, Arabian Central, West Coast / Western Ghats, Central India, Punjab/Haryana, Gangetic Plain, Bay of Bengal, and Northeast India / Cherrapunji).
- **Trajectory Uniform Resampling**: Smooths trajectories and resamples each path into 45 uniform spatial coordinate nodes $(\lambda_i, \phi_i, u_i, v_i, \text{speed}_i)$, exported to `data/processed/monsoon/monsoon_paths_2025.json`.

---

## 🏹 Arrow-Generator-Main Engine (Procedural Vector & KML Ribbon Synthesizer)

Located in `Arrow-Generator-main/`, this procedural generation engine converts raw JSON velocity trajectories (`monsoon_paths_2025.json`, `el_nino`, `la_nina`, `gulf_stream`, `kuroshio`) into 3D KML vector ribbon visualizations with smooth polygon arrowheads and color gradients.

```
[ Representative Trajectory Points ]
               │
               ▼
   compute_boundary_vertices()  ──> Normal vectors n_x = -dy/L, n_y = dx/L
               │
               ▼
   interpolate_color(t)          ──> Color gradient (Deep Blue -> Bright Cyan)
               │
               ▼
   create_quad_polygon()         ──> KML <Polygon> Quad Ribbon Sections
               │
               ▼
   create_arrowhead()            ──> Joined Polygon Arrowhead at Terminal Vector
```

### 1. Perpendicular Normal Vector & Boundary Construction
For an ordered 45-point ERA5 centerline trajectory $P_i = (\lambda_i, \phi_i)$, the engine calculates segment direction vectors $(\Delta x, \Delta y)$ and unit normal vectors $\mathbf{n} = (n_x, n_y)$:

$$n_x = -\frac{\Delta y}{\sqrt{\Delta x^2 + \Delta y^2}}, \quad n_y = \frac{\Delta x}{\sqrt{\Delta x^2 + \Delta y^2}}$$

- **Vertex Normal Averaging**: At intermediate vertex $i$, segment normals are averaged and normalized to ensure smooth ribbon transitions without miter tearing:

$$\mathbf{n}_{\text{vertex}, i} = \frac{\mathbf{n}_{\text{prev}} + \mathbf{n}_{\text{next}}}{\|\mathbf{n}_{\text{prev}} + \mathbf{n}_{\text{next}}\|}$$

- **Ribbon Boundary Offsets**: Left and right boundary coordinates are constructed using ribbon width $w = 0.35^\circ$:

$$P_{\text{left}, i} = P_i + \mathbf{n}_{\text{vertex}, i} \cdot w, \quad P_{\text{right}, i} = P_i - \mathbf{n}_{\text{vertex}, i} \cdot w$$

### 2. Path Color Gradient Interpolation (`interpolate_color`)
Colors transition along normalized path parameter $t \in [0.0, 1.0]$ from ocean origin to target landfall:
- **Interpolation Function**: Computes RGB channel transitions from Deep Blue (`#d90000ff`, $t=0.0$) to Bright Cyan (`#d900ffff`, $t=1.0$):

$$\text{Red} = 0, \quad \text{Green} = \lfloor 255 \cdot t \rfloor, \quad \text{Blue} = 255$$

- Formatted into KML alpha-blue-green-red hex format (`aabbggrr`).

### 3. Polygon Arrowhead Geometry Construction (`create_arrowhead`)
Terminal trajectory vectors $P_{n-1} \rightarrow P_n$ determine arrowhead orientation angle $\theta = \operatorname{atan2}(\Delta y, \Delta x)$:
- **Tip Coordinates**: Located at terminal ERA5 coordinate $P_n$.
- **Wing Coordinates**: Positioned at distance $S = 1.2^\circ$ (size) and angle $\pm \frac{\pi}{6}$ ($30^\circ$ sweep angle):

$$x_{\text{left}} = x_{\text{tip}} - S \cos\left(\theta - \frac{\pi}{6}\right), \quad y_{\text{left}} = y_{\text{tip}} - S \sin\left(\theta - \frac{\pi}{6}\right)$$

$$x_{\text{right}} = x_{\text{tip}} - S \cos\left(\theta + \frac{\pi}{6}\right), \quad y_{\text{right}} = y_{\text{tip}} - S \sin\left(\theta + \frac{\pi}{6}\right)$$

- **Seamless Shaft Join**: Polygon vertices explicitly bind to `shaft_left_end` and `shaft_right_end` of the quad ribbon to form an un-gapped solid vector geometry.

### 4. Trajectory Truncation & Gap Management
- **`truncate_curve_by_distance`**: Trims the terminal end of the ribbon shaft by arrowhead length ($S \cos(\pi/6) + 0.15^\circ$) so the arrowhead polygon fits cleanly without z-fighting overlap.
- **`trim_curve_start_by_distance`**: Trims initial trajectory segments by $0.15^\circ$ to maintain visual separation between adjacent wind paths without altering trajectory direction.

### 5. Automated Tour Playlist Generator (`Arrow-Generator-main/tour_generator.py`)
- Programmatically constructs `<gx:Tour>` playlists for all 5 major phenomena (`indianmonsoon_tour.kml`, `el_nino_tour.kml`, `la_nina_tour.kml`, `gulf_stream_tour.kml`, `kuroshio_tour.kml`).
- Configures multi-stop scientific LookAt sequences specifying `latitude`, `longitude`, `range`, `tilt`, `heading`, `duration`, and `flyToMode` (`smooth`).

---

## 🛰️ Liquid Galaxy Multi-Node Cluster Protocol

The communication layer handles low-level cluster control via encrypted TCP sockets (`dartssh2`).

```
+-------------------+        SSH/SFTP (Port 22)        +-------------------+
|                   |  ------------------------------> | Master Node (lg1) |
|                   |  Commands: /tmp/query.txt        | - Google Earth    |
|   Mobile Client   |  KML Files: /var/www/html/       +-------------------+
|  (Flutter App)    |                                            |
|                   |        SSH execution (sshpass)             |
|                   |  ------------------------------------------+
+-------------------+                                            v
                                                       +-------------------+
                                                       | Slave Nodes (lgX) |
                                                       | - Logos & Overlay |
                                                       +-------------------+
```

### 1. Socket Lifecycle & Fault Tolerance
- **Heartbeat Monitor**: `LGSSHClient` maintains a 10-second SSH socket keepalive (`keepAliveInterval`) paired with a 5-second `echo "ping"` command verification loop.
- **Auto-Reconnection**: Network disconnects trigger an automated 3-attempt reconnection routine with a 3-second backoff interval.

### 2. Multi-Screen Topology Calculation Math
Rig screen indices for slave overlays (logos, phenomenon cards) are dynamically calculated based on cluster size:
- **Leftmost Screen Index**: $\text{screen}_{\text{left}} = \left\lfloor \frac{\text{totalScreens}}{2} \right\rfloor + 2$
- **Rightmost Screen Index**: $\text{screen}_{\text{right}} = \left\lfloor \frac{\text{totalScreens}}{2} \right\rfloor + 1$

### 3. Remote XML Refresh Interval Mutation
To force immediate slave node overlay re-renders without restarting Google Earth, the engine executes remote `sed` mutations over SSH:
```bash
sshpass -p <password> ssh -t lgX 'echo <password> | sudo -S sed -i "s|<href>...</href>|<href>...</href><refreshMode>onInterval</refreshMode><refreshInterval>2</refreshInterval>|" ~/earth/kml/slave/myplaces.kml'
```

---

## 🔄 Bidirectional Geospatial Map Synchronization Engine

`MapSyncService` maintains continuous 2D-to-3D viewport synchronicity between the client's mobile map (`google_maps_flutter`) and the Liquid Galaxy cluster.

### 1. Zoom-to-Range Scale Transformation
Translates mobile 2D discrete map zoom (1.0–21.0) into Google Earth 3D camera range (altitude meters) using exponential scaling:

$$\text{range} = \frac{591657550.5}{2^{\text{zoom} - 1}}$$

### 2. Feedback Loop Suppression & Debouncing
- **Suppression Flag**: Programmatic map adjustments set `_suppressNextCameraIdle = true` to consume the resulting `onCameraIdle` event and prevent infinite $\text{Phone} \leftrightarrow \text{Rig}$ reflection loops.
- **Gesture Debouncer**: Outbound SSH `flytoview` packets are throttled with a 300ms timer to prevent socket saturation during active touch drags.

---

## 🤖 AI Reasoning & Speech Synthesis Pipeline

- **Gemini LLM Integration** (`google_generative_ai`): Queries `gemini-1.5-flash` with domain-constrained prompt templates (`AIPrompts`) for dynamic climate analysis and structured JSON telemetry.
- **Speech Synthesis Engine** (`flutter_tts`): `TTSService` manages asynchronous speech queues, syncing spoken narration with 3D geospatial tour transitions.
- **Hardware-Backed Encryption** (`flutter_secure_storage`): Encrypts and isolates AI API keys within native OS keychains (iOS Keychain / Android EncryptedSharedPreferences).

---

## 📦 Core Technical Stack & Protocol Summary

| Module | Core Dependencies | Primary Technical Function |
| :--- | :--- | :--- |
| **ERA5 Data Processing** | `cdsapi`, `xarray`, `scipy`, `cartopy`, `numpy` | NetCDF4 downloading, 850 hPa wind vector interpolation, streamline numerical integration. |
| **Arrow Generator Engine** | Python 3.10+ (`math`, `json`, `pathlib`) | Normal vector geometry, quad ribbon polygon synthesis, arrowhead computation, KML generation. |
| **Cluster SSH Protocol** | `dartssh2: ^2.13.0` | Socket lifecycle, `/tmp/query.txt` streaming, SFTP uploads, remote `sed` execution. |
| **Geospatial Sync** | `google_maps_flutter: ^2.5.3` | Mobile map controller, coordinate transformation math, debounced gesture tracking. |
| **AI Intelligence** | `google_generative_ai: ^0.4.7` | Gemini 1.5 Flash structured JSON generation & climate prompt engineering. |
| **Voice Narration** | `flutter_tts: ^4.2.0` | Asynchronous text-to-speech audio queueing for guided tours. |
| **Persistence & Security**| `hive_flutter: ^1.1.0`<br>`flutter_secure_storage: ^9.2.4` | Zero-latency NoSQL telemetry caching & encrypted API key storage. |
