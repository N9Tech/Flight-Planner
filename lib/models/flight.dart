import 'package:flutter/foundation.dart';

class Flight {
  String id;
  String flightNumber;
  String airline;
  String aircraftType;
  String aircraftRegistration;
  String departureAirport;
  String arrivalAirport;
  DateTime departureTime;
  DateTime arrivalTime;
  String alternateAirport;
  int cruiseAltitude;
  String cruiseSpeed;
  String route;
  double fuelRequired;
  double payload;
  String pilotId;
  String simbriefId;
  DateTime createdAt;
  DateTime? updatedAt;
  bool isSyncedWithSimbrief;

  Flight({
    required this.id,
    required this.flightNumber,
    required this.airline,
    required this.aircraftType,
    required this.aircraftRegistration,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    this.alternateAirport = '',
    this.cruiseAltitude = 35000,
    this.cruiseSpeed = 'M0.82',
    this.route = '',
    this.fuelRequired = 0.0,
    this.payload = 0.0,
    required this.pilotId,
    this.simbriefId = '',
    required this.createdAt,
    this.updatedAt,
    this.isSyncedWithSimbrief = false,
  });

  factory Flight.empty() {
    return Flight(
      id: '',
      flightNumber: '',
      airline: '',
      aircraftType: '',
      aircraftRegistration: '',
      departureAirport: '',
      arrivalAirport: '',
      departureTime: DateTime.now(),
      arrivalTime: DateTime.now().add(const Duration(hours: 2)),
      pilotId: '',
      createdAt: DateTime.now(),
    );
  }

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] ?? '',
      flightNumber: json['flightNumber'] ?? '',
      airline: json['airline'] ?? '',
      aircraftType: json['aircraftType'] ?? '',
      aircraftRegistration: json['aircraftRegistration'] ?? '',
      departureAirport: json['departureAirport'] ?? '',
      arrivalAirport: json['arrivalAirport'] ?? '',
      departureTime: DateTime.parse(json['departureTime'] ?? DateTime.now().toIso8601String()),
      arrivalTime: DateTime.parse(json['arrivalTime'] ?? DateTime.now().add(const Duration(hours: 2)).toIso8601String()),
      alternateAirport: json['alternateAirport'] ?? '',
      cruiseAltitude: json['cruiseAltitude'] ?? 35000,
      cruiseSpeed: json['cruiseSpeed'] ?? 'M0.82',
      route: json['route'] ?? '',
      fuelRequired: (json['fuelRequired'] ?? 0.0).toDouble(),
      payload: (json['payload'] ?? 0.0).toDouble(),
      pilotId: json['pilotId'] ?? '',
      simbriefId: json['simbriefId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isSyncedWithSimbrief: json['isSyncedWithSimbrief'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flightNumber': flightNumber,
      'airline': airline,
      'aircraftType': aircraftType,
      'aircraftRegistration': aircraftRegistration,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'alternateAirport': alternateAirport,
      'cruiseAltitude': cruiseAltitude,
      'cruiseSpeed': cruiseSpeed,
      'route': route,
      'fuelRequired': fuelRequired,
      'payload': payload,
      'pilotId': pilotId,
      'simbriefId': simbriefId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSyncedWithSimbrief': isSyncedWithSimbrief,
    };
  }

  Flight copyWith({
    String? id,
    String? flightNumber,
    String? airline,
    String? aircraftType,
    String? aircraftRegistration,
    String? departureAirport,
    String? arrivalAirport,
    DateTime? departureTime,
    DateTime? arrivalTime,
    String? alternateAirport,
    int? cruiseAltitude,
    String? cruiseSpeed,
    String? route,
    double? fuelRequired,
    double? payload,
    String? pilotId,
    String? simbriefId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSyncedWithSimbrief,
  }) {
    return Flight(
      id: id ?? this.id,
      flightNumber: flightNumber ?? this.flightNumber,
      airline: airline ?? this.airline,
      aircraftType: aircraftType ?? this.aircraftType,
      aircraftRegistration: aircraftRegistration ?? this.aircraftRegistration,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      alternateAirport: alternateAirport ?? this.alternateAirport,
      cruiseAltitude: cruiseAltitude ?? this.cruiseAltitude,
      cruiseSpeed: cruiseSpeed ?? this.cruiseSpeed,
      route: route ?? this.route,
      fuelRequired: fuelRequired ?? this.fuelRequired,
      payload: payload ?? this.payload,
      pilotId: pilotId ?? this.pilotId,
      simbriefId: simbriefId ?? this.simbriefId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSyncedWithSimbrief: isSyncedWithSimbrief ?? this.isSyncedWithSimbrief,
    );
  }

  String get flightInfo => '$flightNumber - $airline';
  String get routeInfo => '$departureAirport -> $arrivalAirport';
  String get timeInfo => '${departureTime.toString().substring(0, 16)} to ${arrivalTime.toString().substring(11, 16)}';

  @override
  String toString() {
    return 'Flight{id: $id, flightNumber: $flightNumber, airline: $airline, aircraft: $aircraftType $aircraftRegistration, route: $departureAirport->$arrivalAirport}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Flight && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
