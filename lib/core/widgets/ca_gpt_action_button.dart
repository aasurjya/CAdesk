import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Contextual AI action button for CA-GPT features.
///
/// Renders a small floating action button with an AI/sparkle icon
/// that carries context about the current screen for AI assistance.
class CaGptActionButton extends StatelessWidget {
  const CaGptActionButton({
    super.key,
    required this.contextDescription,
    this.onPressed,
  });

  /// Describes what the AI assistant should focus on, e.g.
  /// `'ITR-1 filing for PAN ABCDE1234F'`.
  final String contextDescription;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'ca_gpt_fab',
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      tooltip: 'Ask CA-GPT about $contextDescription',
      child: const Icon(Icons.auto_awesome_rounded, size: 20),
    );
  }
}
