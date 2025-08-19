import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../models/api_response.dart';
import '../models/sticker_models.dart';
import '../models/pack_models.dart';
import '../models/user_models.dart';
import '../models/misc_models.dart';

/// Comprehensive API service for all Sticker.ly API endpoints
/// Based on the discovered API structure from the repository analysis
class ApiService extends getx.GetxService {
  late Dio _dio;
  
  // Base configuration extracted from repository analysis
  static const String _baseUrl = 'https://sticker-ly-api.sergiooak.com.br';
  static const String _apiVersion = 'api/v1';
  
  // Default pagination values from repository
  static const int _defaultPage = 1;
  static const int _defaultPageSize = 10;
  
  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: '$_baseUrl/$_apiVersion',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('API: $obj'),
    ));

    // Add retry interceptor for reliability
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          // Retry logic for network errors
          final response = await _dio.fetch(error.requestOptions);
          handler.resolve(response);
        } else {
          handler.next(error);
        }
      },
    ));
  }

  // ==========================
  // STICKER ENDPOINTS
  // ==========================

  /// Search for stickers by keyword with pagination
  /// GET /api/v1/stickers/search?keyword={query}&pagination[page]={page}&pagination[pageSize]={size}
  Future<ApiResponse<List<ApiSticker>>> searchStickers({
    required String keyword,
    int page = _defaultPage,
    int pageSize = _defaultPageSize,
  }) async {
    try {
      final response = await _dio.get('/stickers/search', queryParameters: {
        'keyword': keyword,
        'pagination[page]': page,
        'pagination[pageSize]': pageSize,
      });

      return ApiResponse<List<ApiSticker>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => ApiSticker.fromJson(item)).toList();
          }
          return <ApiSticker>[];
        },
      );
    } catch (e) {
      return _handleError<List<ApiSticker>>(e, 'Failed to search stickers');
    }
  }

  /// Get recommended stickers
  /// GET /api/v1/stickers/recommended
  Future<ApiResponse<List<ApiSticker>>> getRecommendedStickers() async {
    try {
      final response = await _dio.get('/stickers/recommended');

      return ApiResponse<List<ApiSticker>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => ApiSticker.fromJson(item)).toList();
          }
          return <ApiSticker>[];
        },
      );
    } catch (e) {
      return _handleError<List<ApiSticker>>(e, 'Failed to get recommended stickers');
    }
  }

  /// Get stickers related to a specific sticker ID
  /// GET /api/v1/stickers/[id]/related
  Future<ApiResponse<List<ApiSticker>>> getRelatedStickers(String stickerId) async {
    try {
      final response = await _dio.get('/stickers/$stickerId/related');

      return ApiResponse<List<ApiSticker>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => ApiSticker.fromJson(item)).toList();
          }
          return <ApiSticker>[];
        },
      );
    } catch (e) {
      return _handleError<List<ApiSticker>>(e, 'Failed to get related stickers');
    }
  }

  // ==========================
  // PACK ENDPOINTS
  // ==========================

  /// Search for sticker packs by keyword with pagination
  /// GET /api/v1/packs/search?keyword={query}&pagination[page]={page}&pagination[pageSize]={size}
  Future<ApiResponse<List<ApiSticker>>> searchPacks({
    required String keyword,
    int page = _defaultPage,
    int pageSize = _defaultPageSize,
  }) async {
    try {
      final response = await _dio.get('/packs/search', queryParameters: {
        'keyword': keyword,
        'pagination[page]': page,
        'pagination[pageSize]': pageSize,
      });

      return ApiResponse<List<ApiSticker>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => ApiSticker.fromJson(item)).toList();
          }
          return <ApiSticker>[];
        },
      );
    } catch (e) {
      return _handleError<List<ApiSticker>>(e, 'Failed to search packs');
    }
  }

  /// Get recommended sticker packs (regular and premium)
  /// GET /api/v1/packs/recommended
  Future<ApiResponse<RecommendedPacksResult>> getRecommendedPacks() async {
    try {
      final response = await _dio.get('/packs/recommended');

      return ApiResponse<RecommendedPacksResult>.fromJson(
        response.data,
        (data) => RecommendedPacksResult.fromJson(data),
      );
    } catch (e) {
      return _handleError<RecommendedPacksResult>(e, 'Failed to get recommended packs');
    }
  }

  /// Get specific sticker pack by ID
  /// GET /api/v1/packs/[id]
  Future<ApiResponse<StickerPackResult>> getPackById(String packId) async {
    try {
      final response = await _dio.get('/packs/$packId');

      return ApiResponse<StickerPackResult>.fromJson(
        response.data,
        (data) => StickerPackResult.fromJson(data),
      );
    } catch (e) {
      return _handleError<StickerPackResult>(e, 'Failed to get pack details');
    }
  }

  /// Get packs related to a specific pack ID
  /// GET /api/v1/packs/[id]/related
  Future<ApiResponse<List<ApiStickerPack>>> getRelatedPacks(String packId) async {
    try {
      final response = await _dio.get('/packs/$packId/related');

      return ApiResponse<List<ApiStickerPack>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => ApiStickerPack.fromJson(item)).toList();
          }
          return <ApiStickerPack>[];
        },
      );
    } catch (e) {
      return _handleError<List<ApiStickerPack>>(e, 'Failed to get related packs');
    }
  }

  // ==========================
  // TAG ENDPOINTS
  // ==========================

  /// Search for tags by keyword with pagination
  /// GET /api/v1/tags/search?keyword={query}&pagination[page]={page}&pagination[pageSize]={size}
  Future<ApiResponse<List<StickerTag>>> searchTags({
    required String keyword,
    int page = _defaultPage,
    int pageSize = _defaultPageSize,
  }) async {
    try {
      final response = await _dio.get('/tags/search', queryParameters: {
        'keyword': keyword,
        'pagination[page]': page,
        'pagination[pageSize]': pageSize,
      });

      return ApiResponse<List<StickerTag>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => StickerTag.fromJson(item)).toList();
          }
          return <StickerTag>[];
        },
      );
    } catch (e) {
      return _handleError<List<StickerTag>>(e, 'Failed to search tags');
    }
  }

  /// Get trending tags
  /// GET /api/v1/tags/trending
  Future<ApiResponse<List<TrendingTag>>> getTrendingTags() async {
    try {
      final response = await _dio.get('/tags/trending');

      return ApiResponse<List<TrendingTag>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => TrendingTag.fromJson(item)).toList();
          }
          return <TrendingTag>[];
        },
      );
    } catch (e) {
      return _handleError<List<TrendingTag>>(e, 'Failed to get trending tags');
    }
  }

  /// Get recommended tags
  /// GET /api/v1/tags/recommended
  Future<ApiResponse<List<String>>> getRecommendedTags() async {
    try {
      final response = await _dio.get('/tags/recommended');

      return ApiResponse<List<String>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.cast<String>();
          }
          return <String>[];
        },
      );
    } catch (e) {
      return _handleError<List<String>>(e, 'Failed to get recommended tags');
    }
  }

  // ==========================
  // ARTIST ENDPOINTS
  // ==========================

  /// Get trending artists
  /// GET /api/v1/artists/trending
  Future<ApiResponse<List<StickerlyArtist>>> getTrendingArtists() async {
    try {
      final response = await _dio.get('/artists/trending');

      return ApiResponse<List<StickerlyArtist>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => StickerlyArtist.fromJson(item)).toList();
          }
          return <StickerlyArtist>[];
        },
      );
    } catch (e) {
      return _handleError<List<StickerlyArtist>>(e, 'Failed to get trending artists');
    }
  }

  /// Get recommended artists
  /// GET /api/v1/artists/recommended
  Future<ApiResponse<List<StickerlyArtist>>> getRecommendedArtists() async {
    try {
      final response = await _dio.get('/artists/recommended');

      return ApiResponse<List<StickerlyArtist>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => StickerlyArtist.fromJson(item)).toList();
          }
          return <StickerlyArtist>[];
        },
      );
    } catch (e) {
      return _handleError<List<StickerlyArtist>>(e, 'Failed to get recommended artists');
    }
  }

  // ==========================
  // HOME TAB ENDPOINTS
  // ==========================

  /// Get home tab overview
  /// GET /api/v1/home-tabs
  Future<ApiResponse<List<ApiHomeTab>>> getHomeTabs() async {
    try {
      final response = await _dio.get('/home-tabs');

      return ApiResponse<List<ApiHomeTab>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => ApiHomeTab.fromJson(item)).toList();
          }
          return <ApiHomeTab>[];
        },
      );
    } catch (e) {
      return _handleError<List<ApiHomeTab>>(e, 'Failed to get home tabs');
    }
  }

  /// Get packs for specific home tab
  /// GET /api/v1/home-tabs/[id]
  Future<ApiResponse<List<ApiStickerPack>>> getHomeTabPacks(int tabId) async {
    try {
      final response = await _dio.get('/home-tabs/$tabId');

      return ApiResponse<List<ApiStickerPack>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => ApiStickerPack.fromJson(item)).toList();
          }
          return <ApiStickerPack>[];
        },
      );
    } catch (e) {
      return _handleError<List<ApiStickerPack>>(e, 'Failed to get home tab packs');
    }
  }

  // ==========================
  // ERROR HANDLING
  // ==========================

  ApiResponse<T> _handleError<T>(dynamic error, String fallbackMessage) {
    String errorMessage = fallbackMessage;
    int statusCode = 500;
    Map<String, dynamic>? errorDetails;

    if (error is DioException) {
      statusCode = error.response?.statusCode ?? 500;
      
      if (error.response?.data != null) {
        final responseData = error.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? fallbackMessage;
          errorDetails = responseData['errors'];
        }
      } else {
        errorMessage = error.message ?? fallbackMessage;
      }
    } else if (error is Exception) {
      errorMessage = error.toString();
    }

    return ApiResponse<T>(
      status: 'error',
      message: errorMessage,
      data: null,
      errors: errorDetails ?? {'message': errorMessage, 'statusCode': statusCode},
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  // ==========================
  // UTILITY METHODS
  // ==========================

  /// Check API connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/home-tabs');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get API base URL for external use
  String get baseUrl => '$_baseUrl/$_apiVersion';
}