class Airline {
  String id;
  String name;
  String icaoCode;
  String iataCode;
  String callsign;
  String country;
  String logoUrl;

  Airline({
    required this.id,
    required this.name,
    this.icaoCode = '',
    this.iataCode = '',
    this.callsign = '',
    this.country = '',
    this.logoUrl = '',
  });

  factory Airline.empty() {
    return Airline(
      id: '',
      name: '',
    );
  }

  factory Airline.fromJson(Map<String, dynamic> json) {
    return Airline(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icaoCode: json['icaoCode'] ?? '',
      iataCode: json['iataCode'] ?? '',
      callsign: json['callsign'] ?? '',
      country: json['country'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icaoCode': icaoCode,
      'iataCode': iataCode,
      'callsign': callsign,
      'country': country,
      'logoUrl': logoUrl,
    };
  }

  String get displayName => '$name ($iataCode/$icaoCode)';

  @override
  String toString() {
    return 'Airline{name: $name, icao: $icaoCode, iata: $iataCode}';
  }
}
