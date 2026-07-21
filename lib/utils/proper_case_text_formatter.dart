import 'package:flutter/services.dart';

class ProperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalize the first letter of each word
    final text = newValue.text;
    final words = text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    final newText = capitalizedWords.join(' ');
    
    // We should be careful about cursor position
    // Since we're just changing case, the length stays same unless word boundaries change
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
    );
  }
}
