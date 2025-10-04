import 'package:airshield/constants.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class BuscarInput extends StatefulWidget {
  final List<String> suggestions;
  final List<String> toSearch;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Future<List<String>> Function() peticion;
  final String? Function(String?)? validator;

  const BuscarInput({
    super.key,
    required this.suggestions,
    required this.toSearch,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.peticion,
  });

  @override
  State<BuscarInput> createState() => _BuscarInputState();
}

class _BuscarInputState extends State<BuscarInput> {
  bool _hasError = false;
  late List<String> _suggestions; // Lista mutable para sugerencias
  late List<String> _toSearch; // Lista mutable para búsqueda

  @override
  void initState() {
    super.initState();
    _suggestions = widget.suggestions; // Inicializar con los valores del widget
    _toSearch = widget.toSearch;
  }

  @override
  Widget build(BuildContext context) {
    return SearchField(
      validator: (value) {
        final result = widget.validator?.call(value);
        setState(() {
          _hasError = result != null;
        });
        return result;
      },
      controller: widget.controller,
      onSearchTextChanged: (query) {
        final filter = _toSearch
            .where(
              (element) => element.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
        setState(() {
          _suggestions = filter;
        });
        return null;
      },
      onTap: () async {
        final result = await widget.peticion();
        setState(() {
          _toSearch = result;
          _suggestions = result;
        });
      },
      onSuggestionTap: (item) {
        setState(() {
          widget.controller.text = item.searchKey;
        });
      },
      emptyWidget: SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: colorFuerte)),
      ),
      itemHeight: 50,
      scrollbarDecoration: ScrollbarDecoration(),
      suggestionStyle: const TextStyle(fontSize: 24, color: Colors.black),
      searchInputDecoration: SearchInputDecoration(
        prefixIcon: Icon(
          widget.icon,
          color: _hasError
              ? Colors.red
              : colorFuerte, // Cambiar color del ícono
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.2),
        labelText: widget.hint,
        labelStyle: TextStyle(color: _hasError ? Colors.red : colorFuerte),
        floatingLabelStyle: TextStyle(
          color: _hasError ? Colors.red : colorFuerte,
        ),
        errorStyle: const TextStyle(color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(color: colorFuerte),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(color: colorFuerte),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(color: colorFuerte),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      suggestionsDecoration: SuggestionDecoration(
        border: Border.all(color: colorFuerte),
        borderRadius: BorderRadius.circular(8),
      ),
      suggestions: _suggestions
          .map((e) => SearchFieldListItem<String>(e, child: Text(e)))
          .toList(),
      focusNode: FocusNode(),
      suggestionState: Suggestion.expand,
    );
  }
}
