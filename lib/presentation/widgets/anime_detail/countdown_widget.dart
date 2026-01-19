import 'package:flutter/material.dart';
import 'package:a_watch/presentation/components/index.dart';

/// Устаревший виджет обратного отсчета.
/// Рекомендуется использовать CountdownCard из presentation/components/
@Deprecated(
  'Use CountdownCard from presentation/components/cards/countdown_card.dart instead',
)
class CountdownWidget extends StatelessWidget {
  final DateTime targetDate;

  const CountdownWidget({super.key, required this.targetDate});

  @override
  Widget build(BuildContext context) {
    return CountdownCard(targetDate: targetDate);
  }
}
