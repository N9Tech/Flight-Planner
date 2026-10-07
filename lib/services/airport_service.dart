import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/airport.dart';

class AirportService {
  static const String _apiUrl = 'https://api.aviationstack.com/v1/airports';
  static const String _fallbackUrl = 'https://aviation-edge.com/v2/public/airportDatabase';

  Future<List<Airport>> searchAirports(String query) async {
    // Try to parse as ICAO/IATA code
    if (query.length == 3 || query.length == 4) {
      final airport = await getAirportByCode(query.toUpperCase());
      if (airport != null) {
        return [airport];
      }
    }

    // Search by name/city/country
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?access_key=YOUR_API_KEY&search=$query&limit=20'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['results'] != null) {
          return (json['results'] as List)
              .map((item) => Airport.fromJson({
                    'icao': item['icao_code'] ?? '',
                    'iata': item['iata_code'] ?? '',
                    'name': item['airport_name'] ?? '',
                    'city': item['city'] ?? '',
                    'country': item['country_name'] ?? '',
                    'latitude': item['latitude'] ?? 0.0,
                    'longitude': item['longitude'] ?? 0.0,
                    'elevation': item['elevation'] ?? 0.0,
                    'timezone': item['timezone'] ?? 'UTC',
                  }))
              .toList();
        }
      }
    } catch (e) {
      print('Error searching airports: $e');
    }

    // Fallback: return empty list
    return [];
  }

  Future<Airport?> getAirportByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?access_key=YOUR_API_KEY&iata_code=$code'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['results'] != null && json['results'].isNotEmpty) {
          final item = json['results'][0];
          return Airport.fromJson({
            'icao': item['icao_code'] ?? code,
            'iata': item['iata_code'] ?? code,
            'name': item['airport_name'] ?? '',
            'city': item['city'] ?? '',
            'country': item['country_name'] ?? '',
            'latitude': item['latitude'] ?? 0.0,
            'longitude': item['longitude'] ?? 0.0,
            'elevation': item['elevation'] ?? 0.0,
            'timezone': item['timezone'] ?? 'UTC',
          });
        }
      }
    } catch (e) {
      print('Error getting airport by code: $e');
    }

    return null;
  }

  Future<List<Airport>> getNearbyAirports(double lat, double lng, {int radius = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?access_key=YOUR_API_KEY&lat=$lat&lng=$lng&radius=$radius'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['results'] != null) {
          return (json['results'] as List)
              .map((item) => Airport.fromJson({
                    'icao': item['icao_code'] ?? '',
                    'iata': item['iata_code'] ?? '',
                    'name': item['airport_name'] ?? '',
                    'city': item['city'] ?? '',
                    'country': item['country_name'] ?? '',
                    'latitude': item['latitude'] ?? 0.0,
                    'longitude': item['longitude'] ?? 0.0,
                    'elevation': item['elevation'] ?? 0.0,
                    'timezone': item['timezone'] ?? 'UTC',
                  }))
              .toList();
        }
      }
    } catch (e) {
      print('Error getting nearby airports: $e');
    }

    return [];
  }

  // Static list of popular airports as fallback
  static final List<Airport> _popularAirports = [
    Airport(icao: 'KJFK', iata: 'JFK', name: 'John F Kennedy International', city: 'New York', country: 'United States', latitude: 40.6413, longitude: -73.7781, timezone: 'America/New_York'),
    Airport(icao: 'EGLL', iata: 'LHR', name: 'Heathrow', city: 'London', country: 'United Kingdom', latitude: 51.4706, longitude: -0.4619, timezone: 'Europe/London'),
    Airport(icao: 'LFPG', iata: 'CDG', name: 'Charles de Gaulle', city: 'Paris', country: 'France', latitude: 49.0097, longitude: 2.5478, timezone: 'Europe/Paris'),
    Airport(icao: 'EDDF', iata: 'FRA', name: 'Frankfurt am Main', city: 'Frankfurt', country: 'Germany', latitude: 50.0379, longitude: 8.5606, timezone: 'Europe/Berlin'),
    Airport(icao: 'EHAM', iata: 'AMS', name: 'Amsterdam Schiphol', city: 'Amsterdam', country: 'Netherlands', latitude: 52.3086, longitude: 4.7639, timezone: 'Europe/Amsterdam'),
    Airport(icao: 'ZBAA', iata: 'PEK', name: 'Beijing Capital International', city: 'Beijing', country: 'China', latitude: 40.0801, longitude: 116.5846, timezone: 'Asia/Shanghai'),
    Airport(icao: 'RJTT', iata: 'NRT', name: 'Narita International', city: 'Tokyo', country: 'Japan', latitude: 35.7645, longitude: 140.3860, timezone: 'Asia/Tokyo'),
    Airport(icao: 'OMDB', iata: 'DXB', name: 'Dubai International', city: 'Dubai', country: 'United Arab Emirates', latitude: 25.2528, longitude: 55.3644, timezone: 'Asia/Dubai'),
    Airport(icao: 'YSSY', iata: 'SYD', name: 'Sydney Kingsford Smith', city: 'Sydney', country: 'Australia', latitude: -33.9461, longitude: 151.1772, timezone: 'Australia/Sydney'),
    Airport(icao: 'SBGR', iata: 'GRU', name: 'Guarulhos Governador Andre Franco Montoro', city: 'Sao Paulo', country: 'Brazil', latitude: -23.4356, longitude: -46.4731, timezone: 'America/Sao_Paulo'),
    Airport(icao: 'KLAX', iata: 'LAX', name: 'Los Angeles International', city: 'Los Angeles', country: 'United States', latitude: 33.9416, longitude: -118.4085, timezone: 'America/Los_Angeles'),
    Airport(icao: 'KORD', iata: 'ORD', name: 'Chicago O Hare International', city: 'Chicago', country: 'United States', latitude: 41.9742, longitude: -87.9073, timezone: 'America/Chicago'),
    Airport(icao: 'CYVR', iata: 'YVR', name: 'Vancouver International', city: 'Vancouver', country: 'Canada', latitude: 49.1939, longitude: -123.1840, timezone: 'America/Vancouver'),
    Airport(icao: 'EIDW', iata: 'DUB', name: 'Dublin', city: 'Dublin', country: 'Ireland', latitude: 53.4213, longitude: -6.2701, timezone: 'Europe/Dublin'),
    Airport(icao: 'LEBL', iata: 'BCN', name: 'Barcelona El Prat', city: 'Barcelona', country: 'Spain', latitude: 41.2971, longitude: 2.0833, timezone: 'Europe/Madrid'),
    Airport(icao: 'FQRA', iata: 'RAK', name: 'Menara', city: 'Marrakech', country: 'Morocco', latitude: 31.6069, longitude: -8.0363, timezone: 'Africa/Casablanca'),
    Airport(icao: 'VHHH', iata: 'HKG', name: 'Chek Lap Kok', city: 'Hong Kong', country: 'Hong Kong', latitude: 22.3089, longitude: 113.9147, timezone: 'Asia/Hong_Kong'),
    Airport(icao: 'WSSS', iata: 'SIN', name: 'Changi', city: 'Singapore', country: 'Singapore', latitude: 1.3502, longitude: 103.9942, timezone: 'Asia/Singapore'),
    Airport(icao: 'VIDP', iata: 'DEL', name: 'Indira Gandhi International', city: 'Delhi', country: 'India', latitude: 28.5665, longitude: 77.1031, timezone: 'Asia/Kolkata'),
    Airport(icao: 'SAEZ', iata: 'EZE', name: 'Ministro Pistarini International', city: 'Buenos Aires', country: 'Argentina', latitude: -34.8222, longitude: -58.5358, timezone: 'America/Argentina/Buenos_Aires'),
    Airport(icao: 'FAJS', iata: 'JNB', name: 'OR Tambo International', city: 'Johannesburg', country: 'South Africa', latitude: -26.1392, longitude: 28.2460, timezone: 'Africa/Johannesburg'),
  ];

  Future<List<Airport>> getPopularAirports() async {
    return _popularAirports;
  }

  Future<Airport?> getPopularAirport(String code) async {
    final upperCode = code.toUpperCase();
    return _popularAirports.firstWhere(
      (a) => a.icao == upperCode || a.iata == upperCode,
      orElse: () => Airport.fromIcao(upperCode),
    );
  }
}
