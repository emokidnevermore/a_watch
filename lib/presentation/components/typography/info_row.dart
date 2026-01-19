import 'package:flutter/material.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/core/theme/colors.dart';

/// InfoRow - компонент для отображения пары "ключ: значение"
/// Используется в списках информации (AnimeInfoList и подобных)
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;
  final EdgeInsetsGeometry? padding;
  final TextAlign valueTextAlign;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 120,
    this.padding,
    this.valueTextAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: AppBodyMedium(
              '$label:',
              color: AppColors.getTextColor(
                Theme.of(context).brightness,
                type: TextType.secondary,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppBodyMedium(
              value,
              color: AppColors.getTextColor(
                Theme.of(context).brightness,
                type: TextType.primary,
              ),
              textAlign: valueTextAlign,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
