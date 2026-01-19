import 'package:a_watch/domain/entities/anime_detail.dart';
import 'package:flutter/material.dart';
import 'package:a_watch/presentation/components/index.dart';

class AnimeInfoList extends StatelessWidget {
  final AnimeDetail animeDetail;

  const AnimeInfoList({
    super.key,
    required this.animeDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppH4('Информация'),
          const SizedBox(height: 12),

          InfoRow(label: 'Год выхода', value: animeDetail.year.toString()),
          InfoRow(
            label: 'Продолжительность',
            value: animeDetail.duration != null ? '${animeDetail.duration} мин.' : 'Неизвестно',
          ),
          InfoRow(
            label: 'Режиссёр',
            value: animeDetail.director ?? 'Неизвестно',
          ),
          InfoRow(
            label: 'Рейтинг',
            value: '${animeDetail.rating}/10 (${animeDetail.ratingCount} голосов)',
          ),
          InfoRow(
            label: 'Жанры',
            value: animeDetail.genres.join(', '),
          ),
          InfoRow(
            label: 'Просмотров',
            value: animeDetail.views.toString().replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]} ',
            ),
          ),
          InfoRow(label: 'Статус', value: animeDetail.status),
          InfoRow(label: 'Первоисточник', value: animeDetail.source),
          InfoRow(label: 'Студия', value: animeDetail.studio),
          InfoRow(
            label: 'Тип перевода',
            value: animeDetail.translations.isNotEmpty
              ? animeDetail.translations.join(', ')
              : 'Неизвестно',
          ),
        ],
      );
  }
}
