import 'user_models.dart';

// ==========================
// Base Sticker Pack Models
// ==========================

/// Base sticker pack properties shared across pack types
class BaseStickerPack {
  final bool isPaid;
  final String packId;
  final bool thumb;
  final String name;

  BaseStickerPack({
    required this.isPaid,
    required this.packId,
    required this.thumb,
    required this.name,
  });

  factory BaseStickerPack.fromJson(Map<String, dynamic> json) {
    return BaseStickerPack(
      isPaid: json['isPaid'] ?? false,
      packId: json['packId'] ?? '',
      thumb: json['thumb'] ?? false,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPaid': isPaid,
      'packId': packId,
      'thumb': thumb,
      'name': name,
    };
  }
}

/// Standard sticker pack with additional properties
class StickerPack extends BaseStickerPack {
  final String trayResourceUrl;
  final int nsfwScore;
  final List<String> resourceFileNames;
  final int stickerCount;
  final String status;
  final bool isPrivate;

  StickerPack({
    required super.isPaid,
    required super.packId,
    required super.thumb,
    required super.name,
    required this.trayResourceUrl,
    required this.nsfwScore,
    required this.resourceFileNames,
    required this.stickerCount,
    required this.status,
    required this.isPrivate,
  });

  factory StickerPack.fromJson(Map<String, dynamic> json) {
    return StickerPack(
      isPaid: json['isPaid'] ?? false,
      packId: json['packId'] ?? '',
      thumb: json['thumb'] ?? false,
      name: json['name'] ?? '',
      trayResourceUrl: json['trayResourceUrl'] ?? '',
      nsfwScore: json['nsfwScore'] ?? 0,
      resourceFileNames: List<String>.from(json['resourceFileNames'] ?? []),
      stickerCount: json['stickerCount'] ?? 0,
      status: json['status'] ?? '',
      isPrivate: json['private'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'trayResourceUrl': trayResourceUrl,
      'nsfwScore': nsfwScore,
      'resourceFileNames': resourceFileNames,
      'stickerCount': stickerCount,
      'status': status,
      'private': isPrivate,
    };
  }

  bool get isNsfw => nsfwScore > 0;
}

/// Detailed sticker pack information with full metadata
class StickerPackDetailed extends BaseStickerPack {
  final bool animated;
  final int trayIndex;
  final int viewCount;
  final String authorName;
  final int exportCount;
  final bool isOfficial;
  final String website;
  final int? endNewmarkDate;
  final bool isAnimated;
  final String shareUrl;
  final String resourceUrlPrefix;
  final int resourceVersion;
  final String resourceZip;
  final int updated;
  final String owner;
  final List<String> resourceFiles;

  StickerPackDetailed({
    required super.isPaid,
    required super.packId,
    required super.thumb,
    required super.name,
    required this.animated,
    required this.trayIndex,
    required this.viewCount,
    required this.authorName,
    required this.exportCount,
    required this.isOfficial,
    required this.website,
    this.endNewmarkDate,
    required this.isAnimated,
    required this.shareUrl,
    required this.resourceUrlPrefix,
    required this.resourceVersion,
    required this.resourceZip,
    required this.updated,
    required this.owner,
    required this.resourceFiles,
  });

  factory StickerPackDetailed.fromJson(Map<String, dynamic> json) {
    return StickerPackDetailed(
      isPaid: json['isPaid'] ?? false,
      packId: json['packId'] ?? '',
      thumb: json['thumb'] ?? false,
      name: json['name'] ?? '',
      animated: json['animated'] ?? false,
      trayIndex: json['trayIndex'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      authorName: json['authorName'] ?? '',
      exportCount: json['exportCount'] ?? 0,
      isOfficial: json['isOfficial'] ?? false,
      website: json['website'] ?? '',
      endNewmarkDate: json['endNewmarkDate'],
      isAnimated: json['isAnimated'] ?? false,
      shareUrl: json['shareUrl'] ?? '',
      resourceUrlPrefix: json['resourceUrlPrefix'] ?? '',
      resourceVersion: json['resourceVersion'] ?? 0,
      resourceZip: json['resourceZip'] ?? '',
      updated: json['updated'] ?? 0,
      owner: json['owner'] ?? '',
      resourceFiles: List<String>.from(json['resourceFiles'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'animated': animated,
      'trayIndex': trayIndex,
      'viewCount': viewCount,
      'authorName': authorName,
      'exportCount': exportCount,
      'isOfficial': isOfficial,
      'website': website,
      'endNewmarkDate': endNewmarkDate,
      'isAnimated': isAnimated,
      'shareUrl': shareUrl,
      'resourceUrlPrefix': resourceUrlPrefix,
      'resourceVersion': resourceVersion,
      'resourceZip': resourceZip,
      'updated': updated,
      'owner': owner,
      'resourceFiles': resourceFiles,
    };
  }

  List<String> get stickerUrls {
    return resourceFiles.map((fileName) => resourceUrlPrefix + fileName).toList();
  }
}

// ==========================
// API-Mapped Pack Model (from useMapPack)
// ==========================

/// Simplified pack model as returned by API endpoints
class ApiStickerPack {
  final String id;
  final String name;
  final bool isAnimated;
  final bool isPaid;
  final int views;
  final List<String> stickerUrls;
  final User? user;

  ApiStickerPack({
    required this.id,
    required this.name,
    required this.isAnimated,
    required this.isPaid,
    required this.views,
    required this.stickerUrls,
    this.user,
  });

  factory ApiStickerPack.fromJson(Map<String, dynamic> json) {
    return ApiStickerPack(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isAnimated: json['isAnimated'] ?? false,
      isPaid: json['isPaid'] ?? false,
      views: json['views'] ?? 0,
      stickerUrls: List<String>.from(json['stickerUrls'] ?? []),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isAnimated': isAnimated,
      'isPaid': isPaid,
      'views': views,
      'stickerUrls': stickerUrls,
      'user': user?.toJson(),
    };
  }

  String? get thumbnail => stickerUrls.isNotEmpty ? stickerUrls.first : null;
}

// ==========================
// Pack Result Models (for specific endpoints)
// ==========================

/// Pack detail result from /packs/[id] endpoint
class StickerPackResult {
  final String packId;
  final int exportCount;
  final bool animated;
  final bool thumb;
  final String website;
  final int viewCount;
  final String authorName;
  final int trayIndex;
  final bool isPaid;
  final bool isAnimated;
  final int resourceVersion;
  final String shareUrl;
  final String resourceZip;
  final String resourceUrlPrefix;
  final String owner;
  final int updated;
  final String name;
  final List<String> stickerUrls;

  StickerPackResult({
    required this.packId,
    required this.exportCount,
    required this.animated,
    required this.thumb,
    required this.website,
    required this.viewCount,
    required this.authorName,
    required this.trayIndex,
    required this.isPaid,
    required this.isAnimated,
    required this.resourceVersion,
    required this.shareUrl,
    required this.resourceZip,
    required this.resourceUrlPrefix,
    required this.owner,
    required this.updated,
    required this.name,
    required this.stickerUrls,
  });

  factory StickerPackResult.fromJson(Map<String, dynamic> json) {
    return StickerPackResult(
      packId: json['packId'] ?? json['id'] ?? '',
      exportCount: json['exportCount'] ?? 0,
      animated: json['animated'] ?? false,
      thumb: json['thumb'] ?? false,
      website: json['website'] ?? '',
      viewCount: json['viewCount'] ?? json['views'] ?? 0,
      authorName: json['authorName'] ?? '',
      trayIndex: json['trayIndex'] ?? 0,
      isPaid: json['isPaid'] ?? false,
      isAnimated: json['isAnimated'] ?? false,
      resourceVersion: json['resourceVersion'] ?? 0,
      shareUrl: json['shareUrl'] ?? '',
      resourceZip: json['resourceZip'] ?? '',
      resourceUrlPrefix: json['resourceUrlPrefix'] ?? '',
      owner: json['owner'] ?? '',
      updated: json['updated'] ?? 0,
      name: json['name'] ?? '',
      stickerUrls: List<String>.from(json['stickerUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packId': packId,
      'exportCount': exportCount,
      'animated': animated,
      'thumb': thumb,
      'website': website,
      'viewCount': viewCount,
      'authorName': authorName,
      'trayIndex': trayIndex,
      'isPaid': isPaid,
      'isAnimated': isAnimated,
      'resourceVersion': resourceVersion,
      'shareUrl': shareUrl,
      'resourceZip': resourceZip,
      'resourceUrlPrefix': resourceUrlPrefix,
      'owner': owner,
      'updated': updated,
      'name': name,
      'stickerUrls': stickerUrls,
    };
  }

  String get id => packId;
  int get views => viewCount;
  String? get thumbnail => stickerUrls.isNotEmpty ? stickerUrls.first : null;
}