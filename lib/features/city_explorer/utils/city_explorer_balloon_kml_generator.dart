import 'package:lg_connection/features/city_explorer/models/city_landmark.dart';
import 'package:lg_connection/features/city_explorer/models/weather_data.dart';

/// Generates the complete KML document for the City Explorer details balloon.
///
/// This class is a **pure generator** — it performs no SSH operations, no file
/// uploads, and no side effects. It accepts all required data and returns a
/// KML string ready to be uploaded to a slave_N.kml file on the LG rig.
///
/// The balloon renders via Google Earth's BalloonStyle mechanism:
///   KML BalloonStyle → HTML/CSS inside CDATA → Google Earth renders the card
class CityExplorerBalloonKmlGenerator {
  CityExplorerBalloonKmlGenerator._();

  /// Generates a complete KML document string.
  ///
  /// [landmark]        – the resolved city landmark with coordinates and context.
  /// [weather]         – current weather data for the landmark location.
  /// [iconUrl]         – HTTP URL of the weather icon on the LG web server.
  /// [narration]       – Gemini-generated climate/weather explanation.
  /// [targetLatitude]  – optional custom latitude (e.g. offset for screen center).
  /// [targetLongitude] – optional custom longitude (e.g. offset for screen center).
  static String generate({
    required CityLandmark landmark,
    required WeatherData weather,
    required String iconUrl,
    required String narration,
    double? targetLatitude,
    double? targetLongitude,
  }) {
    final lat = targetLatitude ?? landmark.latitude;
    final lng = targetLongitude ?? landmark.longitude;

    final html = _buildHtml(
      landmark: landmark,
      weather: weather,
      iconUrl: iconUrl,
      narration: narration,
    );

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:gx="http://www.google.com/kml/ext/2.2">
<Document>
  <name>City Explorer — ${_esc(landmark.landmark)}</name>

  <Style id="cityExplorerBalloonStyle">
    <BalloonStyle>
      <bgColor>ff1c140f</bgColor>
      <textColor>ffffffff</textColor>
      <text><![CDATA[$html]]></text>
    </BalloonStyle>
    <IconStyle>
      <scale>1.0</scale>
      <Icon>
        <href>http://maps.google.com/mapfiles/kml/paddle/red-circle.png</href>
      </Icon>
    </IconStyle>
    <LabelStyle>
      <scale>1.0</scale>
    </LabelStyle>
  </Style>

  <Placemark>
    <name>${_esc(landmark.landmark)}</name>
    <styleUrl>#cityExplorerBalloonStyle</styleUrl>
    <gx:balloonVisibility>1</gx:balloonVisibility>
    <Point>
      <coordinates>$lng,$lat,0</coordinates>
    </Point>
  </Placemark>
</Document>
</kml>''';
  }

  // ─── HTML / CSS builder ───────────────────────────────────────────────────

  static String _buildHtml({
    required CityLandmark landmark,
    required WeatherData weather,
    required String iconUrl,
    required String narration,
  }) {
    final tempStr = '${weather.temperature.toStringAsFixed(1)}°C';
    final humidityStr = '${weather.humidity}%';
    final windStr = '${weather.windSpeed.toStringAsFixed(0)} km/h';
    final precipStr = '${weather.precipitation.toStringAsFixed(1)} mm';

    // Escape text for safe embedding in HTML
    final cityHtml = _esc(landmark.city.toUpperCase());
    final landmarkHtml = _esc(landmark.landmark);
    final conditionHtml = _esc(weather.condition);
    final contextHtml = _esc(landmark.climateContext.toUpperCase());
    final narrationHtml = _escHtml(narration);

    return '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet"/>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }

  html, body {
    width: 500px;
    font-family: 'Inter', system-ui, sans-serif;
    background: transparent;
    color: #E1E2E9;
    overflow: hidden;
  }

  .card {
    width: 500px;
    background: linear-gradient(
      160deg,
      rgba(27, 32, 41, 0.98) 0%,
      rgba(15, 20, 28, 0.98) 100%
    );
    border: 1px solid rgba(158, 206, 255, 0.22);
    border-radius: 20px;
    overflow: hidden;
    box-shadow:
      0 12px 40px rgba(0, 0, 0, 0.6),
      0 0 0 1px rgba(158, 206, 255, 0.08) inset;
  }

  /* ── Header ────────────────────────────────────────── */
  .header {
    padding: 22px 24px 16px;
    background: linear-gradient(
      180deg,
      rgba(0, 99, 155, 0.35) 0%,
      rgba(0, 49, 91, 0.15) 100%
    );
    border-bottom: 1px solid rgba(158, 206, 255, 0.15);
  }

  .city-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: linear-gradient(90deg, rgba(0, 73, 125, 0.65) 0%, rgba(0, 99, 155, 0.45) 100%);
    border: 1px solid rgba(158, 206, 255, 0.45);
    border-radius: 8px;
    padding: 6px 14px;
    margin-bottom: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3), 0 0 12px rgba(158, 206, 255, 0.15) inset;
  }

  .location-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #9ECEFF;
    box-shadow: 0 0 8px #9ECEFF;
    flex-shrink: 0;
  }

  .city-name {
    font-size: 14px;
    font-weight: 800;
    letter-spacing: 2.2px;
    color: #9ECEFF;
    text-transform: uppercase;
    line-height: 1;
  }

  .landmark-name {
    font-size: 22px;
    font-weight: 800;
    color: #FFFFFF;
    margin-top: 2px;
    line-height: 1.25;
    letter-spacing: -0.3px;
  }

  /* ── Weather hero ───────────────────────────────────── */
  .weather-hero {
    padding: 20px 24px;
    display: flex;
    align-items: center;
    gap: 22px;
    border-bottom: 1px solid rgba(194, 199, 211, 0.08);
  }

  .weather-icon {
    width: 90px;
    height: 90px;
    object-fit: contain;
    filter: drop-shadow(0 6px 16px rgba(158, 206, 255, 0.3));
    flex-shrink: 0;
  }

  .weather-info {
    flex: 1;
    min-width: 0;
  }

  .temperature {
    font-size: 52px;
    font-weight: 800;
    color: #FFFFFF;
    letter-spacing: -2px;
    line-height: 1;
  }

  .condition {
    font-size: 15px;
    font-weight: 600;
    color: #9ECEFF;
    margin-top: 6px;
    letter-spacing: 0.3px;
  }

  /* ── Metrics grid (Horizontal) ──────────────────────── */
  .metrics {
    padding: 14px 24px;
    display: flex;
    justify-content: space-around;
    align-items: center;
    border-bottom: 1px solid rgba(194, 199, 211, 0.08);
    background: rgba(0, 0, 0, 0.15);
  }

  .metric-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
  }

  .metric-label {
    font-size: 10px;
    font-weight: 700;
    color: rgba(194, 199, 211, 0.65);
    letter-spacing: 1.2px;
    text-transform: uppercase;
  }

  .metric-value {
    font-size: 15px;
    font-weight: 700;
    color: #E1E2E9;
  }

  .metric-divider {
    width: 1px;
    height: 24px;
    background: rgba(158, 206, 255, 0.15);
  }

  /* ── Climate context ────────────────────────────────── */
  .climate-section {
    padding: 16px 24px 0;
  }

  .section-label {
    font-size: 9.5px;
    font-weight: 700;
    letter-spacing: 2px;
    color: rgba(118, 214, 155, 0.75);
    text-transform: uppercase;
    margin-bottom: 6px;
  }

  .context-tag {
    display: inline-block;
    font-size: 11.5px;
    font-weight: 700;
    color: #76D69B;
    background: rgba(118, 214, 155, 0.12);
    border: 1px solid rgba(118, 214, 155, 0.25);
    border-radius: 8px;
    padding: 4px 12px;
    letter-spacing: 0.8px;
  }

  /* ── Narration ──────────────────────────────────────── */
  .narration-section {
    padding: 14px 24px 20px;
  }

  .narration-label {
    font-size: 9.5px;
    font-weight: 700;
    letter-spacing: 2px;
    color: rgba(255, 184, 107, 0.85);
    text-transform: uppercase;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .narration-label::before {
    content: '';
    display: inline-block;
    width: 18px;
    height: 2px;
    background: linear-gradient(90deg, #FFB86B, transparent);
    border-radius: 1px;
  }

  .narration-text {
    font-size: 13px;
    font-weight: 400;
    color: rgba(225, 226, 233, 0.88);
    line-height: 1.65;
  }

  /* ── Footer brand strip ──────────────────────────────── */
  .brand-strip {
    background: linear-gradient(
      90deg,
      rgba(0, 49, 91, 0.6) 0%,
      rgba(0, 73, 125, 0.3) 100%
    );
    padding: 10px 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-top: 1px solid rgba(158, 206, 255, 0.12);
  }

  .brand-name {
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 2.2px;
    color: rgba(158, 206, 255, 0.7);
    text-transform: uppercase;
  }
</style>
</head>
<body>
<div class="card">

  <!-- Header -->
  <div class="header">
    <div class="city-badge">
      <span class="location-dot"></span>
      <span class="city-name">$cityHtml</span>
    </div>
    <div class="landmark-name">$landmarkHtml</div>
  </div>

  <!-- Weather hero -->
  <div class="weather-hero">
    <img class="weather-icon" src="$iconUrl" alt="$conditionHtml"/>
    <div class="weather-info">
      <div class="temperature">$tempStr</div>
      <div class="condition">$conditionHtml</div>
    </div>
  </div>

  <!-- Metrics -->
  <div class="metrics">
    <div class="metric-item">
      <span class="metric-label">HUMIDITY</span>
      <span class="metric-value">$humidityStr</span>
    </div>
    <div class="metric-divider"></div>
    <div class="metric-item">
      <span class="metric-label">WIND</span>
      <span class="metric-value">$windStr</span>
    </div>
    <div class="metric-divider"></div>
    <div class="metric-item">
      <span class="metric-label">PRECIPITATION</span>
      <span class="metric-value">$precipStr</span>
    </div>
  </div>

  <!-- Climate context -->
  <div class="climate-section">
    <div class="section-label">Climate Context</div>
    <div class="context-tag">$contextHtml</div>
  </div>

  <!-- Narration -->
  <div class="narration-section">
    <div class="narration-label">AI Climate Insight</div>
    <div class="narration-text">$narrationHtml</div>
  </div>

  <!-- Brand strip -->
  <div class="brand-strip">
    <span class="brand-name">AI-ASSISTED EARTH SYSTEM EXPLORER</span>
  </div>

</div>
</body>
</html>''';
  }

  // ─── XML / HTML escaping ──────────────────────────────────────────────────

  /// Escapes characters that are special in XML/HTML attribute values and
  /// text content. Used for KML element text nodes.
  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  /// Escapes for inclusion in HTML text nodes (ampersands, angle brackets).
  /// Preserves line breaks as `<br>` tags.
  static String _escHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('\n', '<br/>');
}
