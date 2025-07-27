import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var newText = '';

    for (int i = 0; i < digitsOnly.length; i++) {
      newText += digitsOnly[i];
      if (i == 4 || i == 11) newText += '-';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}