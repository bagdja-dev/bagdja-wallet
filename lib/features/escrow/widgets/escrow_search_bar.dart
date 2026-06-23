import 'package:flutter/material.dart';

class EscrowSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSearch;
  const EscrowSearchBar({super.key, required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search buyer, seller, notes',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onSubmitted: onSearch,
      ),
    );
  }
}
