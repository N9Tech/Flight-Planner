import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/simbrief_response.dart';
import '../models/flight.dart';

class SimBriefService {
  static const String _baseUrl = 'https://www.simbrief.com/api';
  static const String _preferencesKey = 'simbrief_pilot_id';
  static const String _usernameKey = 'simbrief_username';

  String? _pilotId;
  String? _username;

  Future<String?> getPilotId() async {
    if (_pilotId != null) return _pilotId;
    final prefs = await SharedPreferences.getInstance();
    _pilotId = prefs.getString(_preferencesKey);
    return _pilotId;
  }

  Future<void> setPilotId(String pilotId) async {
    _pilotId = pilotId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, pilotId);
  }

  Future<String?> getUsername() async {
    if (_username != null) return _username;
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(_usernameKey);
    return _username;
  }

  Future<void> setUsername(String username) async {
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<bool> isLoggedIn() async {
    final pilotId = await getPilotId();
    return pilotId != null && pilotId.isNotEmpty;
  }

  Future<void> logout() async {
    _pilotId = null;
    _username = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferencesKey);
    await prefs.remove(_usernameKey);
  }

  // Login to SimBrief using username/password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login.php'),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          await setUsername(username);
          await setPilotId(json['pilot_id']?.toString() ?? username);
          return {'success': true, 'message': 'Login successful', 'pilot_id': json['pilot_id']};
        } else {
          return {'success': false, 'message': json['error'] ?? 'Login failed'};
        }
      } else {
        return {'success': false, 'message': 'Failed to connect to SimBrief. Status: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get user's saved flight plans from SimBrief
  Future<List<SimBriefPlan>> getUserPlans() async {
    final pilotId = await getPilotId();
    if (pilotId == null || pilotId.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/plan.get.php?pilot_id=$pilotId'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List) {
          return json.map((item) => SimBriefPlan.fromJson(item)).toList();
        } else if (json['plans'] is List) {
          return (json['plans'] as List).map((item) => SimBriefPlan.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching user plans: $e');
      return [];
    }
  }

  // Get a specific flight plan from SimBrief
  Future<SimBriefResponse?> getFlightPlan(String ofpId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/plan.fetch.php?ofp_id=$ofpId'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SimBriefResponse.fromJson(json);
      }
      return null;
    } catch (e) {
      print('Error fetching flight plan: $e');
      return null;
    }
  }

  // Get latest flight plan for a pilot
  Future<SimBriefResponse?> getLatestPlan() async {
    final pilotId = await getPilotId();
    if (pilotId == null || pilotId.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/plan.latest.php?pilot_id=$pilotId'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SimBriefResponse.fromJson(json);
      }
      return null;
    } catch (e) {
      print('Error fetching latest plan: $e');
      return null;
    }
  }

  // Create a new flight plan on SimBrief
  Future<Map<String, dynamic>> createFlightPlan(Flight flight) async {
    final pilotId = await getPilotId();
    if (pilotId == null || pilotId.isEmpty) {
      return {'success': false, 'message': 'Not logged in to SimBrief'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/plan.create.php'),
        body: {
          'pilot_id': pilotId,
          'flight_number': flight.flightNumber,
          'airline': flight.airline,
          'aircraft': flight.aircraftType,
          'reg': flight.aircraftRegistration,
          'origin': flight.departureAirport,
          'destination': flight.arrivalAirport,
          'alternate': flight.alternateAirport,
          'route': flight.route,
          'cruise_altitude': flight.cruiseAltitude.toString(),
          'cruise_speed': flight.cruiseSpeed,
          'dep_time': flight.departureTime.toIso8601String(),
          'arr_time': flight.arrivalTime.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return {
            'success': true,
            'message': 'Flight plan created',
            'ofp_id': json['ofp_id'],
          };
        } else {
          return {'success': false, 'message': json['error'] ?? 'Failed to create plan'};
        }
      } else {
        return {'success': false, 'message': 'Failed to connect. Status: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Import flight plan from SimBrief to local
  Future<Flight?> importFromSimBrief(String ofpId) async {
    final plan = await getFlightPlan(ofpId);
    if (plan == null) return null;

    return Flight(
      id: plan.ofpId ?? '',
      flightNumber: plan.flightNumber ?? '',
      airline: plan.airline ?? '',
      aircraftType: plan.aircraftType ?? '',
      aircraftRegistration: plan.aircraftRegistration ?? '',
      departureAirport: plan.departureAirport ?? '',
      arrivalAirport: plan.arrivalAirport ?? '',
      alternateAirport: plan.alternateAirport ?? '',
      cruiseAltitude: int.tryParse(plan.cruiseAltitude ?? '35000') ?? 35000,
      cruiseSpeed: plan.cruiseSpeed ?? 'M0.82',
      route: plan.route ?? '',
      departureTime: DateTime.tryParse(plan.departureTime ?? '') ?? DateTime.now(),
      arrivalTime: DateTime.tryParse(plan.arrivalTime ?? '') ?? DateTime.now().add(const Duration(hours: 2)),
      fuelRequired: double.tryParse(plan.fuelRequired?.replaceAll(',', '') ?? '0') ?? 0.0,
      payload: double.tryParse(plan.payload?.replaceAll(',', '') ?? '0') ?? 0.0,
      pilotId: plan.pilotId ?? '',
      simbriefId: plan.ofpId ?? '',
      createdAt: DateTime.now(),
      isSyncedWithSimbrief: true,
    );
  }

  // Sync local flight to SimBrief
  Future<Map<String, dynamic>> syncToSimBrief(Flight flight) async {
    final pilotId = await getPilotId();
    if (pilotId == null || pilotId.isEmpty) {
      return {'success': false, 'message': 'Not logged in to SimBrief'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/plan.update.php'),
        body: {
          'pilot_id': pilotId,
          'ofp_id': flight.simbriefId.isNotEmpty ? flight.simbriefId : flight.id,
          'flight_number': flight.flightNumber,
          'airline': flight.airline,
          'aircraft': flight.aircraftType,
          'reg': flight.aircraftRegistration,
          'origin': flight.departureAirport,
          'destination': flight.arrivalAirport,
          'alternate': flight.alternateAirport,
          'route': flight.route,
          'cruise_altitude': flight.cruiseAltitude.toString(),
          'cruise_speed': flight.cruiseSpeed,
          'dep_time': flight.departureTime.toIso8601String(),
          'arr_time': flight.arrivalTime.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return {
            'success': true,
            'message': 'Flight plan synced',
            'ofp_id': json['ofp_id'],
          };
        } else {
          return {'success': false, 'message': json['error'] ?? 'Failed to sync plan'};
        }
      } else {
        return {'success': false, 'message': 'Failed to connect. Status: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Delete a flight plan from SimBrief
  Future<Map<String, dynamic>> deleteFlightPlan(String ofpId) async {
    final pilotId = await getPilotId();
    if (pilotId == null || pilotId.isEmpty) {
      return {'success': false, 'message': 'Not logged in to SimBrief'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/plan.delete.php'),
        body: {
          'pilot_id': pilotId,
          'ofp_id': ofpId,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return {'success': true, 'message': 'Flight plan deleted'};
        } else {
          return {'success': false, 'message': json['error'] ?? 'Failed to delete plan'};
        }
      } else {
        return {'success': false, 'message': 'Failed to connect. Status: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get OFP text for a plan
  Future<String?> getOFPText(String ofpId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ofp.text.php?ofp_id=$ofpId'),
      );

      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      print('Error fetching OFP text: $e');
      return null;
    }
  }

  // Get NavLog for a plan
  Future<String?> getNavLog(String ofpId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/navlog.php?ofp_id=$ofpId'),
      );

      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      print('Error fetching NavLog: $e');
      return null;
    }
  }
}
