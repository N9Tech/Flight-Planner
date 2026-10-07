class Aircraft {
  String id;
  String type;
  String registration;
  String manufacturer;
  String model;
  int maxPassengers;
  int maxRange;
  double maxFuel;
  double emptyWeight;
  String engineType;
  int cruiseSpeed;
  int maxAltitude;

  Aircraft({
    required this.id,
    required this.type,
    required this.registration,
    required this.manufacturer,
    required this.model,
    this.maxPassengers = 0,
    this.maxRange = 0,
    this.maxFuel = 0.0,
    this.emptyWeight = 0.0,
    this.engineType = 'Jet',
    this.cruiseSpeed = 500,
    this.maxAltitude = 41000,
  });

  factory Aircraft.empty() {
    return Aircraft(
      id: '',
      type: '',
      registration: '',
      manufacturer: '',
      model: '',
    );
  }

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      registration: json['registration'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      model: json['model'] ?? '',
      maxPassengers: json['maxPassengers'] ?? 0,
      maxRange: json['maxRange'] ?? 0,
      maxFuel: (json['maxFuel'] ?? 0.0).toDouble(),
      emptyWeight: (json['emptyWeight'] ?? 0.0).toDouble(),
      engineType: json['engineType'] ?? 'Jet',
      cruiseSpeed: json['cruiseSpeed'] ?? 500,
      maxAltitude: json['maxAltitude'] ?? 41000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'registration': registration,
      'manufacturer': manufacturer,
      'model': model,
      'maxPassengers': maxPassengers,
      'maxRange': maxRange,
      'maxFuel': maxFuel,
      'emptyWeight': emptyWeight,
      'engineType': engineType,
      'cruiseSpeed': cruiseSpeed,
      'maxAltitude': maxAltitude,
    };
  }

  String get displayName => '$manufacturer $model ($registration)';
  String get shortName => '$type ($registration)';

  @override
  String toString() {
    return 'Aircraft{type: $type, registration: $registration, model: $model}';
  }
}
