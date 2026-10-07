class SimBriefResponse {
  final String? filename;
  final String? ofpId;
  final String? userId;
  final String? pilotId;
  final String? flightNumber;
  final String? airline;
  final String? aircraftType;
  final String? aircraftRegistration;
  final String? departureAirport;
  final String? arrivalAirport;
  final String? alternateAirport;
  final String? route;
  final String? cruiseAltitude;
  final String? cruiseSpeed;
  final String? departureTime;
  final String? arrivalTime;
  final String? flightTime;
  final String? fuelRequired;
  final String? payload;
  final String? weather;
  final String? notam;
  final String? remarks;
  final String? ofpText;
  final String? navlog;
  final Map<String, dynamic>? params;

  SimBriefResponse({
    this.filename,
    this.ofpId,
    this.userId,
    this.pilotId,
    this.flightNumber,
    this.airline,
    this.aircraftType,
    this.aircraftRegistration,
    this.departureAirport,
    this.arrivalAirport,
    this.alternateAirport,
    this.route,
    this.cruiseAltitude,
    this.cruiseSpeed,
    this.departureTime,
    this.arrivalTime,
    this.flightTime,
    this.fuelRequired,
    this.payload,
    this.weather,
    this.notam,
    this.remarks,
    this.ofpText,
    this.navlog,
    this.params,
  });

  factory SimBriefResponse.fromJson(Map<String, dynamic> json) {
    return SimBriefResponse(
      filename: json['filename'],
      ofpId: json['ofp_id'] ?? json['id'],
      userId: json['user_id'] ?? json['username'],
      pilotId: json['pilot_id'],
      flightNumber: json['flight_number'] ?? json['flightnum'],
      airline: json['airline'],
      aircraftType: json['aircraft'] ?? json['aircraft_type'],
      aircraftRegistration: json['reg'] ?? json['registration'],
      departureAirport: json['origin'] ?? json['dep'],
      arrivalAirport: json['destination'] ?? json['arr'],
      alternateAirport: json['alternate'],
      route: json['route'],
      cruiseAltitude: json['cruise_altitude'] ?? json['altitude'],
      cruiseSpeed: json['cruise_speed'] ?? json['speed'],
      departureTime: json['departure_time'] ?? json['dep_time'],
      arrivalTime: json['arrival_time'] ?? json['arr_time'],
      flightTime: json['flight_time'] ?? json['duration'],
      fuelRequired: json['fuel_required'] ?? json['fuel'],
      payload: json['payload'],
      weather: json['weather'],
      notam: json['notam'],
      remarks: json['remarks'],
      ofpText: json['ofp_text'] ?? json['text'],
      navlog: json['navlog'],
      params: json['params'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (filename != null) data['filename'] = filename;
    if (ofpId != null) data['ofp_id'] = ofpId;
    if (userId != null) data['user_id'] = userId;
    if (pilotId != null) data['pilot_id'] = pilotId;
    if (flightNumber != null) data['flight_number'] = flightNumber;
    if (airline != null) data['airline'] = airline;
    if (aircraftType != null) data['aircraft'] = aircraftType;
    if (aircraftRegistration != null) data['reg'] = aircraftRegistration;
    if (departureAirport != null) data['origin'] = departureAirport;
    if (arrivalAirport != null) data['destination'] = arrivalAirport;
    if (alternateAirport != null) data['alternate'] = alternateAirport;
    if (route != null) data['route'] = route;
    if (cruiseAltitude != null) data['cruise_altitude'] = cruiseAltitude;
    if (cruiseSpeed != null) data['cruise_speed'] = cruiseSpeed;
    if (departureTime != null) data['departure_time'] = departureTime;
    if (arrivalTime != null) data['arrival_time'] = arrivalTime;
    if (flightTime != null) data['flight_time'] = flightTime;
    if (fuelRequired != null) data['fuel_required'] = fuelRequired;
    if (payload != null) data['payload'] = payload;
    if (weather != null) data['weather'] = weather;
    if (notam != null) data['notam'] = notam;
    if (remarks != null) data['remarks'] = remarks;
    if (ofpText != null) data['ofp_text'] = ofpText;
    if (navlog != null) data['navlog'] = navlog;
    if (params != null) data['params'] = params;
    return data;
  }

  bool get isValid => ofpId != null && ofpId!.isNotEmpty;

  @override
  String toString() {
    return 'SimBriefResponse{ofpId: $ofpId, flightNumber: $flightNumber, pilotId: $pilotId}';
  }
}

class SimBriefPlan {
  final String? id;
  final String? userId;
  final String? pilotId;
  final Map<String, dynamic>? params;

  SimBriefPlan({this.id, this.userId, this.pilotId, this.params});

  factory SimBriefPlan.fromJson(Map<String, dynamic> json) {
    return SimBriefPlan(
      id: json['id'] ?? json['ofp_id'],
      userId: json['user_id'] ?? json['username'],
      pilotId: json['pilot_id'],
      params: json['params'],
    );
  }
}
