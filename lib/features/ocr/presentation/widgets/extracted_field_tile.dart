import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A list tile showing an extracted OCR field with optional inline editing.
///
/// When [editMode] is true the value is rendered in an editable [TextField].
/// Confidence is visualised via a colour-coded [LinearProgressIndicator]:
///   - green  >= 0.80
///   - amber  >= 0.60
///   - red    <  0.60
class ExtractedFieldTile extends StatefulWidget {
  const ExtractedFieldTile({
    super.key,
    required this.fieldName,
    required this.value,
    required this.confidence,
    this.editMode = false,
    this.onValueChanged,
  });

  final String fieldName;
  final String value;
  final double confidence;
  final bool editMode;
  final ValueChanged<String>? onValueChanged;

  @override
  State<ExtractedFieldTile> createState() => _ExtractedFieldTileState();
}

class _ExtractedFieldTileState extends State<ExtractedFieldTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(ExtractedFieldTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _barColor {
    if (widget.confidence >= 0.80) return AppColors.success;
    if (widget.confidence >= 0.60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.fieldName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.neutral400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(widget.confidence * 100).round()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _barColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          widget.editMode
              ? TextField(
                  controller: _controller,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: widget.onValueChanged,
                )
              : Text(
                  widget.value.isEmpty ? '—' : widget.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.value.isEmpty
                        ? AppColors.neutral300
                        : AppColors.neutral900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: widget.confidence.clamp(0.0, 1.0),
            backgroundColor: AppColors.neutral100,
            color: _barColor,
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
