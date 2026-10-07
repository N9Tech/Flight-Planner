import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/flight_service.dart';
import '../services/airport_service.dart';
import '../models/airport.dart';

class AirportSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isOptional;

  const AirportSearchField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isOptional = false,
  });

  @override
  State<AirportSearchField> createState() => _AirportSearchFieldState();
}

class _AirportSearchFieldState extends State<AirportSearchField> {
  List<Airport> _suggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _searchAirports(widget.controller.text);
  }

  Future<void> _searchAirports(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final flightService = Provider.of<FlightService>(context, listen: false);
      final airportService = AirportService();

      // Search in recent airports first
      final recent = flightService.searchAirports(query);
      
      // Also search in popular airports
      final popular = (await airportService.getPopularAirports())
          .where((a) => 
            a.icao.toLowerCase().contains(query.toLowerCase()) ||
            a.iata.toLowerCase().contains(query.toLowerCase()) ||
            a.name.toLowerCase().contains(query.toLowerCase()) ||
            a.city.toLowerCase().contains(query.toLowerCase())
          )
          .toList();

      // Combine and deduplicate
      final all = [...recent, ...popular];
      final unique = <Airport>[];
      final seen = <String>{};
      
      for (final airport in all) {
        if (!seen.contains(airport.icao) && airport.icao.isNotEmpty) {
          seen.add(airport.icao);
          unique.add(airport);
        }
      }

      setState(() => _suggestions = unique.take(10).toList());
    } catch (e) {
      print('Error searching airports: $e');
      setState(() => _suggestions = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Airport>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Airport>.empty();
        }
        return _suggestions;
      },
      displayStringForOption: (Airport airport) => airport.displayName,
      onSelected: (Airport airport) {
        widget.controller.text = airport.icao;
        // Save to recent
        final flightService = Provider.of<FlightService>(context, listen: false);
        flightService.addRecentAirport(airport);
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Airport> onSelected,
        Iterable<Airport> options,
      ) {
        return _AirportOptionsWidget(
          options: options,
          onSelected: onSelected,
        );
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: Icon(widget.prefixIcon),
            border: const OutlineInputBorder(),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          validator: widget.isOptional
              ? null
              : (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a ${widget.labelText.toLowerCase()}';
                  }
                  // Basic validation: should be 3-4 uppercase letters
                  if (!RegExp(r'^[A-Z]{3,4}$').hasMatch(value)) {
                    return 'Please enter a valid ICAO/IATA code';
                  }
                  return null;
                },
        );
      },
    );
  }
}

class _AirportOptionsWidget extends StatelessWidget {
  final Iterable<Airport> options;
  final AutocompleteOnSelected<Airport> onSelected;

  const _AirportOptionsWidget({
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        child: SizedBox(
          height: 200,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final option = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(option),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option.displayName,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${option.icao} / ${option.iata}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
