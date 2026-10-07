import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/flight_service.dart';
import '../models/aircraft.dart';

class AircraftSearchField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;

  const AircraftSearchField({
    super.key,
    required this.controller,
    required this.decoration,
  });

  @override
  State<AircraftSearchField> createState() => _AircraftSearchFieldState();
}

class _AircraftSearchFieldState extends State<AircraftSearchField> {
  List<Aircraft> _suggestions = [];

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
    setState(() => _suggestions = flightService.searchAircrafts(widget.controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Aircraft>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Aircraft>.empty();
        }
        return _suggestions;
      },
      displayStringForOption: (Aircraft aircraft) => aircraft.displayName,
      onSelected: (Aircraft aircraft) {
        widget.controller.text = aircraft.type;
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Aircraft> onSelected,
        Iterable<Aircraft> options,
      ) {
        return _AircraftOptionsWidget(
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

class _AircraftOptionsWidget extends StatelessWidget {
  final Iterable<Aircraft> options;
  final AutocompleteOnSelected<Aircraft> onSelected;

  const _AircraftOptionsWidget({
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
                        option.registration,
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
