// ==========================
// API Response Models
// ==========================

/// Standardized API response wrapper used by all endpoints
class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? errors;
  final String timestamp;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.meta,
    this.errors,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      status: json['status'] ?? 'unknown',
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      meta: json['meta'] as Map<String, dynamic>?,
      errors: json['errors'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) {
    return {
      'status': status,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
      'meta': meta,
      'errors': errors,
      'timestamp': timestamp,
    };
  }

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';
}

/// Generic result wrapper for lists
class ListResult<T> {
  final List<T> items;
  final int? size;

  ListResult({
    required this.items,
    this.size,
  });

  factory ListResult.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ListResult<T>(
      items: (json['stickers'] as List? ?? json['stickerPacks'] as List? ?? json['tags'] as List? ?? json['artists'] as List? ?? [])
          .map((item) => fromJsonT(item))
          .toList(),
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'size': size,
    };
  }
}

/// Pagination metadata included in search responses
class PaginationMeta {
  final int page;
  final int pageSize;
  final int pageCount;
  final int total;

  PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.pageCount,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      pageCount: json['pageCount'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'pageSize': pageSize,
      'pageCount': pageCount,
      'total': total,
    };
  }
}

/// Search metadata with keyword enhancement info
class SearchMeta {
  final KeywordMeta keyword;
  final PaginationMeta pagination;

  SearchMeta({
    required this.keyword,
    required this.pagination,
  });

  factory SearchMeta.fromJson(Map<String, dynamic> json) {
    return SearchMeta(
      keyword: KeywordMeta.fromJson(json['keyword'] ?? {}),
      pagination: PaginationMeta.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword.toJson(),
      'pagination': pagination.toJson(),
    };
  }
}

class KeywordMeta {
  final String original;
  final String improved;

  KeywordMeta({
    required this.original,
    required this.improved,
  });

  factory KeywordMeta.fromJson(Map<String, dynamic> json) {
    return KeywordMeta(
      original: json['original'] ?? '',
      improved: json['improved'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'improved': improved,
    };
  }
}