import 'package:a_watch/data/parser/anime_list_parser.dart';
import 'package:a_watch/data/parser/anime_detail_parser.dart';
import 'package:a_watch/data/parser/collections_parser.dart';
import 'package:a_watch/data/parser/series_page_parser.dart';
import 'package:a_watch/data/parser/iparser.dart';

class ParserFactoryImpl extends ParserFactory {
  ParserFactoryImpl() : super([
        AnimeListParser(),
        AnimeDetailParser(),
        CollectionsParser(),
        SeriesPageParser(),
      ]);
}
