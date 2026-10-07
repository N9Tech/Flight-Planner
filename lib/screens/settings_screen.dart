import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/simbrief_service.dart';
import '../services/flight_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection('Account'),
            const SizedBox(height: 8),
            _buildSimBriefSettings(context),
            const SizedBox(height: 24),
            _buildSection('Data'),
            const SizedBox(height: 8),
            _buildDataSettings(context),
            const SizedBox(height: 24),
            _buildSection('About'),
            const SizedBox(height: 8),
            _buildAboutSettings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSimBriefSettings(BuildContext context) {
    final simbriefService = Provider.of<SimBriefService>(context, listen: false);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<bool>(
              future: simbriefService.isLoggedIn(),
              builder: (context, snapshot) {
                final isLoggedIn = snapshot.data ?? false;
                return ListTile(
                  leading: Icon(
                    isLoggedIn ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isLoggedIn ? Colors.green : Colors.grey,
                  ),
                  title: const Text('SimBrief Integration'),
                  subtitle: isLoggedIn
                      ? FutureBuilder<String?>
                          future: simbriefService.getUsername(),
                          builder: (context, userSnapshot) {
                            return Text('Logged in as: ${userSnapshot.data ?? "Unknown"}');
                          }
                      : const Text('Not connected'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (isLoggedIn) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout from SimBrief'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await simbriefService.logout();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Logout', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SimBriefLoginScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About SimBrief'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://www.simbrief.com'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSettings(BuildContext context) {
    final flightService = Provider.of<FlightService>(context, listen: false);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Export Data'),
              subtitle: const Text('Export flights to file'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Import Data'),
              subtitle: const Text('Import flights from file'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import feature coming soon')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all local flight data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Data'),
                    content: const Text('Are you sure you want to delete ALL flight data? This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Clear all data
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          flightService.loadData();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All data cleared')),
                          );
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('Flight Planner'),
              subtitle: Text('Version 1.0.0'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.developer_mode),
              title: const Text('Developer'),
              subtitle: const Text('N9Tech'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://github.com/N9Tech'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Source Code'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://github.com/N9Tech/Flight-Planner'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Report Issues'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://github.com/N9Tech/Flight-Planner/issues'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: $url')),
      );
    }
  }
}

// Import SimBriefLoginScreen for navigation
import 'simbrief_login_screen.dart';
