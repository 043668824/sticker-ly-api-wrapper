import 'package:get/get.dart';
import '../models/sticker_models.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';

/// Controller for managing sticker-related functionality
class StickerController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Search state
  final _isSearching = false.obs;
  final _searchResults = <ApiSticker>[].obs;
  final _searchQuery = ''.obs;
  final _searchMeta = Rxn<SearchMeta>();
  final _currentPage = 1.obs;
  final _hasMoreResults = true.obs;

  // Recommended stickers state
  final _isLoadingRecommended = false.obs;
  final _recommendedStickers = <ApiSticker>[].obs;

  // Related stickers state
  final _isLoadingRelated = false.obs;
  final _relatedStickers = <ApiSticker>[].obs;
  final _currentStickerId = ''.obs;

  // Error state
  final _error = ''.obs;

  // Getters
  bool get isSearching => _isSearching.value;
  List<ApiSticker> get searchResults => _searchResults;
  String get searchQuery => _searchQuery.value;
  SearchMeta? get searchMeta => _searchMeta.value;
  int get currentPage => _currentPage.value;
  bool get hasMoreResults => _hasMoreResults.value;

  bool get isLoadingRecommended => _isLoadingRecommended.value;
  List<ApiSticker> get recommendedStickers => _recommendedStickers;

  bool get isLoadingRelated => _isLoadingRelated.value;
  List<ApiSticker> get relatedStickers => _relatedStickers;
  String get currentStickerId => _currentStickerId.value;

  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadRecommendedStickers();
  }

  /// Search for stickers with pagination support
  Future<void> searchStickers(String query, {bool isNewSearch = true}) async {
    if (query.trim().isEmpty) {
      clearSearchResults();
      return;
    }

    try {
      if (isNewSearch) {
        _currentPage.value = 1;
        _hasMoreResults.value = true;
        _searchResults.clear();
      }

      _isSearching.value = true;
      _error.value = '';
      _searchQuery.value = query.trim();

      final response = await _apiService.searchStickers(
        keyword: query.trim(),
        page: _currentPage.value,
        pageSize: 20,
      );

      if (response.isSuccess && response.data != null) {
        if (isNewSearch) {
          _searchResults.assignAll(response.data!);
        } else {
          _searchResults.addAll(response.data!);
        }

        // Parse search metadata if available
        if (response.meta != null) {
          try {
            _searchMeta.value = SearchMeta.fromJson(response.meta!);
            
            // Update pagination state
            final paginationMeta = _searchMeta.value?.pagination;
            if (paginationMeta != null) {
              _hasMoreResults.value = paginationMeta.page < paginationMeta.pageCount;
            }
          } catch (e) {
            print('Error parsing search metadata: $e');
          }
        }

        // Update page for next search
        if (!isNewSearch) {
          _currentPage.value++;
        }
      } else {
        _error.value = response.message;
        if (isNewSearch) {
          _searchResults.clear();
        }
      }
    } catch (e) {
      _error.value = 'Failed to search stickers: $e';
      print('Error searching stickers: $e');
      if (isNewSearch) {
        _searchResults.clear();
      }
    } finally {
      _isSearching.value = false;
    }
  }

  /// Load more search results (pagination)
  Future<void> loadMoreSearchResults() async {
    if (!_hasMoreResults.value || _isSearching.value || _searchQuery.value.isEmpty) {
      return;
    }

    _currentPage.value++;
    await searchStickers(_searchQuery.value, isNewSearch: false);
  }

  /// Load recommended stickers
  Future<void> loadRecommendedStickers() async {
    try {
      _isLoadingRecommended.value = true;
      _error.value = '';

      final response = await _apiService.getRecommendedStickers();
      
      if (response.isSuccess && response.data != null) {
        _recommendedStickers.assignAll(response.data!);
      } else {
        _error.value = response.message;
      }
    } catch (e) {
      _error.value = 'Failed to load recommended stickers: $e';
      print('Error loading recommended stickers: $e');
    } finally {
      _isLoadingRecommended.value = false;
    }
  }

  /// Load related stickers for a specific sticker ID
  Future<void> loadRelatedStickers(String stickerId) async {
    if (stickerId.isEmpty) return;

    try {
      _isLoadingRelated.value = true;
      _error.value = '';
      _currentStickerId.value = stickerId;

      final response = await _apiService.getRelatedStickers(stickerId);
      
      if (response.isSuccess && response.data != null) {
        _relatedStickers.assignAll(response.data!);
      } else {
        _error.value = response.message;
        _relatedStickers.clear();
      }
    } catch (e) {
      _error.value = 'Failed to load related stickers: $e';
      print('Error loading related stickers: $e');
      _relatedStickers.clear();
    } finally {
      _isLoadingRelated.value = false;
    }
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults.clear();
    _searchQuery.value = '';
    _searchMeta.value = null;
    _currentPage.value = 1;
    _hasMoreResults.value = true;
  }

  /// Clear related stickers
  void clearRelatedStickers() {
    _relatedStickers.clear();
    _currentStickerId.value = '';
  }

  /// Refresh recommended stickers
  Future<void> refreshRecommended() async {
    _recommendedStickers.clear();
    await loadRecommendedStickers();
  }

  /// Clear error state
  void clearError() {
    _error.value = '';
  }

  /// Get sticker by ID from current results
  ApiSticker? getStickerById(String stickerId) {
    try {
      return _searchResults.firstWhere((sticker) => sticker.id == stickerId);
    } catch (e) {
      try {
        return _recommendedStickers.firstWhere((sticker) => sticker.id == stickerId);
      } catch (e) {
        try {
          return _relatedStickers.firstWhere((sticker) => sticker.id == stickerId);
        } catch (e) {
          return null;
        }
      }
    }
  }

  /// Check if sticker is in favorites (placeholder for future implementation)
  bool isStickerFavorite(String stickerId) {
    // TODO: Implement favorite functionality with local storage
    return false;
  }

  /// Toggle sticker favorite status (placeholder for future implementation)
  Future<void> toggleStickerFavorite(String stickerId) async {
    // TODO: Implement favorite functionality with local storage
  }
}