import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../services/flight_service.dart';
import 'flight_list_screen.dart';
import 'add_flight_screen.dart';
import 'simbrief_login_screen.dart';
import 'settings_screen.dart';
import '../widgets/flight_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final flightService = Provider.of<FlightService>(context);
    final upcomingFlights = flightService.getUpcomingFlights();
    final pastFlights = flightService.getPastFlights();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flight Planner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => flightService.loadData(),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildDashboard(upcomingFlights, pastFlights) : _buildPages(_currentIndex),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight),
            label: 'Flights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'SimBrief',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(List<Flight> upcomingFlights, List<Flight> pastFlights) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatsCard(upcomingFlights, pastFlights),
          const SizedBox(height: 20),
          _buildSectionHeader('Next Flights', Icons.flight_takeoff),
          const SizedBox(height: 8),
          _buildUpcomingFlights(upcomingFlights),
          const SizedBox(height: 20),
          _buildSectionHeader('Recent Flights', Icons.history),
          const SizedBox(height: 8),
          _buildRecentFlights(pastFlights),
        ],
      ),
    );
  }

  Widget _buildStatsCard(List<Flight> upcomingFlights, List<Flight> pastFlights) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Flight Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Upcoming', upcomingFlights.length.toString(), Icons.flight_takeoff, Colors.blue),
                _buildStatItem('Completed', pastFlights.length.toString(), Icons.check_circle, Colors.green),
                _buildStatItem('Total', (upcomingFlights.length + pastFlights.length).toString(), Icons.flight, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingFlights(List<Flight> flights) {
    if (flights.isEmpty) {
      return _buildEmptyState('No upcoming flights', 'Add a flight to get started');
    }

    return Column(
      children: flights.take(3).map((flight) => FlightCard(
        flight: flight,
        onTap: () => _navigateToFlightDetail(flight),
      )).toList(),
    );
  }

  Widget _buildRecentFlights(List<Flight> flights) {
    if (flights.isEmpty) {
      return _buildEmptyState('No recent flights', 'Your completed flights will appear here');
    }

    return Column(
      children: flights.take(3).map((flight) => FlightCard(
        flight: flight,
        onTap: () => _navigateToFlightDetail(flight),
      )).toList(),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.flight, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPages(int index) {
    switch (index) {
      case 1:
        return const FlightListScreen();
      case 2:
        return const SimBriefLoginScreen();
      default:
        return Container();
    }
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFlightScreen()),
        ),
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFlightScreen()),
        ),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  void _navigateToFlightDetail(Flight flight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlightScreen(flight: flight),
      ),
    );
  }
}
