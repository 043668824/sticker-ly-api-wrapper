// ==========================
// User Models
// ==========================

/// Base user properties shared across user types
class BaseUser {
  final String oid;
  final String userName;
  final String profileUrl;
  final String creatorType;

  BaseUser({
    required this.oid,
    required this.userName,
    required this.profileUrl,
    required this.creatorType,
  });

  factory BaseUser.fromJson(Map<String, dynamic> json) {
    return BaseUser(
      oid: json['oid'] ?? '',
      userName: json['userName'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      creatorType: json['creatorType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oid': oid,
      'userName': userName,
      'profileUrl': profileUrl,
      'creatorType': creatorType,
    };
  }
}

/// General user type with optional properties
class User extends BaseUser {
  final bool? isOfficial;
  final bool? isMe;
  final String? relationType;

  User({
    required super.oid,
    required super.userName,
    required super.profileUrl,
    required super.creatorType,
    this.isOfficial,
    this.isMe,
    this.relationType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      oid: json['oid'] ?? '',
      userName: json['userName'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      creatorType: json['creatorType'] ?? '',
      isOfficial: json['isOfficial'],
      isMe: json['isMe'],
      relationType: json['relationType'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'isOfficial': isOfficial,
      'isMe': isMe,
      'relationType': relationType,
    };
  }
}

/// Official user type (always marked as official)
class OfficialUser extends BaseUser {
  final bool isOfficial;

  OfficialUser({
    required super.oid,
    required super.userName,
    required super.profileUrl,
    required super.creatorType,
    this.isOfficial = true,
  });

  factory OfficialUser.fromJson(Map<String, dynamic> json) {
    return OfficialUser(
      oid: json['oid'] ?? '',
      userName: json['userName'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      creatorType: json['creatorType'] ?? '',
      isOfficial: json['isOfficial'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'isOfficial': isOfficial,
    };
  }
}

// ==========================
// Artist Models (from API mapping)
// ==========================

/// Artist information as returned by API endpoints
class StickerlyArtist {
  final String id;
  final String name;
  final String username;
  final String bio;
  final int stickerCount;
  final int followerCount;
  final int followingCount;
  final bool isOfficial;
  final String creatorType;
  final String profileUrl;
  final String coverUrl;

  StickerlyArtist({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.stickerCount,
    required this.followerCount,
    required this.followingCount,
    required this.isOfficial,
    required this.creatorType,
    required this.profileUrl,
    required this.coverUrl,
  });

  factory StickerlyArtist.fromJson(Map<String, dynamic> json) {
    return StickerlyArtist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      bio: json['bio'] ?? '',
      stickerCount: json['stickerCount'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isOfficial: json['isOfficial'] ?? false,
      creatorType: json['creatorType'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'bio': bio,
      'stickerCount': stickerCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'isOfficial': isOfficial,
      'creatorType': creatorType,
      'profileUrl': profileUrl,
      'coverUrl': coverUrl,
    };
  }
}

/// Raw artist data as received from Stickerly API
class StickerlyArtistRaw {
  final String oid;
  final bool isPrivate;
  final bool allowUserCollection;
  final int stickerCount;
  final String relationship;
  final int followerCount;
  final int followingCount;
  final bool isOfficial;
  final String creatorType;
  final String bio;
  final List<String> socialLink;
  final bool newUser;
  final bool isMe;
  final String shareUrl;
  final String profileUrl;
  final String coverUrl;
  final String userName;
  final String displayName;

  StickerlyArtistRaw({
    required this.oid,
    required this.isPrivate,
    required this.allowUserCollection,
    required this.stickerCount,
    required this.relationship,
    required this.followerCount,
    required this.followingCount,
    required this.isOfficial,
    required this.creatorType,
    required this.bio,
    required this.socialLink,
    required this.newUser,
    required this.isMe,
    required this.shareUrl,
    required this.profileUrl,
    required this.coverUrl,
    required this.userName,
    required this.displayName,
  });

  factory StickerlyArtistRaw.fromJson(Map<String, dynamic> json) {
    return StickerlyArtistRaw(
      oid: json['oid'] ?? '',
      isPrivate: json['isPrivate'] ?? false,
      allowUserCollection: json['allowUserCollection'] ?? false,
      stickerCount: json['stickerCount'] ?? 0,
      relationship: json['relationship'] ?? '',
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isOfficial: json['isOfficial'] ?? false,
      creatorType: json['creatorType'] ?? '',
      bio: json['bio'] ?? '',
      socialLink: List<String>.from(json['socialLink'] ?? []),
      newUser: json['newUser'] ?? false,
      isMe: json['isMe'] ?? false,
      shareUrl: json['shareUrl'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      userName: json['userName'] ?? '',
      displayName: json['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oid': oid,
      'isPrivate': isPrivate,
      'allowUserCollection': allowUserCollection,
      'stickerCount': stickerCount,
      'relationship': relationship,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'isOfficial': isOfficial,
      'creatorType': creatorType,
      'bio': bio,
      'socialLink': socialLink,
      'newUser': newUser,
      'isMe': isMe,
      'shareUrl': shareUrl,
      'profileUrl': profileUrl,
      'coverUrl': coverUrl,
      'userName': userName,
      'displayName': displayName,
    };
  }
}