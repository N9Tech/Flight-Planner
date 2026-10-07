import 'package:flutter/material.dart';
import '../models/simbrief_response.dart';

class FlightPlanCard extends StatelessWidget {
  final SimBriefPlan plan;
  final VoidCallback? onImport;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  const FlightPlanCard({
    super.key,
    required this.plan,
    this.onImport,
    this.onView,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.id ?? 'Unknown Plan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (plan.userId != null)
                        Text(
                          'User: ${plan.userId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (plan.pilotId != null)
                  Chip(
                    label: Text(plan.pilotId!),
                    avatar: const Icon(Icons.person, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onView != null)
                  TextButton.icon(
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                    onPressed: onView,
                  ),
                if (onImport != null)
                  TextButton.icon(
                    icon: const Icon(Icons.cloud_download, size: 16),
                    label: const Text('Import'),
                    onPressed: onImport,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
