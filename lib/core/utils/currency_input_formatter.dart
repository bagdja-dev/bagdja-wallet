
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final String? locale;
  final String? symbol;
  final int decimalDigits;

  CurrencyInputFormatter({
    this.locale = 'id_ID',
    this.symbol = '',
    this.decimalDigits = 0,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digit characters except '.'
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Parse as number
    num? number = num.tryParse(digits);
    if (number == null) {
      return oldValue;
    }

    // Format with thousand separators
    final formatter = NumberFormat.decimalPattern(locale);
    final formatted = formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String format(num amount, {String locale = 'id_ID', String? symbol, int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern(locale);
    return symbol != null ? '$symbol ${formatter.format(amount)}' : formatter.format(amount);
  }
}
