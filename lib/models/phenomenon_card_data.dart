/// Gemini-sourced data for the climate-phenomenon details card.
///
/// Mirrors [CityLandmark]/[WeatherData] usage in the City Explorer balloon:
/// a single plain-data object produced by the AI layer and consumed by the
/// phenomenon card KML generator.
class PhenomenonCardData {
  final String name;
  final String category;
  final String region;
  final String summary;
  final String insight;
  final List<String> keyFacts;

  const PhenomenonCardData({
    required this.name,
    required this.category,
    required this.region,
    required this.summary,
    required this.insight,
    this.keyFacts = const [],
  });

  factory PhenomenonCardData.fromJson(Map<String, dynamic> json, String name) {
    final factsRaw = json['keyFacts'];
    final facts = factsRaw is List
        ? factsRaw
            .where((e) => e != null)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList()
        : <String>[];

    return PhenomenonCardData(
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : name,
      category: (json['category'] as String?)?.trim() ?? 'Climate Phenomenon',
      region: (json['region'] as String?)?.trim() ?? '',
      summary: (json['summary'] as String?)?.trim() ?? '',
      insight: (json['insight'] as String?)?.trim() ?? '',
      keyFacts: facts.take(3).toList(),
    );
  }
}
