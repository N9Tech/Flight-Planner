import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../services/flight_service.dart';
import 'add_flight_screen.dart';
import '../widgets/flight_card.dart';

class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: All, 1: Upcoming, 2: Past

  @override
  Widget build(BuildContext context) {
    final flightService = Provider.of<FlightService>(context);
    
    List<Flight> flights = flightService.flights;
    
    // Apply filter
    if (_selectedFilter == 1) {
      flights = flightService.getUpcomingFlights();
    } else if (_selectedFilter == 2) {
      flights = flightService.getPastFlights();
    }
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      flights = flightService.searchFlights(_searchQuery);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Flights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('All Flights')),
              const PopupMenuItem(value: 1, child: Text('Upcoming')),
              const PopupMenuItem(value: 2, child: Text('Past')),
            ],
          ),
        ],
      ),
      body: flights.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: flights.length,
              itemBuilder: (context, index) {
                final flight = flights[index];
                return FlightCard(
                  flight: flight,
                  onTap: () => _navigateToFlightDetail(flight),
                  onDelete: () => _deleteFlight(flight.id),
                  onDuplicate: () => _duplicateFlight(flight),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFlightScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No flights found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 0
                ? 'Add your first flight to get started'
                : _selectedFilter == 1
                    ? 'No upcoming flights'
                    : 'No past flights',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: FlightSearchDelegate(),
    ).then((value) {
      if (value != null) {
        setState(() => _searchQuery = value);
      }
    });
  }

  void _navigateToFlightDetail(Flight flight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlightScreen(flight: flight),
      ),
    );
  }

  Future<void> _deleteFlight(String flightId) async {
    final flightService = Provider.of<FlightService>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flight'),
        content: const Text('Are you sure you want to delete this flight?'),
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
      await flightService.deleteFlight(flightId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flight deleted successfully')),
      );
    }
  }

  void _duplicateFlight(Flight flight) {
    final newFlight = flight.copyWith(
      id: '',
      flightNumber: '${flight.flightNumber}-COPY',
      createdAt: DateTime.now(),
      updatedAt: null,
      isSyncedWithSimbrief: false,
      simbriefId: '',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlightScreen(flight: newFlight),
      ),
    );
  }
}

class FlightSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, query),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final flightService = Provider.of<FlightService>(context, listen: false);
    final flights = flightService.searchFlights(query);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        return FlightCard(
          flight: flight,
          onTap: () => close(context, query),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final flightService = Provider.of<FlightService>(context, listen: false);
    final flights = flightService.searchFlights(query);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        return ListTile(
          title: Text(flight.flightInfo),
          subtitle: Text(flight.routeInfo),
          onTap: () => close(context, query),
        );
      },
    );
  }
}
