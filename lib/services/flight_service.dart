import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/flight.dart';
import '../models/aircraft.dart';
import '../models/airline.dart';
import '../models/airport.dart';

class FlightService with ChangeNotifier {
  static const String _flightsKey = 'flights';
  static const String _aircraftsKey = 'aircrafts';
  static const String _airlinesKey = 'airlines';
  static const String _recentAirportsKey = 'recent_airports';

  List<Flight> _flights = [];
  List<Aircraft> _aircrafts = [];
  List<Airline> _airlines = [];
  List<Airport> _recentAirports = [];

  List<Flight> get flights => _flights;
  List<Aircraft> get aircrafts => _aircrafts;
  List<Airline> get airlines => _airlines;
  List<Airport> get recentAirports => _recentAirports;

  FlightService() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load flights
    final flightsJson = prefs.getStringList(_flightsKey) ?? [];
    _flights = flightsJson.map((json) => Flight.fromJson(jsonDecode(json))).toList();
    
    // Load aircrafts
    final aircraftsJson = prefs.getStringList(_aircraftsKey) ?? [];
    _aircrafts = aircraftsJson.map((json) => Aircraft.fromJson(jsonDecode(json))).toList();
    
    // Load airlines
    final airlinesJson = prefs.getStringList(_airlinesKey) ?? [];
    _airlines = airlinesJson.map((json) => Airline.fromJson(jsonDecode(json))).toList();
    
    // Load recent airports
    final airportsJson = prefs.getStringList(_recentAirportsKey) ?? [];
    _recentAirports = airportsJson.map((json) => Airport.fromJson(jsonDecode(json))).toList();
    
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setStringList(
      _flightsKey,
      _flights.map((flight) => jsonEncode(flight.toJson())).toList(),
    );
    
    await prefs.setStringList(
      _aircraftsKey,
      _aircrafts.map((aircraft) => jsonEncode(aircraft.toJson())).toList(),
    );
    
    await prefs.setStringList(
      _airlinesKey,
      _airlines.map((airline) => jsonEncode(airline.toJson())).toList(),
    );
    
    await prefs.setStringList(
      _recentAirportsKey,
      _recentAirports.map((airport) => jsonEncode(airport.toJson())).toList(),
    );
  }

  // ============ FLIGHTS ============

  Future<void> addFlight(Flight flight) async {
    flight = flight.copyWith(
      id: flight.id.isEmpty ? const Uuid().v4() : flight.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _flights.add(flight);
    await saveData();
    notifyListeners();
  }

  Future<void> updateFlight(Flight flight) async {
    final index = _flights.indexWhere((f) => f.id == flight.id);
    if (index >= 0) {
      _flights[index] = flight.copyWith(
        updatedAt: DateTime.now(),
      );
      await saveData();
      notifyListeners();
    }
  }

  Future<void> deleteFlight(String flightId) async {
    _flights.removeWhere((f) => f.id == flightId);
    await saveData();
    notifyListeners();
  }

  Flight? getFlight(String flightId) {
    return _flights.firstWhere((f) => f.id == flightId);
  }

  // ============ AIRCRAFTS ============

  Future<void> addAircraft(Aircraft aircraft) async {
    aircraft = aircraft.copyWith(
      id: aircraft.id.isEmpty ? const Uuid().v4() : aircraft.id,
    );
    _aircrafts.add(aircraft);
    await saveData();
    notifyListeners();
  }

  Future<void> updateAircraft(Aircraft aircraft) async {
    final index = _aircrafts.indexWhere((a) => a.id == aircraft.id);
    if (index >= 0) {
      _aircrafts[index] = aircraft;
      await saveData();
      notifyListeners();
    }
  }

  Future<void> deleteAircraft(String aircraftId) async {
    _aircrafts.removeWhere((a) => a.id == aircraftId);
    await saveData();
    notifyListeners();
  }

  Aircraft? getAircraft(String aircraftId) {
    return _aircrafts.firstWhere((a) => a.id == aircraftId);
  }

  // ============ AIRLINES ============

  Future<void> addAirline(Airline airline) async {
    airline = airline.copyWith(
      id: airline.id.isEmpty ? const Uuid().v4() : airline.id,
    );
    _airlines.add(airline);
    await saveData();
    notifyListeners();
  }

  Future<void> updateAirline(Airline airline) async {
    final index = _airlines.indexWhere((a) => a.id == airline.id);
    if (index >= 0) {
      _airlines[index] = airline;
      await saveData();
      notifyListeners();
    }
  }

  Future<void> deleteAirline(String airlineId) async {
    _airlines.removeWhere((a) => a.id == airlineId);
    await saveData();
    notifyListeners();
  }

  Airline? getAirline(String airlineId) {
    return _airlines.firstWhere((a) => a.id == airlineId);
  }

  // ============ AIRPORTS ============

  Future<void> addRecentAirport(Airport airport) async {
    // Remove if already exists
    _recentAirports.removeWhere((a) => a.icao == airport.icao);
    // Add to beginning
    _recentAirports.insert(0, airport);
    // Keep only last 20
    if (_recentAirports.length > 20) {
      _recentAirports = _recentAirports.sublist(0, 20);
    }
    await saveData();
    notifyListeners();
  }

  Future<void> removeRecentAirport(String icao) async {
    _recentAirports.removeWhere((a) => a.icao == icao);
    await saveData();
    notifyListeners();
  }

  Airport? getAirport(String icao) {
    return _recentAirports.firstWhere(
      (a) => a.icao == icao,
      orElse: () => Airport.fromIcao(icao),
    );
  }

  // ============ UTILITIES ============

  List<Flight> getUpcomingFlights() {
    return _flights
        .where((f) => f.departureTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
  }

  List<Flight> getPastFlights() {
    return _flights
        .where((f) => f.departureTime.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));
  }

  List<Flight> searchFlights(String query) {
    final lowerQuery = query.toLowerCase();
    return _flights.where((f) {
      return f.flightNumber.toLowerCase().contains(lowerQuery) ||
          f.airline.toLowerCase().contains(lowerQuery) ||
          f.departureAirport.toLowerCase().contains(lowerQuery) ||
          f.arrivalAirport.toLowerCase().contains(lowerQuery) ||
          f.aircraftType.toLowerCase().contains(lowerQuery) ||
          f.aircraftRegistration.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Aircraft> searchAircrafts(String query) {
    final lowerQuery = query.toLowerCase();
    return _aircrafts.where((a) {
      return a.type.toLowerCase().contains(lowerQuery) ||
          a.registration.toLowerCase().contains(lowerQuery) ||
          a.manufacturer.toLowerCase().contains(lowerQuery) ||
          a.model.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Airline> searchAirlines(String query) {
    final lowerQuery = query.toLowerCase();
    return _airlines.where((a) {
      return a.name.toLowerCase().contains(lowerQuery) ||
          a.icaoCode.toLowerCase().contains(lowerQuery) ||
          a.iataCode.toLowerCase().contains(lowerQuery) ||
          a.callsign.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Airport> searchAirports(String query) {
    final lowerQuery = query.toLowerCase();
    return _recentAirports.where((a) {
      return a.icao.toLowerCase().contains(lowerQuery) ||
          a.iata.toLowerCase().contains(lowerQuery) ||
          a.name.toLowerCase().contains(lowerQuery) ||
          a.city.toLowerCase().contains(lowerQuery) ||
          a.country.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

// Extension for Aircraft to make it immutable
extension AircraftExtensions on Aircraft {
  Aircraft copyWith({
    String? id,
    String? type,
    String? registration,
    String? manufacturer,
    String? model,
    int? maxPassengers,
    int? maxRange,
    double? maxFuel,
    double? emptyWeight,
    String? engineType,
    int? cruiseSpeed,
    int? maxAltitude,
  }) {
    return Aircraft(
      id: id ?? this.id,
      type: type ?? this.type,
      registration: registration ?? this.registration,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      maxPassengers: maxPassengers ?? this.maxPassengers,
      maxRange: maxRange ?? this.maxRange,
      maxFuel: maxFuel ?? this.maxFuel,
      emptyWeight: emptyWeight ?? this.emptyWeight,
      engineType: engineType ?? this.engineType,
      cruiseSpeed: cruiseSpeed ?? this.cruiseSpeed,
      maxAltitude: maxAltitude ?? this.maxAltitude,
    );
  }
}

// Extension for Airline to make it immutable
extension AirlineExtensions on Airline {
  Airline copyWith({
    String? id,
    String? name,
    String? icaoCode,
    String? iataCode,
    String? callsign,
    String? country,
    String? logoUrl,
  }) {
    return Airline(
      id: id ?? this.id,
      name: name ?? this.name,
      icaoCode: icaoCode ?? this.icaoCode,
      iataCode: iataCode ?? this.iataCode,
      callsign: callsign ?? this.callsign,
      country: country ?? this.country,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
