# 🌍Demonstration of Arrow generating Visualization using KML

A procedural geospatial visualization tool that generates, in this case **monsoon wind patterns** using smooth curves, directional arrows, and weather icons, exported as a **KML file** for visualization in Google Earth or Liquid Galaxy.

---

## 📌 Overview

This project simulates large-scale **monsoon systems over the Indian subcontinent** by programmatically generating:

- Curved wind flow/ ocean currents paths using **Bezier curves**
- Directional arrows to indicate flow
- Weather icons (rainfall and low-pressure zones)
- A complete `.kml` file for geospatial visualization

The output can be visualized in tools like **Google Earth/Liquid Galaxy** to explore atmospheric patterns interactively.

---

## 🚀 Features

- 🌊 Smooth wind trajectories using Bezier curves  
- ➡️ Directional arrows with arrowheads  
- 🌧️ Weather markers (rainfall zones, low-pressure regions)  
- 🧭 Multiple monsoon branches:
  - Arabian Sea branch  
  - Bay of Bengal branch  
  - Southeast Asia inflow  
- 📦 Fully automated KML generation  
- 🌐 Compatible with Liquid Galaxy setups  

---

## 🧠 How It Works

### 1. Bezier Curve Generation
Smooth curves are generated between two points using a control point:
B(t) = (1−t)²P₀ + 2(1−t)tP₁ + t²P₂


This creates natural-looking wind flow paths.

---

### 2. Arrow Construction
Each wind path consists of:
- A **LineString** (curve)
- A **polygon arrowhead** (direction indicator)

---

### 3. Icon Placement
Icons are added at key locations:
- Rainfall regions 🌧️  
- Low-pressure center 🌀  

---

### 4. KML Export
All elements are wrapped into a valid and saved as a .kml:
```xml
<kml>
  <Document>
