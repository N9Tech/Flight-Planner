import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../models/aircraft.dart';
import '../models/airline.dart';
import '../services/flight_service.dart';
import '../services/airport_service.dart';
import '../services/simbrief_service.dart';
import '../widgets/airport_search_field.dart';
import '../widgets/aircraft_search_field.dart';
import '../widgets/airline_search_field.dart';

class AddFlightScreen extends StatefulWidget {
  final Flight? flight;

  const AddFlightScreen({super.key, this.flight});

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flightNumberController = TextEditingController();
  final _airlineController = TextEditingController();
  final _aircraftTypeController = TextEditingController();
  final _aircraftRegistrationController = TextEditingController();
  final _departureAirportController = TextEditingController();
  final _arrivalAirportController = TextEditingController();
  final _alternateAirportController = TextEditingController();
  final _routeController = TextEditingController();
  final _cruiseAltitudeController = TextEditingController();
  final _cruiseSpeedController = TextEditingController();
  final _fuelRequiredController = TextEditingController();
  final _payloadController = TextEditingController();

  DateTime _departureTime = DateTime.now();
  DateTime _arrivalTime = DateTime.now().add(const Duration(hours: 2));
  bool _isLoading = false;
  bool _isSyncedWithSimbrief = false;
  String? _simbriefId;

  @override
  void initState() {
    super.initState();
    if (widget.flight != null) {
      _loadFlightData(widget.flight!);
    } else {
      _departureTime = DateTime.now();
      _arrivalTime = DateTime.now().add(const Duration(hours: 2));
    }
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _airlineController.dispose();
    _aircraftTypeController.dispose();
    _aircraftRegistrationController.dispose();
    _departureAirportController.dispose();
    _arrivalAirportController.dispose();
    _alternateAirportController.dispose();
    _routeController.dispose();
    _cruiseAltitudeController.dispose();
    _cruiseSpeedController.dispose();
    _fuelRequiredController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  void _loadFlightData(Flight flight) {
    _flightNumberController.text = flight.flightNumber;
    _airlineController.text = flight.airline;
    _aircraftTypeController.text = flight.aircraftType;
    _aircraftRegistrationController.text = flight.aircraftRegistration;
    _departureAirportController.text = flight.departureAirport;
    _arrivalAirportController.text = flight.arrivalAirport;
    _alternateAirportController.text = flight.alternateAirport;
    _routeController.text = flight.route;
    _cruiseAltitudeController.text = flight.cruiseAltitude.toString();
    _cruiseSpeedController.text = flight.cruiseSpeed;
    _fuelRequiredController.text = flight.fuelRequired.toString();
    _payloadController.text = flight.payload.toString();
    _departureTime = flight.departureTime;
    _arrivalTime = flight.arrivalTime;
    _isSyncedWithSimbrief = flight.isSyncedWithSimbrief;
    _simbriefId = flight.simbriefId;
  }

  Future<void> _selectDateTime(BuildContext context, bool isDeparture) async {
    final initialDate = isDeparture ? _departureTime : _arrivalTime;
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isDeparture) {
            _departureTime = newDateTime;
            // Auto-update arrival time if it was before departure
            if (_arrivalTime.isBefore(_departureTime)) {
              _arrivalTime = _departureTime.add(const Duration(hours: 2));
            }
          } else {
            _arrivalTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveFlight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final flightService = Provider.of<FlightService>(context, listen: false);
      final simbriefService = Provider.of<SimBriefService>(context, listen: false);

      final flight = Flight(
        id: widget.flight?.id ?? '',
        flightNumber: _flightNumberController.text.trim(),
        airline: _airlineController.text.trim(),
        aircraftType: _aircraftTypeController.text.trim(),
        aircraftRegistration: _aircraftRegistrationController.text.trim(),
        departureAirport: _departureAirportController.text.trim().toUpperCase(),
        arrivalAirport: _arrivalAirportController.text.trim().toUpperCase(),
        alternateAirport: _alternateAirportController.text.trim().toUpperCase(),
        route: _routeController.text.trim(),
        cruiseAltitude: int.tryParse(_cruiseAltitudeController.text) ?? 35000,
        cruiseSpeed: _cruiseSpeedController.text.trim(),
        departureTime: _departureTime,
        arrivalTime: _arrivalTime,
        fuelRequired: double.tryParse(_fuelRequiredController.text) ?? 0.0,
        payload: double.tryParse(_payloadController.text) ?? 0.0,
        pilotId: await simbriefService.getPilotId() ?? '',
        simbriefId: _simbriefId ?? '',
        createdAt: widget.flight?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isSyncedWithSimbrief: _isSyncedWithSimbrief,
      );

      if (widget.flight == null) {
        await flightService.addFlight(flight);
      } else {
        await flightService.updateFlight(flight);
      }

      // Save airports to recent
      final airportService = AirportService();
      await airportService.getPopularAirport(flight.departureAirport);
      await airportService.getPopularAirport(flight.arrivalAirport);
      if (flight.alternateAirport.isNotEmpty) {
        await airportService.getPopularAirport(flight.alternateAirport);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flight ${widget.flight == null ? 'added' : 'updated'} successfully'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncWithSimBrief() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final simbriefService = Provider.of<SimBriefService>(context, listen: false);
      final flightService = Provider.of<FlightService>(context, listen: false);

      if (!await simbriefService.isLoggedIn()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to SimBrief first')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final flight = Flight(
        id: widget.flight?.id ?? '',
        flightNumber: _flightNumberController.text.trim(),
        airline: _airlineController.text.trim(),
        aircraftType: _aircraftTypeController.text.trim(),
        aircraftRegistration: _aircraftRegistrationController.text.trim(),
        departureAirport: _departureAirportController.text.trim().toUpperCase(),
        arrivalAirport: _arrivalAirportController.text.trim().toUpperCase(),
        alternateAirport: _alternateAirportController.text.trim().toUpperCase(),
        route: _routeController.text.trim(),
        cruiseAltitude: int.tryParse(_cruiseAltitudeController.text) ?? 35000,
        cruiseSpeed: _cruiseSpeedController.text.trim(),
        departureTime: _departureTime,
        arrivalTime: _arrivalTime,
        fuelRequired: double.tryParse(_fuelRequiredController.text) ?? 0.0,
        payload: double.tryParse(_payloadController.text) ?? 0.0,
        pilotId: await simbriefService.getPilotId() ?? '',
        simbriefId: _simbriefId ?? '',
        createdAt: widget.flight?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isSyncedWithSimbrief: true,
      );

      final result = await simbriefService.createFlightPlan(flight);

      if (result['success'] == true) {
        _simbriefId = result['ofp_id'];
        _isSyncedWithSimbrief = true;

        // Save the flight
        await flightService.addFlight(flight.copyWith(
          simbriefId: _simbriefId,
          isSyncedWithSimbrief: true,
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flight synced with SimBrief successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromSimBrief() async {
    setState(() => _isLoading = true);

    try {
      final simbriefService = Provider.of<SimBriefService>(context, listen: false);
      
      if (!await simbriefService.isLoggedIn()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to SimBrief first')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final latestPlan = await simbriefService.getLatestPlan();
      if (latestPlan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No flight plans found on SimBrief')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final flight = await simbriefService.importFromSimBrief(latestPlan.ofpId ?? '');
      if (flight == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to import flight plan')),
        );
        setState(() => _isLoading = false);
        return;
      }

      _loadFlightData(flight);
      _simbriefId = flight.simbriefId;
      _isSyncedWithSimbrief = flight.isSyncedWithSimbrief;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flight plan imported from SimBrief')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flight == null ? 'Add Flight' : 'Edit Flight'),
        actions: [
          if (_isSyncedWithSimbrief)
            IconButton(
              icon: const Icon(Icons.sync, color: Colors.green),
              onPressed: _syncWithSimBrief,
              tooltip: 'Synced with SimBrief',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFlight,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFlightInfoSection(),
                    const SizedBox(height: 20),
                    _buildRouteSection(),
                    const SizedBox(height: 20),
                    _buildAircraftSection(),
                    const SizedBox(height: 20),
                    _buildTimesSection(),
                    const SizedBox(height: 20),
                    _buildAdditionalInfoSection(),
                    const SizedBox(height: 20),
                    _buildSimBriefSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFlightInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Flight Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _flightNumberController,
              decoration: const InputDecoration(
                labelText: 'Flight Number',
                prefixIcon: Icon(Icons.airplanemode_active),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a flight number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AirlineSearchField(
              controller: _airlineController,
              decoration: const InputDecoration(
                labelText: 'Airline',
                prefixIcon: Icon(Icons.airline_seat_recline_normal),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AirportSearchField(
                    controller: _departureAirportController,
                    labelText: 'Departure',
                    prefixIcon: Icons.flight_takeoff,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AirportSearchField(
                    controller: _arrivalAirportController,
                    labelText: 'Arrival',
                    prefixIcon: Icons.flight_land,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AirportSearchField(
              controller: _alternateAirportController,
              labelText: 'Alternate Airport',
              prefixIcon: Icons.airport_shuttle,
              isOptional: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Route',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _routeController,
              decoration: const InputDecoration(
                labelText: 'Route (e.g., DCT N450W DCT)',
                prefixIcon: Icon(Icons.route),
                border: OutlineInputBorder(),
                hintText: 'Enter route points or leave empty for direct',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAircraftSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Aircraft',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AircraftSearchField(
              controller: _aircraftTypeController,
              decoration: const InputDecoration(
                labelText: 'Aircraft Type',
                prefixIcon: Icon(Icons.airplanemode_active),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _aircraftRegistrationController,
              decoration: const InputDecoration(
                labelText: 'Registration',
                prefixIcon: Icon(Icons.confirmation_number),
                border: OutlineInputBorder(),
                hintText: 'e.g., F-GZCP, N12345',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Flight Times',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Departure Time',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(_departureTime),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Arrival Time',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(_arrivalTime),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Duration: ${_calculateDuration()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cruiseAltitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Cruise Altitude (ft)',
                      prefixIcon: Icon(Icons.alt_route),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final alt = int.tryParse(value);
                        if (alt == null) {
                          return 'Please enter a valid altitude';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cruiseSpeedController,
                    decoration: const InputDecoration(
                      labelText: 'Cruise Speed',
                      prefixIcon: Icon(Icons.speed),
                      border: OutlineInputBorder(),
                      hintText: 'e.g., M0.82, 280',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fuelRequiredController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Required (kg)',
                      prefixIcon: Icon(Icons.local_gas_station),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _payloadController,
                    decoration: const InputDecoration(
                      labelText: 'Payload (kg)',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimBriefSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'SimBrief Integration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isSyncedWithSimbrief)
                  Icon(Icons.check_circle, color: Colors.green)
                else
                  Icon(Icons.radio_button_unchecked, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            if (_simbriefId != null && _simbriefId!.isNotEmpty)
              Text(
                'SimBrief OFP ID: $_simbriefId',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Import from SimBrief'),
                    onPressed: _importFromSimBrief,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Sync to SimBrief'),
                    onPressed: _syncWithSimBrief,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Flight'),
            onPressed: _saveFlight,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _calculateDuration() {
    final duration = _arrivalTime.difference(_departureTime);
    if (duration.isNegative) {
      return 'Invalid (arrival before departure)';
    }
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
