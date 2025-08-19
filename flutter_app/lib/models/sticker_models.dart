import 'user_models.dart';
import 'pack_models.dart';

// ==========================
// Base Sticker Models
// ==========================

/// Base sticker properties shared across sticker types
class BaseSticker {
  final String sid;
  final bool animated;
  final bool isAnimated;
  final int viewCount;
  final bool liked;

  BaseSticker({
    required this.sid,
    required this.animated,
    required this.isAnimated,
    required this.viewCount,
    required this.liked,
  });

  factory BaseSticker.fromJson(Map<String, dynamic> json) {
    return BaseSticker(
      sid: json['sid'] ?? '',
      animated: json['animated'] ?? false,
      isAnimated: json['isAnimated'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'animated': animated,
      'isAnimated': isAnimated,
      'viewCount': viewCount,
      'liked': liked,
    };
  }
}

/// Complete sticker with associated pack and user
class Sticker extends BaseSticker {
  final StickerPack stickerPack;
  final User user;
  final String packId;
  final String resourceUrl;
  final String packName;

  Sticker({
    required super.sid,
    required super.animated,
    required super.isAnimated,
    required super.viewCount,
    required super.liked,
    required this.stickerPack,
    required this.user,
    required this.packId,
    required this.resourceUrl,
    required this.packName,
  });

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      sid: json['sid'] ?? '',
      animated: json['animated'] ?? false,
      isAnimated: json['isAnimated'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      liked: json['liked'] ?? false,
      stickerPack: StickerPack.fromJson(json['stickerPack'] ?? {}),
      user: User.fromJson(json['user'] ?? {}),
      packId: json['packId'] ?? '',
      resourceUrl: json['resourceUrl'] ?? '',
      packName: json['packName'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'stickerPack': stickerPack.toJson(),
      'user': user.toJson(),
      'packId': packId,
      'resourceUrl': resourceUrl,
      'packName': packName,
    };
  }
}

/// Detailed sticker information with fileName
class StickerDetail extends BaseSticker {
  final StickerPack stickerPack;
  final String fileName;

  StickerDetail({
    required super.sid,
    required super.animated,
    required super.isAnimated,
    required super.viewCount,
    required super.liked,
    required this.stickerPack,
    required this.fileName,
  });

  factory StickerDetail.fromJson(Map<String, dynamic> json) {
    return StickerDetail(
      sid: json['sid'] ?? '',
      animated: json['animated'] ?? false,
      isAnimated: json['isAnimated'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      liked: json['liked'] ?? false,
      stickerPack: StickerPack.fromJson(json['stickerPack'] ?? {}),
      fileName: json['fileName'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'stickerPack': stickerPack.toJson(),
      'fileName': fileName,
    };
  }
}

// ==========================
// API-Mapped Sticker Model (from useMapSticker)
// ==========================

/// Simplified sticker model as returned by API endpoints
class ApiSticker {
  final String id;
  final String url;
  final bool isAnimated;
  final int views;
  final ApiStickerPackInfo pack;
  final ApiUserInfo user;

  ApiSticker({
    required this.id,
    required this.url,
    required this.isAnimated,
    required this.views,
    required this.pack,
    required this.user,
  });

  factory ApiSticker.fromJson(Map<String, dynamic> json) {
    return ApiSticker(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      isAnimated: json['isAnimated'] ?? false,
      views: json['views'] ?? 0,
      pack: ApiStickerPackInfo.fromJson(json['pack'] ?? {}),
      user: ApiUserInfo.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'isAnimated': isAnimated,
      'views': views,
      'pack': pack.toJson(),
      'user': user.toJson(),
    };
  }
}

/// Simplified pack info embedded in sticker response
class ApiStickerPackInfo {
  final String id;
  final String name;
  final String thumbnail;
  final bool isNsfw;
  final int nsfwScore;
  final List<String> stickerUrls;

  ApiStickerPackInfo({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.isNsfw,
    required this.nsfwScore,
    required this.stickerUrls,
  });

  factory ApiStickerPackInfo.fromJson(Map<String, dynamic> json) {
    return ApiStickerPackInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      isNsfw: json['isNsfw'] ?? false,
      nsfwScore: json['nsfwScore'] ?? 0,
      stickerUrls: List<String>.from(json['stickerUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'isNsfw': isNsfw,
      'nsfwScore': nsfwScore,
      'stickerUrls': stickerUrls,
    };
  }
}

/// Simplified user info embedded in sticker response
class ApiUserInfo {
  final String? id;
  final String? name;
  final bool isOfficial;
  final String? profileUrl;

  ApiUserInfo({
    this.id,
    this.name,
    required this.isOfficial,
    this.profileUrl,
  });

  factory ApiUserInfo.fromJson(Map<String, dynamic> json) {
    return ApiUserInfo(
      id: json['id'],
      name: json['name'],
      isOfficial: json['isOfficial'] ?? false,
      profileUrl: json['profileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOfficial': isOfficial,
      'profileUrl': profileUrl,
    };
  }
}