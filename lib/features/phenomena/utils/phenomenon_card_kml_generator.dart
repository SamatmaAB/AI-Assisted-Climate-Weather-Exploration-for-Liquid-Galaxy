import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/models/phenomenon_card_data.dart';

/// Generates the complete KML document for a climate-phenomenon details card.
///
/// This is a **pure generator** — no SSH, no uploads, no side effects. It
/// produces a KML string ready to be written to `slave_N.kml` on the LG rig.
///
/// The card mirrors the City Explorer details card styling:
///   KML BalloonStyle → HTML/CSS inside CDATA → Google Earth renders the card
class PhenomenonCardKmlGenerator {
  PhenomenonCardKmlGenerator._();

  /// Generates a complete KML document string.
  ///
  /// [phenomenon]   – the resolved climate phenomenon (provides id/name + coords).
  /// [data]         – Gemini-sourced card content.
  /// [iconUrl]      – HTTP URL of the phenomenon icon on the LG web server.
  /// [targetLatitude] / [targetLongitude] – optional offset for screen center.
  static String generate({
    required ClimatePhenomenon phenomenon,
    required PhenomenonCardData data,
    required String iconUrl,
    double? targetLatitude,
    double? targetLongitude,
  }) {
    final coords = parseLookAt(phenomenon.lookAtXml);
    final lat = targetLatitude ?? coords['latitude']!;
    final lng = targetLongitude ?? coords['longitude']!;

    final html = _buildHtml(data: data, iconUrl: iconUrl);

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:gx="http://www.google.com/kml/ext/2.2">
<Document>
  <name>Phenomenon Card — ${_esc(data.name)}</name>

  <Style id="phenomenonCardStyle">
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
    <name>${_esc(data.name)}</name>
    <styleUrl>#phenomenonCardStyle</styleUrl>
    <gx:balloonVisibility>1</gx:balloonVisibility>
    <Point>
      <coordinates>$lng,$lat,0</coordinates>
    </Point>
  </Placemark>
</Document>
</kml>''';
  }

  /// Extracts lat/long from a phenomenon's hardcoded `<LookAt>` XML.
  /// Public so the deploy service can reuse the same coordinate source.
  static Map<String, double> parseLookAt(String lookAtXml) {
    double lat = 0.0;
    double lng = 0.0;
    final latMatch =
        RegExp(r'<latitude>([^<]+)</latitude>').firstMatch(lookAtXml);
    final lngMatch =
        RegExp(r'<longitude>([^<]+)</longitude>').firstMatch(lookAtXml);
    if (latMatch != null) lat = double.tryParse(latMatch.group(1)!) ?? 0.0;
    if (lngMatch != null) lng = double.tryParse(lngMatch.group(1)!) ?? 0.0;
    return {'latitude': lat, 'longitude': lng};
  }

  // ─── HTML / CSS builder ───────────────────────────────────────────────────

  static String _buildHtml({
    required PhenomenonCardData data,
    required String iconUrl,
  }) {
    final cityHtml = _esc(data.name.toUpperCase());
    final landmarkHtml = _esc(data.name);
    final categoryHtml = _esc(data.category);
    final regionHtml = _esc(data.region.toUpperCase());
    final summaryHtml = _escHtml(data.summary);
    final insightHtml = _escHtml(data.insight);

    final factsHtml = data.keyFacts.isEmpty
        ? ''
        : '''
  <!-- Key facts -->
  <div class="metrics" style="flex-direction: column; align-items: stretch; gap: 8px;">
    <div class="metric-item" style="flex-direction: row; align-items: flex-start; gap: 10px;">
      <span class="metric-label" style="min-width: 64px; text-align: left;">FACTS</span>
      <span class="metric-value" style="text-align: left; font-weight: 500; line-height: 1.5;">
${data.keyFacts.map((f) => '${_escHtml(f)}<br/>').join('\n')}      </span>
    </div>
  </div>''';

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
    width: 100%;
    margin: 0;
    padding: 0;
    font-family: 'Inter', system-ui, sans-serif;
    background: transparent;
    color: #E1E2E9;
    overflow: hidden;
  }

  .card {
    width: calc(100vw - 44px);
    margin: 0 22px;
    height: auto;
    background: linear-gradient(
      160deg,
      rgba(27, 32, 41, 0.98) 0%,
      rgba(15, 20, 28, 0.98) 100%
    );
    border: 1px solid rgba(158, 206, 255, 0.22);
    border-radius: 18px;
    padding: 16px;
    overflow: hidden;
    box-shadow:
      0 12px 40px rgba(0, 0, 0, 0.6),
      0 0 0 1px rgba(158, 206, 255, 0.08) inset;
  }

  /* ── Header ────────────────────────────────────────── */
  .header {
    padding: 16px;
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

  /* ── Hero (icon + summary) ─────────────────────────── */
  .weather-hero {
    padding: 16px;
    display: flex;
    align-items: center;
    gap: 16px;
    border-bottom: 1px solid rgba(194, 199, 211, 0.08);
  }

  .weather-icon {
    width: 80px;
    height: 80px;
    object-fit: contain;
    filter: drop-shadow(0 6px 16px rgba(158, 206, 255, 0.3));
    flex-shrink: 0;
  }

  .weather-info {
    flex: 1;
    min-width: 0;
  }

  .condition {
    font-size: 15px;
    font-weight: 600;
    color: #9ECEFF;
    margin-bottom: 6px;
    letter-spacing: 0.3px;
  }

  .summary-text {
    font-size: 13.5px;
    font-weight: 400;
    color: rgba(225, 226, 233, 0.88);
    line-height: 1.6;
  }

  /* ── Region tag ────────────────────────────────────── */
  .climate-section {
    padding: 16px 16px 0;
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

  /* ── Insight ──────────────────────────────────────── */
  .narration-section {
    padding: 14px 16px 16px;
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

  /* ── Footer brand strip ────────────────────────────── */
  .brand-strip {
    background: linear-gradient(
      90deg,
      rgba(0, 49, 91, 0.6) 0%,
      rgba(0, 73, 125, 0.3) 100%
    );
    padding: 10px 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-top: 1px solid rgba(158, 206, 255, 0.12);
  }
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

  <!-- Hero: icon + summary -->
  <div class="weather-hero">
    <img class="weather-icon" src="$iconUrl" alt="$categoryHtml"/>
    <div class="weather-info">
      <div class="condition">$categoryHtml</div>
      <div class="summary-text">$summaryHtml</div>
    </div>
  </div>

  <!-- Region -->
  <div class="climate-section">
    <div class="section-label">Primary Region</div>
    <div class="context-tag">$regionHtml</div>
  </div>

  <!-- Insight -->
  <div class="narration-section">
    <div class="narration-label">AI Climate Insight</div>
    <div class="narration-text">$insightHtml</div>
  </div>
$factsHtml

  <!-- Brand strip -->
  <div class="brand-strip">
    <span class="brand-name">AI-ASSISTED EARTH SYSTEM EXPLORER</span>
  </div>

</div>
</body>
</html>''';
  }

  // ─── XML / HTML escaping ──────────────────────────────────────────────────

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static String _escHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('\n', '<br/>');
}
