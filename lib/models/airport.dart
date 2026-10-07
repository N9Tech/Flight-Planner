class Airport {
  String icao;
  String iata;
  String name;
  String city;
  String country;
  double latitude;
  double longitude;
  double elevation;
  String timezone;

  Airport({
    required this.icao,
    this.iata = '',
    required this.name,
    this.city = '',
    this.country = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.elevation = 0.0,
    this.timezone = 'UTC',
  });

  factory Airport.fromIcao(String icao) {
    return Airport(icao: icao, name: icao);
  }

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      icao: json['icao'] ?? '',
      iata: json['iata'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      elevation: (json['elevation'] ?? 0.0).toDouble(),
      timezone: json['timezone'] ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icao': icao,
      'iata': iata,
      'name': name,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'timezone': timezone,
    };
  }

  String get displayName => '$icao - $name ($city, $country)';
  String get shortName => '$icao - $name';

  @override
  String toString() {
    return 'Airport{icao: $icao, name: $name, city: $city}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Airport && other.icao == icao;
  }

  @override
  int get hashCode => icao.hashCode;
}
