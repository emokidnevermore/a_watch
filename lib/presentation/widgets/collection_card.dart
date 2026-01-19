import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final int itemCount;
  final VoidCallback? onTap;

  const CollectionCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.itemCount,
    this.onTap,
  });

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return 'https://yummyanime.tv$url';
    return 'https://yummyanime.tv/$url';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160, // Фиксированная ширина для коллекций
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
                image: _normalizeImageUrl(imageUrl).isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(_normalizeImageUrl(imageUrl)),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: imageUrl == null
                  ? const Center(
                      child: Icon(Icons.collections, size: 40, color: Colors.white),
                    )
                  : null,
            ),
            
            const SizedBox(height: 8),
            
            // Название и количество
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$itemCount аниме',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
