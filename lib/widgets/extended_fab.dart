import 'package:flutter/material.dart';

class ExtendedFab extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const ExtendedFab({
    super.key,
    required this.isExpanded,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 150),
      offset: isExpanded ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isExpanded ? 1.0 : 0.0,
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          label: Text(label),
          icon: Icon(icon),
        ),
      ),
    );
  }
}
