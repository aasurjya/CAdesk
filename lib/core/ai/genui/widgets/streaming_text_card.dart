import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Shows streaming LLM text with a blinking cursor effect.
class StreamingTextCard extends StatelessWidget {
  const StreamingTextCard({
    super.key,
    required this.text,
    this.isStreaming = true,
  });

  final String text;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral900,
                  height: 1.5,
                ),
                children: [
                  if (isStreaming)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: _BlinkingCursor(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 16,
        margin: const EdgeInsets.only(left: 2),
        color: AppColors.primary,
      ),
    );
  }
}
