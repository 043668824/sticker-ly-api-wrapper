// ==========================
// Tag Models
// ==========================

/// Trending tag information
class TrendingTag {
  final String keyword;
  final bool isNew;
  final String image;

  TrendingTag({
    required this.keyword,
    required this.isNew,
    required this.image,
  });

  factory TrendingTag.fromJson(Map<String, dynamic> json) {
    return TrendingTag(
      keyword: json['keyword'] ?? '',
      isNew: json['isNew'] ?? false,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'isNew': isNew,
      'image': image,
    };
  }
}

/// Sticker tag information with count
class StickerTag {
  final String tagName;
  final int count;

  StickerTag({
    required this.tagName,
    required this.count,
  });

  factory StickerTag.fromJson(Map<String, dynamic> json) {
    return StickerTag(
      tagName: json['tagName'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagName': tagName,
      'count': count,
    };
  }
}

// ==========================
// Home Tab Models
// ==========================

/// Home tab overview information
class HomeTabOverview {
  final String layoutType;
  final String keyword;
  final String contentType;
  final int limit;
  final String title;
  final int id;

  HomeTabOverview({
    required this.layoutType,
    required this.keyword,
    required this.contentType,
    required this.limit,
    required this.title,
    required this.id,
  });

  factory HomeTabOverview.fromJson(Map<String, dynamic> json) {
    return HomeTabOverview(
      layoutType: json['layoutType'] ?? '',
      keyword: json['keyword'] ?? '',
      contentType: json['contentType'] ?? '',
      limit: json['limit'] ?? 0,
      title: json['title'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layoutType': layoutType,
      'keyword': keyword,
      'contentType': contentType,
      'limit': limit,
      'title': title,
      'id': id,
    };
  }
}

/// Simplified home tab info as returned by API
class ApiHomeTab {
  final int id;
  final String title;
  final String keyword;

  ApiHomeTab({
    required this.id,
    required this.title,
    required this.keyword,
  });

  factory ApiHomeTab.fromJson(Map<String, dynamic> json) {
    return ApiHomeTab(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      keyword: json['keyword'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'keyword': keyword,
    };
  }
}

// ==========================
// Result Wrapper Models
// ==========================

/// Wrapper for recommended packs response
class RecommendedPacksResult {
  final List<dynamic> packs; // Can be ApiStickerPack or StickerPackDetailed
  final List<dynamic> premium;

  RecommendedPacksResult({
    required this.packs,
    required this.premium,
  });

  factory RecommendedPacksResult.fromJson(Map<String, dynamic> json) {
    return RecommendedPacksResult(
      packs: json['packs'] ?? [],
      premium: json['premium'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packs': packs,
      'premium': premium,
    };
  }
}

/// Generic list wrapper that can hold any type of items
class ApiListResult<T> {
  final List<T> items;
  final int total;

  ApiListResult({
    required this.items,
    required this.total,
  });

  factory ApiListResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final List<dynamic> itemsList = json['items'] ?? json['data'] ?? [];
    return ApiListResult<T>(
      items: itemsList.map((item) => fromJson(item as Map<String, dynamic>)).toList(),
      total: json['total'] ?? itemsList.length,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJson) {
    return {
      'items': items.map((item) => toJson(item)).toList(),
      'total': total,
    };
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
}