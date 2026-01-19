import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/anime/domain/entities/anime_detail.dart';
import 'dart:async';

class RecentAnimeCache {
  static const _recentAnimeKey = 'recent_anime_tabs';
  static const _recentAnimeDetailKey = 'recent_anime_detail';
  static const _maxTabs = 1;
  static final RecentAnimeCache _instance = RecentAnimeCache._internal();
  final StreamController<List<Anime>> _streamController = StreamController.broadcast();

  factory RecentAnimeCache() => _instance;

  RecentAnimeCache._internal();

  Stream<List<Anime>> get recentAnimesStream => _streamController.stream;

  Future<void> saveRecentAnime(Anime anime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingAnimes = await getRecentAnimes();
      
      // Remove if already exists
      existingAnimes.removeWhere((item) => item.id == anime.id);
      
      // Add to beginning
      existingAnimes.insert(0, anime);
      
      // Keep only the last opened anime (max 1 tab)
      if (existingAnimes.length > _maxTabs) {
        existingAnimes.removeRange(_maxTabs, existingAnimes.length);
      }
      
      final jsonList = existingAnimes.map((anime) => {
        'id': anime.id,
        'title': anime.title,
        'slug': anime.slug,
        'url': anime.url,
        'poster': anime.poster,
        'year': anime.year,
        'genres': anime.genres,
      }).toList();
      
      await prefs.setString(_recentAnimeKey, jsonEncode(jsonList));
      log('Recent anime saved: ${anime.title}');
      
      // Notify listeners about the change
      _streamController.add(existingAnimes);
    } catch (e) {
      log('Error saving recent anime: $e');
    }
  }

  Future<List<Anime>> getRecentAnimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentAnimeKey);
      
      if (jsonString == null) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      
      return jsonList.map((json) => Anime(
        id: json['id'] as String,
        title: json['title'] as String,
        slug: json['slug'] as String,
        url: json['url'] as String,
        poster: json['poster'] as String,
        year: json['year'] as String? ?? '',
        genres: (json['genres'] as List<dynamic>?)
            ?.map((g) => g as String)
            .toList() ?? [],
      )).toList();
    } catch (e) {
      log('Error loading recent animes: $e');
      return [];
    }
  }

  Future<void> clearRecentAnimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentAnimeKey);
      log('Recent animes cleared');
      
      // Notify listeners about the change
      _streamController.add([]);
    } catch (e) {
      log('Error clearing recent animes: $e');
    }
  }

  Future<bool> hasRecentAnime() async {
    final animes = await getRecentAnimes();
    return animes.isNotEmpty;
  }

  Future<Anime?> getLastRecentAnime() async {
    final animes = await getRecentAnimes();
    return animes.isNotEmpty ? animes.first : null;
  }

  Future<void> saveRecentAnimeDetail(AnimeDetail animeDetail) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create a JSON representation of AnimeDetail
      final jsonDetail = {
        'title': animeDetail.title,
        'originalTitle': animeDetail.originalTitle,
        'url': animeDetail.url,
        'posterUrl': animeDetail.posterUrl,
        'coverUrl': animeDetail.coverUrl,
        'year': animeDetail.year,
        'duration': animeDetail.duration,
        'director': animeDetail.director,
        'rating': animeDetail.rating,
        'ratingCount': animeDetail.ratingCount,
        'genres': animeDetail.genres,
        'views': animeDetail.views,
        'status': animeDetail.status,
        'source': animeDetail.source,
        'studio': animeDetail.studio,
        'translations': animeDetail.translations,
        'description': animeDetail.description,
        'nextEpisodeDate': animeDetail.nextEpisodeDate?.toIso8601String(),
        'episodeCount': animeDetail.episodeCount,
        'ageRating': animeDetail.ageRating,
        'franchise': animeDetail.franchise.map((anime) => {
          'id': anime.id,
          'title': anime.title,
          'slug': anime.slug,
          'url': anime.url,
          'poster': anime.poster,
          'year': anime.year,
          'genres': anime.genres,
        }).toList(),
        'related': animeDetail.related.map((anime) => {
          'id': anime.id,
          'title': anime.title,
          'slug': anime.slug,
          'url': anime.url,
          'poster': anime.poster,
          'year': anime.year,
          'genres': anime.genres,
        }).toList(),
      };

      await prefs.setString(_recentAnimeDetailKey, jsonEncode(jsonDetail));
      log('Recent anime detail saved: ${animeDetail.title}');
    } catch (e) {
      log('Error saving recent anime detail: $e');
    }
  }

  Future<AnimeDetail?> getRecentAnimeDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentAnimeDetailKey);

      if (jsonString == null) {
        return null;
      }

      final jsonDetail = jsonDecode(jsonString) as Map<String, dynamic>;

      return AnimeDetail(
        title: jsonDetail['title'] as String,
        originalTitle: jsonDetail['originalTitle'] as String? ?? '',
        url: jsonDetail['url'] as String,
        posterUrl: jsonDetail['posterUrl'] as String,
        coverUrl: jsonDetail['coverUrl'] as String?,
        year: jsonDetail['year'] as int,
        duration: jsonDetail['duration'] as int?,
        director: jsonDetail['director'] as String?,
        rating: (jsonDetail['rating'] as num).toDouble(),
        ratingCount: jsonDetail['ratingCount'] as int,
        genres: (jsonDetail['genres'] as List<dynamic>).map((g) => g as String).toList(),
        views: jsonDetail['views'] as int,
        status: jsonDetail['status'] as String,
        source: jsonDetail['source'] as String,
        studio: jsonDetail['studio'] as String,
        translations: (jsonDetail['translations'] as List<dynamic>).map((t) => t as String).toList(),
        description: jsonDetail['description'] as String,
        nextEpisodeDate: jsonDetail['nextEpisodeDate'] != null
            ? DateTime.parse(jsonDetail['nextEpisodeDate'] as String)
            : null,
        episodeCount: jsonDetail['episodeCount'] as int?,
        ageRating: jsonDetail['ageRating'] as String?,
        franchise: (jsonDetail['franchise'] as List<dynamic>).map((json) => Anime(
          id: json['id'] as String,
          title: json['title'] as String,
          slug: json['slug'] as String,
          url: json['url'] as String,
          poster: json['poster'] as String,
          year: json['year'] as String,
          genres: (json['genres'] as List<dynamic>).map((g) => g as String).toList(),
        )).toList(),
        related: (jsonDetail['related'] as List<dynamic>).map((json) => Anime(
          id: json['id'] as String,
          title: json['title'] as String,
          slug: json['slug'] as String,
          url: json['url'] as String,
          poster: json['poster'] as String,
          year: json['year'] as String,
          genres: (json['genres'] as List<dynamic>).map((g) => g as String).toList(),
        )).toList(),
      );
    } catch (e) {
      log('Error loading recent anime detail: $e');
      return null;
    }
  }

  Future<void> clearRecentAnimeDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentAnimeDetailKey);
      log('Recent anime detail cleared');
    } catch (e) {
      log('Error clearing recent anime detail: $e');
    }
  }

  Future<void> close() async {
    await _streamController.close();
  }
}
