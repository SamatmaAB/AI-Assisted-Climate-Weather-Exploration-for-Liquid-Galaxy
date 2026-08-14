# Earth Systems Explorer: Immersive Climate & Weather Exploration Engine for Liquid Galaxy

[![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.1+-0175C2?logo=dart)](https://dart.dev)
[![Pipeline](https://img.shields.io/badge/Data%20Pipeline-Indian%20Monsoon-FF9933)](#-indian-monsoon--climate-data-pipeline)
[![Protocol](https://img.shields.io/badge/Protocol-SSH2%20%7C%20SFTP-blue)](#-liquid-galaxy-multi-node-cluster-protocol)
[![AI Engine](https://img.shields.io/badge/AI-Gemini%201.5%20Flash-orange?logo=google)](https://deepmind.google/technologies/gemini/)

**Earth Systems Explorer** is an advanced control and visualization engine engineered for the **Liquid Galaxy** multi-display cluster. The application orchestrates high-resolution geospatial vector layers, automated 3D camera sweeps, bidirectional map synchronicity, and AI-driven telemetry cards across physical multi-node rig clusters.

---

## 🌧️ Indian Monsoon & Climate Data Pipeline

The flagship data pipeline ingests, transforms, renders, and narrates atmospheric and oceanographic phenomena—with specialized optimization for the **Indian Monsoon** ($\text{lat: } 20.5937^\circ\text{N}, \text{lng: } 78.9629^\circ\text{E}$).

```
[ Vector KML / Tour Assets ] ───────> SFTP Upload to Master (/var/www/html/) ───────> Master Display (lg1)
                                                                                              │
[ Phenomenon Identifier ]                                                                      │ Rig Focus (LookAt)
       │                                                                                      ▼
       ├───> Hive Cache Check ──(Hit)───┐                                           [ Multi-Screen Rig ]
       │                                 ▼                                                    ▲
       └───> Gemini 1.5 Flash ─(Miss)──> JSON Telemetry                                       │
                                         │                                                    │ KML Upload &
                                         ▼                                                    │ sed Refresh
                               Off-Axis Offset Math ──> Rightmost Slave Screen KML ───────────┘
                               (\Delta lat, \Delta lng)      (slave_X.kml Balloon)
```

### 1. Multi-Node Asset Deployment Pipeline
When initiating the Indian Monsoon visualization, `HomeViewModel` executes an atomic multi-step deployment sequence across the cluster:
1. **Asset Transport**: Streams raw KML vector paths (`assets/kml/indian_monsoon.kml`) and guided camera tour playlists (`assets/kml/indianmonsoon_tour.kml`) via SFTP to `/var/www/html/` on the master node (`lg1`).
2. **KML Index Dispatch**: Modifies `/var/www/html/kmls.txt` to inject both dataset and tour endpoints, broadcasting active render calls to all cluster nodes via `refreshkml`.
3. **Camera Framing**: Emits a `<LookAt>` payload targeting the Indian subcontinent ($\text{range: } 5,000,000\,\text{m}, \text{tilt: } 45^\circ$) directly to `/tmp/query.txt`.

### 2. AI Telemetry & Phenomenon Balloon Pipeline (`PhenomenonCardService`)
Simultaneously, a structured AI data pipeline generates real-time scientific telemetry for display on the cluster's rightmost node:

1. **LLM JSON Synthesis**: Calls `gemini-1.5-flash` using a system instruction (`AIPrompts.phenomenonCard`) to extract structured telemetry (thermodynamic drivers, precipitation corridors, ocean-atmosphere domain tags, and impact metrics).
2. **Zero-Latency Caching**: Results are stored in a local `Hive` key-value store, bypassing LLM latency on subsequent visualizations.
3. **Off-Axis Spherical Coordinate Transformation**: To center the balloon over the rightmost screen in a multi-display rig, target coordinates are computed using spherical offset math:

$$\Delta \text{lat} = \frac{d \cdot \cos(\text{heading} + 90^\circ)}{111000}, \quad \Delta \text{lng} = \frac{d \cdot \sin(\text{heading} + 90^\circ)}{111000 \cdot \cos(\text{lat}_{\text{rad}})}$$

Where $d = 350\,\text{m}$ represents the offset distance vector.

4. **Slave Overlay Injection**: Compiles the dataset into a glassmorphic HTML/CSS KML balloon, writes to `/var/www/html/kml/slave_<rightMostScreen>.kml`, and executes `sudo sed` string replacement over SSH to trigger instant display updates.

### 3. Synchronized Guided Tour & Speech Synthesis
- **Camera Tour Execution**: Triggers `playtour=Indian Monsoon Guided Tour` in `/tmp/query.txt` to initiate smooth `<gx:FlyTo>` camera sweeps along the Arabian Sea and Bay of Bengal monsoon branches.
- **Narrative Audio Pipeline**: Asynchronously requests Gemini explanations (`AIRepository.getExplanation`) and queues real-time text-to-speech audio via `TTSService` (`flutter_tts`), keeping spoken narration in sync with geospatial movements.

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

## 🌀 KML Generation & 3D Orbital Engine

### Parametric Orbital Camera Sweeps
`SSHCommands.buildOrbitTourKml` programmatically generates parametric `<gx:Tour>` XML payloads orbiting a central coordinate $(\text{lat}, \text{lng})$:
- **Total Keyframe Steps**: $N = \left( \frac{360}{\Delta H} \right) \cdot \text{rotations}$
- **Heading Keyframes**: $H_i = (H_0 + i \cdot \Delta H) \pmod{360}$

```xml
<gx:Tour>
  <name>Orbit</name>
  <gx:Playlist>
    <gx:FlyTo>
      <gx:duration>1.0</gx:duration>
      <gx:flyToMode>smooth</gx:flyToMode>
      <LookAt>
        <longitude>78.9629</longitude>
        <latitude>20.5937</latitude>
        <heading>120.0</heading>
        <tilt>60.0</tilt>
        <range>1000000.0</range>
      </LookAt>
    </gx:FlyTo>
  </gx:Playlist>
</gx:Tour>
```

---

## 🤖 AI Reasoning & Speech Synthesis Pipeline

- **Gemini LLM Integration** (`google_generative_ai`): Queries `gemini-1.5-flash` with domain-constrained prompt templates (`AIPrompts`) for dynamic climate analysis and structured JSON telemetry.
- **Speech Synthesis Engine** (`flutter_tts`): `TTSService` manages asynchronous speech queues, syncing spoken narration with 3D geospatial tour transitions.
- **Hardware-Backed Encryption** (`flutter_secure_storage`): Encrypts and isolates AI API keys within native OS keychains (iOS Keychain / Android EncryptedSharedPreferences).

---

## 📦 Core Technical Stack & Protocol Summary

| Module | Core Dependencies | Primary Technical Function |
| :--- | :--- | :--- |
| **Cluster SSH Protocol** | `dartssh2: ^2.13.0` | Socket lifecycle, `/tmp/query.txt` streaming, SFTP uploads, remote `sed` execution. |
| **Geospatial Sync** | `google_maps_flutter: ^2.5.3` | Mobile map controller, coordinate transformation math, debounced gesture tracking. |
| **AI Intelligence** | `google_generative_ai: ^0.4.7` | Gemini 1.5 Flash structured JSON generation & climate prompt engineering. |
| **Voice Narration** | `flutter_tts: ^4.2.0` | Asynchronous text-to-speech audio queueing for guided tours. |
| **Persistence & Security**| `hive_flutter: ^1.1.0`<br>`flutter_secure_storage: ^9.2.4` | Zero-latency NoSQL telemetry caching & encrypted API key storage. |
