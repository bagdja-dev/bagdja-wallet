import 'package:flutter/material.dart';
import 'package:bagdja_wallet/localization/main.dart';

/// Reusable component for selecting Buyer/Seller position
class EscrowPositionSelector extends StatelessWidget {
  final String selectedPosition;
  final ValueChanged<String> onPositionSelected;

  const EscrowPositionSelector({
    super.key,
    required this.selectedPosition,
    required this.onPositionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('escrow.selectYourPosition'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PositionOption(
                label: context.tr('escrow.buyer'),
                icon: Icons.monetization_on_sharp,
                isSelected: selectedPosition == 'buyer',
                onTap: () => onPositionSelected('buyer'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PositionOption(
                label: context.tr('escrow.seller'),
                icon: Icons.store_mall_directory,
                isSelected: selectedPosition == 'seller',
                onTap: () => onPositionSelected('seller'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PositionOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PositionOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue[50] : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
