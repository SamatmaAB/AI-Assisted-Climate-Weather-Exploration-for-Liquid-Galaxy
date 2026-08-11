import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/models/phenomenon_card_data.dart';

/// Generates the complete KML document for a climate-phenomenon details card.
///
/// This is a **pure generator** — no SSH, no uploads, no side effects. It
/// produces a KML string ready to be written to `slave_N.kml` on the LG rig,
/// mirroring [CityExplorerBalloonKmlGenerator] but for climate phenomena.
///
/// The card renders via Google Earth's BalloonStyle mechanism:
///   KML BalloonStyle → HTML/CSS inside CDATA → Google Earth renders the card
class PhenomenonCardKmlGenerator {
  PhenomenonCardKmlGenerator._();

  /// Generates a complete KML document string.
  ///
  /// [phenomenon]   – the resolved climate phenomenon (provides id/name + coords).
  /// [data]         – Gemini-sourced card content.
  /// [targetLatitude] / [targetLongitude] – optional offset for screen center.
  static String generate({
    required ClimatePhenomenon phenomenon,
    required PhenomenonCardData data,
    double? targetLatitude,
    double? targetLongitude,
  }) {
    final coords = parseLookAt(phenomenon.lookAtXml);
    final lat = targetLatitude ?? coords['latitude']!;
    final lng = targetLongitude ?? coords['longitude']!;

    final html = _buildHtml(data: data);

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:gx="http://www.google.com/kml/ext/2.2">
<Document>
  <name>Phenomenon Card — ${_esc(data.name)}</name>

  <Style id="phenomenonCardStyle">
    <BalloonStyle>
      <bgColor>ff0f1410</bgColor>
      <textColor>ffffffff</textColor>
      <text><![CDATA[$html]]></text>
    </BalloonStyle>
    <IconStyle>
      <scale>1.0</scale>
      <Icon>
        <href>http://maps.google.com/mapfiles/kml/paddle/grn-circle.png</href>
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

  static String _buildHtml({required PhenomenonCardData data}) {
    final nameHtml = _esc(data.name);
    final categoryHtml = _esc(data.category);
    final regionHtml = _esc(data.region.toUpperCase());
    final summaryHtml = _escHtml(data.summary);
    final insightHtml = _escHtml(data.insight);

    final factsHtml = data.keyFacts.isEmpty
        ? ''
        : '''
  <div class="facts-section">
    <div class="section-label">Key Facts</div>
    <ul class="facts-list">
${data.keyFacts.map((f) => '      <li>${_escHtml(f)}</li>').join('\n')}
    </ul>
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
      rgba(18, 32, 28, 0.98) 0%,
      rgba(12, 22, 19, 0.98) 100%
    );
    border: 1px solid rgba(118, 214, 155, 0.22);
    border-radius: 20px;
    overflow: hidden;
    box-shadow:
      0 12px 40px rgba(0, 0, 0, 0.6),
      0 0 0 1px rgba(118, 214, 155, 0.08) inset;
  }

  /* ── Header ────────────────────────────────────────── */
  .header {
    padding: 22px 24px 16px;
    background: linear-gradient(
      180deg,
      rgba(0, 110, 80, 0.35) 0%,
      rgba(0, 60, 45, 0.15) 100%
    );
    border-bottom: 1px solid rgba(118, 214, 155, 0.15);
  }

  .category-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: linear-gradient(90deg, rgba(0, 100, 70, 0.65) 0%, rgba(0, 130, 95, 0.45) 100%);
    border: 1px solid rgba(118, 214, 155, 0.45);
    border-radius: 8px;
    padding: 6px 14px;
    margin-bottom: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3), 0 0 12px rgba(118, 214, 155, 0.15) inset;
  }

  .region-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #76D69B;
    box-shadow: 0 0 8px #76D69B;
    flex-shrink: 0;
  }

  .category-name {
    font-size: 14px;
    font-weight: 800;
    letter-spacing: 2.2px;
    color: #76D69B;
    text-transform: uppercase;
    line-height: 1;
  }

  .phenomenon-name {
    font-size: 22px;
    font-weight: 800;
    color: #FFFFFF;
    margin-top: 2px;
    line-height: 1.25;
    letter-spacing: -0.3px;
  }

  /* ── Summary hero ──────────────────────────────────── */
  .summary-section {
    padding: 18px 24px;
    border-bottom: 1px solid rgba(194, 199, 211, 0.08);
  }

  .region-tag {
    display: inline-block;
    font-size: 11.5px;
    font-weight: 700;
    color: #76D69B;
    background: rgba(118, 214, 155, 0.12);
    border: 1px solid rgba(118, 214, 155, 0.25);
    border-radius: 8px;
    padding: 4px 12px;
    letter-spacing: 0.8px;
    margin-bottom: 12px;
  }

  .summary-text {
    font-size: 14px;
    font-weight: 500;
    color: rgba(225, 226, 233, 0.92);
    line-height: 1.6;
  }

  /* ── Insight ───────────────────────────────────────── */
  .insight-section {
    padding: 14px 24px 20px;
  }

  .section-label {
    font-size: 9.5px;
    font-weight: 700;
    letter-spacing: 2px;
    color: rgba(118, 214, 155, 0.75);
    text-transform: uppercase;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .section-label::before {
    content: '';
    display: inline-block;
    width: 18px;
    height: 2px;
    background: linear-gradient(90deg, #76D69B, transparent);
    border-radius: 1px;
  }

  .insight-text {
    font-size: 13px;
    font-weight: 400;
    color: rgba(225, 226, 233, 0.88);
    line-height: 1.65;
  }

  /* ── Facts ────────────────────────────────────────── */
  .facts-section {
    padding: 0 24px 18px;
  }

  .facts-list {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .facts-list li {
    position: relative;
    padding-left: 18px;
    font-size: 12.5px;
    font-weight: 400;
    color: rgba(225, 226, 233, 0.85);
    line-height: 1.5;
  }

  .facts-list li::before {
    content: '';
    position: absolute;
    left: 0;
    top: 7px;
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: #76D69B;
    box-shadow: 0 0 6px #76D69B;
  }

  /* ── Footer brand strip ────────────────────────────── */
  .brand-strip {
    background: linear-gradient(
      90deg,
      rgba(0, 60, 45, 0.6) 0%,
      rgba(0, 100, 70, 0.3) 100%
    );
    padding: 10px 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-top: 1px solid rgba(118, 214, 155, 0.12);
  }

  .brand-name {
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 2.2px;
    color: rgba(118, 214, 155, 0.7);
    text-transform: uppercase;
  }
</style>
</head>
<body>
<div class="card">

  <!-- Header -->
  <div class="header">
    <div class="category-badge">
      <span class="region-dot"></span>
      <span class="category-name">$categoryHtml</span>
    </div>
    <div class="phenomenon-name">$nameHtml</div>
  </div>

  <!-- Summary hero -->
  <div class="summary-section">
    ${regionHtml.isNotEmpty ? '<div class="region-tag">$regionHtml</div>' : ''}
    <div class="summary-text">$summaryHtml</div>
  </div>

  <!-- Insight -->
  <div class="insight-section">
    <div class="section-label">AI Climate Insight</div>
    <div class="insight-text">$insightHtml</div>
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
