import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/simbrief_response.dart';
import '../services/simbrief_service.dart';
import '../services/flight_service.dart';
import 'add_flight_screen.dart';
import 'simbrief_login_screen.dart';
import '../widgets/flight_plan_card.dart';

class SimBriefPlansScreen extends StatefulWidget {
  const SimBriefPlansScreen({super.key});

  @override
  State<SimBriefPlansScreen> createState() => _SimBriefPlansScreenState();
}

class _SimBriefPlansScreenState extends State<SimBriefPlansScreen> {
  bool _isLoading = true;
  List<SimBriefPlan> _plans = [];
  SimBriefResponse? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);

    try {
      final simbriefService = Provider.of<SimBriefService>(context, listen: false);
      final plans = await simbriefService.getUserPlans();
      setState(() => _plans = plans);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading plans: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPlans() async {
    await _loadPlans();
  }

  Future<void> _importPlan(String ofpId) async {
    setState(() => _isLoading = true);

    try {
      final simbriefService = Provider.of<SimBriefService>(context, listen: false);
      final flightService = Provider.of<FlightService>(context, listen: false);

      final flight = await simbriefService.importFromSimBrief(ofpId);
      if (flight != null) {
        await flightService.addFlight(flight);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flight plan imported successfully')),
        );

        // Navigate to edit the imported flight
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddFlightScreen(flight: flight),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to import flight plan')),
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

  Future<void> _deletePlan(String ofpId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flight Plan'),
        content: const Text('Are you sure you want to delete this flight plan from SimBrief?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        final simbriefService = Provider.of<SimBriefService>(context, listen: false);
        final result = await simbriefService.deleteFlightPlan(ofpId);

        if (result['success'] == true) {
          await _loadPlans();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Flight plan deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${result['message']}')),
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
  }

  Future<void> _viewPlanDetails(String ofpId) async {
    setState(() => _isLoading = true);

    try {
      final simbriefService = Provider.of<SimBriefService>(context, listen: false);
      final plan = await simbriefService.getFlightPlan(ofpId);

      if (plan != null) {
        setState(() => _selectedPlan = plan);
        showDialog(
          context: context,
          builder: (context) => _buildPlanDetailsDialog(plan),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load plan details')),
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

  Widget _buildPlanDetailsDialog(SimBriefResponse plan) {
    return AlertDialog(
      title: const Text('Flight Plan Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Flight Number', plan.flightNumber ?? 'N/A'),
            _buildDetailRow('Airline', plan.airline ?? 'N/A'),
            _buildDetailRow('Aircraft', plan.aircraftType ?? 'N/A'),
            _buildDetailRow('Registration', plan.aircraftRegistration ?? 'N/A'),
            _buildDetailRow('Route', plan.departureAirport ?? 'N/A' + ' -> ' + (plan.arrivalAirport ?? 'N/A')),
            _buildDetailRow('Alternate', plan.alternateAirport ?? 'None'),
            _buildDetailRow('Cruise Altitude', plan.cruiseAltitude ?? 'N/A'),
            _buildDetailRow('Cruise Speed', plan.cruiseSpeed ?? 'N/A'),
            _buildDetailRow('Departure Time', plan.departureTime ?? 'N/A'),
            _buildDetailRow('Arrival Time', plan.arrivalTime ?? 'N/A'),
            _buildDetailRow('Flight Time', plan.flightTime ?? 'N/A'),
            _buildDetailRow('Fuel Required', plan.fuelRequired ?? 'N/A'),
            _buildDetailRow('Payload', plan.payload ?? 'N/A'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final simbriefService = Provider.of<SimBriefService>(context, listen: false);
    await simbriefService.logout();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SimBriefLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simbriefService = Provider.of<SimBriefService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SimBrief Flight Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPlans,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _plans.length,
                  itemBuilder: (context, index) {
                    final plan = _plans[index];
                    return FlightPlanCard(
                      plan: plan,
                      onImport: () => _importPlan(plan.id ?? ''),
                      onView: () => _viewPlanDetails(plan.id ?? ''),
                      onDelete: () => _deletePlan(plan.id ?? ''),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final simbriefService = Provider.of<SimBriefService>(context, listen: false);
          final latestPlan = await simbriefService.getLatestPlan();
          if (latestPlan != null) {
            await _importPlan(latestPlan.ofpId ?? '');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No latest plan found on SimBrief')),
            );
          }
        },
        icon: const Icon(Icons.cloud_download),
        label: const Text('Import Latest'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No flight plans found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your SimBrief flight plans will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            onPressed: _refreshPlans,
          ),
        ],
      ),
    );
  }
}
