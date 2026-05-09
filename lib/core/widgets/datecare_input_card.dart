/// ═══════════════════════════════════════════════════════════════════════════════
/// datecare_input_card.dart — Luxury Text Input Card
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// A reusable input widget used on the Login and Register screens.
/// Wraps a TextField inside a tonal card container with:
///   - Uppercase label (metadata-style tag)
///   - Underlined input style (matches the almanac aesthetic)
///   - Ambient shadow for depth
///   - Optional password obscuring with visibility icon
///
/// USAGE:
///   DatecareInputCard(
///     label: 'Manager Email',
///     hint: 'Curator@estate.com',
///     controller: myController,
///   )
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class DatecareInputCard extends StatelessWidget {
  final String label;        // The uppercase label above the input
  final String hint;         // Placeholder text in the input field
  final bool obscureText;    // If true, shows dots instead of text (for passwords)
  final TextEditingController? controller; // Optional controller to capture input

  const DatecareInputCard({
    super.key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,   // Tonal card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5), // Ghost border
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 32, // Very diffused ambient shadow
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Uppercase metadata-style label
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // The actual text input
          TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              // Show eye icon for password fields
              suffixIcon: obscureText ? const Icon(Icons.visibility, size: 20) : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
