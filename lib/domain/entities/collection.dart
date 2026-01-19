class Collection {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final int itemCount;
  final String url;

  Collection({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.itemCount,
    required this.url,
  });
}
