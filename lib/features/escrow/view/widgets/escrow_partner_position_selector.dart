import 'package:flutter/material.dart';
import 'package:bagdja_wallet/localization/main.dart';

/// Reusable component for selecting partner position (Personal/Organization)
class EscrowPartnerPositionSelector extends StatelessWidget {
  final String selectedPartnerType;
  final ValueChanged<String> onPartnerTypeSelected;

  const EscrowPartnerPositionSelector({
    super.key,
    required this.selectedPartnerType,
    required this.onPartnerTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('escrow.partnerPosition'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PartnerTypeOption(
                label: context.tr('escrow.personal'),
                icon: Icons.person,
                isSelected: selectedPartnerType == 'personal',
                onTap: () => onPartnerTypeSelected('personal'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PartnerTypeOption(
                label: context.tr('escrow.organization'),
                icon: Icons.business,
                isSelected: selectedPartnerType == 'organization',
                onTap: () => onPartnerTypeSelected('organization'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PartnerTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PartnerTypeOption({
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
