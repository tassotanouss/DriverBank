import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.prefixText,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.isFormField = false,
    this.helperText,
    this.autovalidateMode,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? prefixText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool isFormField;
  final String? helperText;
  final AutovalidateMode? autovalidateMode;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      helperText: helperText,
    );

    final field = isFormField
        ? TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            autovalidateMode: autovalidateMode,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            decoration: decoration,
          )
        : TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            decoration: decoration,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: field,
    );
  }
}
