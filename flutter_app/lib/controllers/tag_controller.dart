import 'package:get/get.dart';
import '../models/misc_models.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';

/// Controller for managing tag-related functionality
class TagController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Search state
  final _isSearching = false.obs;
  final _searchResults = <StickerTag>[].obs;
  final _searchQuery = ''.obs;
  final _searchMeta = Rxn<SearchMeta>();
  final _currentPage = 1.obs;
  final _hasMoreResults = true.obs;

  // Trending tags state
  final _isLoadingTrending = false.obs;
  final _trendingTags = <TrendingTag>[].obs;

  // Recommended tags state
  final _isLoadingRecommended = false.obs;
  final _recommendedTags = <String>[].obs;

  // Error state
  final _error = ''.obs;

  // Getters
  bool get isSearching => _isSearching.value;
  List<StickerTag> get searchResults => _searchResults;
  String get searchQuery => _searchQuery.value;
  SearchMeta? get searchMeta => _searchMeta.value;
  int get currentPage => _currentPage.value;
  bool get hasMoreResults => _hasMoreResults.value;

  bool get isLoadingTrending => _isLoadingTrending.value;
  List<TrendingTag> get trendingTags => _trendingTags;

  bool get isLoadingRecommended => _isLoadingRecommended.value;
  List<String> get recommendedTags => _recommendedTags;

  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadTrendingTags();
    loadRecommendedTags();
  }

  /// Search for tags with pagination support
  Future<void> searchTags(String query, {bool isNewSearch = true}) async {
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

      final response = await _apiService.searchTags(
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
      _error.value = 'Failed to search tags: $e';
      print('Error searching tags: $e');
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
    await searchTags(_searchQuery.value, isNewSearch: false);
  }

  /// Load trending tags
  Future<void> loadTrendingTags() async {
    try {
      _isLoadingTrending.value = true;
      _error.value = '';

      final response = await _apiService.getTrendingTags();
      
      if (response.isSuccess && response.data != null) {
        _trendingTags.assignAll(response.data!);
      } else {
        _error.value = response.message;
      }
    } catch (e) {
      _error.value = 'Failed to load trending tags: $e';
      print('Error loading trending tags: $e');
    } finally {
      _isLoadingTrending.value = false;
    }
  }

  /// Load recommended tags
  Future<void> loadRecommendedTags() async {
    try {
      _isLoadingRecommended.value = true;
      _error.value = '';

      final response = await _apiService.getRecommendedTags();
      
      if (response.isSuccess && response.data != null) {
        _recommendedTags.assignAll(response.data!);
      } else {
        _error.value = response.message;
      }
    } catch (e) {
      _error.value = 'Failed to load recommended tags: $e';
      print('Error loading recommended tags: $e');
    } finally {
      _isLoadingRecommended.value = false;
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

  /// Refresh trending tags
  Future<void> refreshTrending() async {
    _trendingTags.clear();
    await loadTrendingTags();
  }

  /// Refresh recommended tags
  Future<void> refreshRecommended() async {
    _recommendedTags.clear();
    await loadRecommendedTags();
  }

  /// Refresh all tag data
  Future<void> refreshAll() async {
    await Future.wait([
      loadTrendingTags(),
      loadRecommendedTags(),
    ]);
  }

  /// Clear error state
  void clearError() {
    _error.value = '';
  }

  /// Get tag by name from current results
  StickerTag? getTagByName(String tagName) {
    try {
      return _searchResults.firstWhere((tag) => tag.tagName == tagName);
    } catch (e) {
      return null;
    }
  }

  /// Get trending tag by keyword
  TrendingTag? getTrendingTagByKeyword(String keyword) {
    try {
      return _trendingTags.firstWhere((tag) => tag.keyword == keyword);
    } catch (e) {
      return null;
    }
  }

  /// Check if tag is popular (has high count)
  bool isTagPopular(StickerTag tag) {
    const popularThreshold = 100; // Adjust based on your needs
    return tag.count >= popularThreshold;
  }

  /// Get popular tags from search results
  List<StickerTag> get popularTags {
    return _searchResults.where((tag) => isTagPopular(tag)).toList();
  }

  /// Get new trending tags
  List<TrendingTag> get newTrendingTags {
    return _trendingTags.where((tag) => tag.isNew).toList();
  }
}