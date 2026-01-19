abstract class CollectionsEvent {
  const CollectionsEvent();
}

class CollectionsLoad extends CollectionsEvent {
  final String url;
  final bool useCache;

  const CollectionsLoad({
    required this.url,
    this.useCache = true,
  });
}
