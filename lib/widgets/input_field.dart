import 'package:airshield/constants.dart';
import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  // Atributos del input
  final TextEditingController controller; // Controlador
  final String label; // Etiqueta del input
  final TextInputType? keyboardType; // Tipo de input
  final bool obscureText; // Si es true, oculta lo que escribes
  final String? Function(String?)? validator; // Funcion para verificar el input
  final bool? disabled; // Si es true, el campo será deshabilitado
  final String?
  defaultText; // Texto predeterminado cuando el campo esté deshabilitado
  final Color?
  colorfecha; // Color del texto para la fecha (si es un campo datetime)
  final EdgeInsetsGeometry? paddingInterno;
  final Color? colorFondo;
  final bool? centerHint;
  final Color? hintColor; // Color opcional para el hint

  // Constructor
  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.hintColor,
    this.colorFondo,
    this.centerHint,
    this.paddingInterno,
    this.colorfecha,
    this.disabled = false,
    this.defaultText,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  // Estado para verificar si el input tiene error
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Asignar el valor de defaultText al controller.text si está vacío
    if (widget.defaultText != null && widget.controller.text.isEmpty) {
      widget.controller.text = widget.defaultText!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determina si es de tipo datetime
    bool isDateTimeInput = widget.keyboardType == TextInputType.datetime;

    // Definir el color del texto
    Color textColor = widget.disabled == true
        ? Colors.black
        : (isDateTimeInput ? Colors.black : Colors.black);

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      enabled:
          widget.disabled !=
          true, // Si 'disabled' es true, el campo se deshabilita
      style: TextStyle(
        color: textColor, // Color del texto
      ),
      validator: (value) {
        final result = widget.validator?.call(value);
        setState(() {
          _hasError =
              result !=
              null; // Si el validador devuelve un error, _hasError es true
        });
        return result; // Retorna el mensaje de error para mostrarlo
      },
      decoration: InputDecoration(
        contentPadding: widget.centerHint == true
            ? const EdgeInsets.only(top: 14, right: 10, left: 10)
            : widget.paddingInterno,
        filled: true,
        fillColor: widget.disabled == true
            ? Colors.grey.withValues(alpha: .13)
            : widget.colorFondo ?? Colors.white.withValues(alpha: .2),
        hintText: widget.centerHint == true ? widget.label : null,
        hintStyle: TextStyle(
          color: _hasError
              ? Colors.red
              : (widget.hintColor ??
                    (widget.disabled == true ? Colors.grey : colorFuerte)),
          fontSize: 16,
        ),
        labelText: widget.centerHint == true ? null : widget.label,
        labelStyle: TextStyle(
          color: _hasError
              ? Colors.red
              : (widget.disabled == true ? Colors.grey : colorFuerte),
        ),
        floatingLabelBehavior: widget.centerHint == true
            ? FloatingLabelBehavior.never
            : FloatingLabelBehavior.auto,
        errorStyle: const TextStyle(color: Colors.red),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(color: colorFuerte),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(color: colorFuerte),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
