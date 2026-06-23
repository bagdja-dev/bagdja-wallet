import 'package:flutter/material.dart';
import 'package:bagdja_wallet/core/utils/currency_input_formatter.dart';
import 'package:bagdja_wallet/localization/main.dart';

/// Reusable component for entering escrow amount
class EscrowAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String currencyCode;
  final String? Function(String?)? validator;

  const EscrowAmountInput({
    super.key,
    required this.controller,
    required this.currencyCode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('escrow.amount'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixText: '$currencyCode ',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          validator: validator,
        ),
      ],
    );
  }
}
