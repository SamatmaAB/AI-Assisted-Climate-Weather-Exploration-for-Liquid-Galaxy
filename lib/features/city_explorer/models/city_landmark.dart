class CityLandmark {
  final String city;
  final String landmark;
  final double latitude;
  final double longitude;
  final String climateContext;

  const CityLandmark({
    required this.city,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    required this.climateContext,
  });

  factory CityLandmark.fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num).toDouble();
    final lng = (json['longitude'] as num).toDouble();

    if (lat < -90 || lat > 90) {
      throw FormatException('Invalid latitude value: $lat');
    }
    if (lng < -180 || lng > 180) {
      throw FormatException('Invalid longitude value: $lng');
    }

    return CityLandmark(
      city: json['city']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
      climateContext: json['climate_context']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'city': city,
        'landmark': landmark,
        'latitude': latitude,
        'longitude': longitude,
        'climate_context': climateContext,
      };
}
