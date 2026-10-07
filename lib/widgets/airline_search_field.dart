import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/flight_service.dart';
import '../models/airline.dart';

class AirlineSearchField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;

  const AirlineSearchField({
    super.key,
    required this.controller,
    required this.decoration,
  });

  @override
  State<AirlineSearchField> createState() => _AirlineSearchFieldState();
}

class _AirlineSearchFieldState extends State<AirlineSearchField> {
  List<Airline> _suggestions = [];

  // List of popular airlines for suggestions
  static final List<Airline> _popularAirlines = [
    Airline(id: '', name: 'Air France', icaoCode: 'AFR', iataCode: 'AF', callsign: 'AIRFRANS', country: 'France', logoUrl: ''),
    Airline(id: '', name: 'Lufthansa', icaoCode: 'DLH', iataCode: 'LH', callsign: 'LUFTHANSA', country: 'Germany', logoUrl: ''),
    Airline(id: '', name: 'British Airways', icaoCode: 'BAW', iataCode: 'BA', callsign: 'SPEEDBIRD', country: 'United Kingdom', logoUrl: ''),
    Airline(id: '', name: 'KLM', icaoCode: 'KLM', iataCode: 'KL', callsign: 'KLM', country: 'Netherlands', logoUrl: ''),
    Airline(id: '', name: 'Delta Air Lines', icaoCode: 'DAL', iataCode: 'DL', callsign: 'DELTA', country: 'United States', logoUrl: ''),
    Airline(id: '', name: 'United Airlines', icaoCode: 'UAL', iataCode: 'UA', callsign: 'UNITED', country: 'United States', logoUrl: ''),
    Airline(id: '', name: 'American Airlines', icaoCode: 'AAL', iataCode: 'AA', callsign: 'AMERICAN', country: 'United States', logoUrl: ''),
    Airline(id: '', name: 'Emirates', icaoCode: 'UAE', iataCode: 'EK', callsign: 'EMIRATES', country: 'United Arab Emirates', logoUrl: ''),
    Airline(id: '', name: 'Qatar Airways', icaoCode: 'QTR', iataCode: 'QR', callsign: 'QATARI', country: 'Qatar', logoUrl: ''),
    Airline(id: '', name: 'Singapore Airlines', icaoCode: 'SQC', iataCode: 'SQ', callsign: 'SINGAPORE', country: 'Singapore', logoUrl: ''),
    Airline(id: '', name: 'Qantas', icaoCode: 'QFA', iataCode: 'QF', callsign: 'QANTAS', country: 'Australia', logoUrl: ''),
    Airline(id: '', name: 'Japan Airlines', icaoCode: 'JAL', iataCode: 'JL', callsign: 'JAPANAIR', country: 'Japan', logoUrl: ''),
    Airline(id: '', name: 'Cathay Pacific', icaoCode: 'CPA', iataCode: 'CX', callsign: 'CATHAY', country: 'Hong Kong', logoUrl: ''),
    Airline(id: '', name: 'Swiss International', icaoCode: 'SWR', iataCode: 'LX', callsign: 'SWISS', country: 'Switzerland', logoUrl: ''),
    Airline(id: '', name: 'Iberia', icaoCode: 'IBE', iataCode: 'IB', callsign: 'IBERIA', country: 'Spain', logoUrl: ''),
    Airline(id: '', name: 'Finnair', icaoCode: 'FIN', iataCode: 'AY', callsign: 'FINNAIR', country: 'Finland', logoUrl: ''),
    Airline(id: '', name: 'Turkish Airlines', icaoCode: 'THY', iataCode: 'TK', callsign: 'TURKAIR', country: 'Turkey', logoUrl: ''),
    Airline(id: '', name: 'Ryanair', icaoCode: 'RYR', iataCode: 'FR', callsign: 'RYANAIR', country: 'Ireland', logoUrl: ''),
    Airline(id: '', name: 'EasyJet', icaoCode: 'EZY', iataCode: 'U2', callsign: 'EASY', country: 'United Kingdom', logoUrl: ''),
    Airline(id: '', name: 'Air Canada', icaoCode: 'ACA', iataCode: 'AC', callsign: 'AIRCANADA', country: 'Canada', logoUrl: ''),
    Airline(id: '', name: 'ANA', icaoCode: 'ANA', iataCode: 'NH', callsign: 'ALL NIPPON', country: 'Japan', logoUrl: ''),
  ];

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
    final flightService = Provider.of<FlightService>(context, listen: false);
    final query = widget.controller.text.toLowerCase();
    
    // Search in saved airlines
    final saved = flightService.searchAirlines(query);
    
    // Search in popular airlines
    final popular = _popularAirlines.where((a) =>
      a.name.toLowerCase().contains(query) ||
      a.icaoCode.toLowerCase().contains(query) ||
      a.iataCode.toLowerCase().contains(query) ||
      a.callsign.toLowerCase().contains(query)
    ).toList();

    // Combine and deduplicate
    final all = [...saved, ...popular];
    final unique = <Airline>[];
    final seen = <String>{};
    
    for (final airline in all) {
      if (!seen.contains(airline.icaoCode) && airline.icaoCode.isNotEmpty) {
        seen.add(airline.icaoCode);
        unique.add(airline);
      }
    }

    setState(() => _suggestions = unique.take(10).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Airline>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Airline>.empty();
        }
        return _suggestions;
      },
      displayStringForOption: (Airline airline) => airline.displayName,
      onSelected: (Airline airline) {
        widget.controller.text = airline.name;
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Airline> onSelected,
        Iterable<Airline> options,
      ) {
        return _AirlineOptionsWidget(
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
          decoration: widget.decoration,
        );
      },
    );
  }
}

class _AirlineOptionsWidget extends StatelessWidget {
  final Iterable<Airline> options;
  final AutocompleteOnSelected<Airline> onSelected;

  const _AirlineOptionsWidget({
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
                        option.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${option.iataCode}/${option.icaoCode} - ${option.country}',
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
