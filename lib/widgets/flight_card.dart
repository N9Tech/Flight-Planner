import 'package:flutter/material.dart';
import '../models/flight.dart';
import 'package:intl/intl.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const FlightCard({
    super.key,
    required this.flight,
    this.onTap,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                          flight.flightNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flight.airline,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (flight.isSyncedWithSimbrief)
                        const Icon(Icons.sync, color: Colors.green, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, HH:mm').format(flight.departureTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.flight_takeoff, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    flight.departureAirport,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Icon(Icons.flight_land, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    flight.arrivalAirport,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.airplanemode_active, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${flight.aircraftType} ${flight.aircraftRegistration.isNotEmpty ? '(${flight.aircraftRegistration})' : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              if (onDelete != null || onDuplicate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onDuplicate != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: onDuplicate,
                          tooltip: 'Duplicate',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Delete',
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
