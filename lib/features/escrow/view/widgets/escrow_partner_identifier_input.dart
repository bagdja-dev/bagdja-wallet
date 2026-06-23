import 'package:flutter/material.dart';

/// Reusable component for entering partner identifier
class EscrowPartnerIdentifierInput extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool isValidating;
  final bool? isValid;
  final String? validationMessage;
  final VoidCallback? onChanged;

  const EscrowPartnerIdentifierInput({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.isValidating = false,
    this.isValid,
    this.validationMessage,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          onChanged: (_) => onChanged?.call(),
          decoration: InputDecoration(
            labelText: labelText,
            hintText: labelText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: _buildSuffixIcon(),
          ),
          validator: validator,
        ),
        const SizedBox(height: 8),
        if (validationMessage != null)
          Text(
            validationMessage!,
            style: TextStyle(
              color: isValid == true ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (isValidating) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (isValid == true) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (isValid == false) {
      return const Icon(Icons.cancel, color: Colors.red);
    }
    return null;
  }
}
