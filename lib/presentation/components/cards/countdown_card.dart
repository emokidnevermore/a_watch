import 'dart:async';

import 'package:flutter/material.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/core/theme/colors.dart';
import 'package:a_watch/core/theme/borders.dart';
import 'package:a_watch/core/theme/shadows.dart';

/// CountdownCard - специализированная карточка для обратного отсчета времени
class CountdownCard extends StatefulWidget {
  final DateTime targetDate;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CountdownCard({
    super.key,
    required this.targetDate,
    this.title,
    this.padding,
    this.margin,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateTimeRemaining() {
    final now = DateTime.now();
    final target = widget.targetDate;
    final difference = target.difference(now);

    setState(() {
      _timeRemaining = difference.isNegative ? Duration.zero : difference;
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 2,
        shadowColor: AppColors.shadow,
        borderRadius: AppBorders.radiusLG,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1a2a6c), Color(0xFFb21f1f), Color(0xFFfdbb2d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppBorders.radiusLG,
            border: Border.all(
              color: AppColors.getBorderColor(Theme.of(context).brightness),
            ),
            boxShadow: AppShadows.getShadowList(ShadowType.medium),
          ),
          child: Column(
            children: [
              if (widget.title != null) ...[
                AppH4(
                  widget.title!,
                  textAlign: TextAlign.center,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
              ],

              AppBodyLarge(
                'До выхода следующей серии осталось:',
                textAlign: TextAlign.center,
                color: Colors.white.withValues(alpha: 0.9),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeBox('Дней', days),
                  _buildTimeBox('Часов', hours),
                  _buildTimeBox('Минут', minutes),
                  _buildTimeBox('Секунд', seconds),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBox(String label, int value) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.accentPrimary,
            borderRadius: AppBorders.radiusLG,
            boxShadow: AppShadows.getShadowList(ShadowType.medium),
          ),
          child: Center(
            child: AppH3(
              value.toString().padLeft(2, '0'),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 6),

        AppCaption(
          label,
          color: AppColors.getTextColor(
            Theme.of(context).brightness,
            type: TextType.secondary,
          ),
        ),
      ],
    );
  }
}
