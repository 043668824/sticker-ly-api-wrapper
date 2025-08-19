import 'package:get/get.dart';
import '../models/user_models.dart';
import '../services/api_service.dart';

/// Controller for managing artist-related functionality
class ArtistController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Trending artists state
  final _isLoadingTrending = false.obs;
  final _trendingArtists = <StickerlyArtist>[].obs;

  // Recommended artists state
  final _isLoadingRecommended = false.obs;
  final _recommendedArtists = <StickerlyArtist>[].obs;

  // Selected artist state
  final _selectedArtist = Rxn<StickerlyArtist>();

  // Error state
  final _error = ''.obs;

  // Getters
  bool get isLoadingTrending => _isLoadingTrending.value;
  List<StickerlyArtist> get trendingArtists => _trendingArtists;

  bool get isLoadingRecommended => _isLoadingRecommended.value;
  List<StickerlyArtist> get recommendedArtists => _recommendedArtists;

  StickerlyArtist? get selectedArtist => _selectedArtist.value;

  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;

  // Computed getters
  List<StickerlyArtist> get officialArtists {
    return [..._trendingArtists, ..._recommendedArtists]
        .where((artist) => artist.isOfficial)
        .toSet() // Remove duplicates
        .toList();
  }

  List<StickerlyArtist> get popularArtists {
    const popularThreshold = 1000; // Followers threshold
    return [..._trendingArtists, ..._recommendedArtists]
        .where((artist) => artist.followerCount >= popularThreshold)
        .toSet()
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadTrendingArtists();
    loadRecommendedArtists();
  }

  /// Load trending artists
  Future<void> loadTrendingArtists() async {
    try {
      _isLoadingTrending.value = true;
      _error.value = '';

      final response = await _apiService.getTrendingArtists();
      
      if (response.isSuccess && response.data != null) {
        _trendingArtists.assignAll(response.data!);
      } else {
        _error.value = response.message;
      }
    } catch (e) {
      _error.value = 'Failed to load trending artists: $e';
      print('Error loading trending artists: $e');
    } finally {
      _isLoadingTrending.value = false;
    }
  }

  /// Load recommended artists
  Future<void> loadRecommendedArtists() async {
    try {
      _isLoadingRecommended.value = true;
      _error.value = '';

      final response = await _apiService.getRecommendedArtists();
      
      if (response.isSuccess && response.data != null) {
        _recommendedArtists.assignAll(response.data!);
      } else {
        _error.value = response.message;
      }
    } catch (e) {
      _error.value = 'Failed to load recommended artists: $e';
      print('Error loading recommended artists: $e');
    } finally {
      _isLoadingRecommended.value = false;
    }
  }

  /// Select an artist to view details
  void selectArtist(StickerlyArtist artist) {
    _selectedArtist.value = artist;
  }

  /// Clear selected artist
  void clearSelectedArtist() {
    _selectedArtist.value = null;
  }

  /// Get artist by ID
  StickerlyArtist? getArtistById(String artistId) {
    // Search in trending artists first
    try {
      return _trendingArtists.firstWhere((artist) => artist.id == artistId);
    } catch (e) {
      // Search in recommended artists
      try {
        return _recommendedArtists.firstWhere((artist) => artist.id == artistId);
      } catch (e) {
        return null;
      }
    }
  }

  /// Get artist by username
  StickerlyArtist? getArtistByUsername(String username) {
    // Search in trending artists first
    try {
      return _trendingArtists.firstWhere((artist) => 
          artist.username.toLowerCase() == username.toLowerCase());
    } catch (e) {
      // Search in recommended artists
      try {
        return _recommendedArtists.firstWhere((artist) => 
            artist.username.toLowerCase() == username.toLowerCase());
      } catch (e) {
        return null;
      }
    }
  }

  /// Check if artist is followed (placeholder for future implementation)
  bool isArtistFollowed(String artistId) {
    // TODO: Implement follow functionality with local storage or backend
    return false;
  }

  /// Toggle artist follow status (placeholder for future implementation)
  Future<void> toggleArtistFollow(String artistId) async {
    // TODO: Implement follow functionality
  }

  /// Get all artists (trending + recommended, deduplicated)
  List<StickerlyArtist> get allArtists {
    final allArtistsList = <StickerlyArtist>[
      ..._trendingArtists,
      ..._recommendedArtists,
    ];
    
    // Remove duplicates based on ID
    final seenIds = <String>{};
    return allArtistsList.where((artist) => seenIds.add(artist.id)).toList();
  }

  /// Search artists by name (local search in loaded data)
  List<StickerlyArtist> searchArtistsByName(String query) {
    if (query.trim().isEmpty) {
      return [];
    }
    
    final lowercaseQuery = query.toLowerCase().trim();
    return allArtists.where((artist) =>
      artist.name.toLowerCase().contains(lowercaseQuery) ||
      artist.username.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Get artists by creator type
  List<StickerlyArtist> getArtistsByCreatorType(String creatorType) {
    return allArtists.where((artist) => 
        artist.creatorType.toLowerCase() == creatorType.toLowerCase()).toList();
  }

  /// Refresh trending artists
  Future<void> refreshTrending() async {
    _trendingArtists.clear();
    await loadTrendingArtists();
  }

  /// Refresh recommended artists
  Future<void> refreshRecommended() async {
    _recommendedArtists.clear();
    await loadRecommendedArtists();
  }

  /// Refresh all artist data
  Future<void> refreshAll() async {
    await Future.wait([
      loadTrendingArtists(),
      loadRecommendedArtists(),
    ]);
  }

  /// Clear error state
  void clearError() {
    _error.value = '';
  }

  /// Check if artist is popular based on follower count
  bool isArtistPopular(StickerlyArtist artist) {
    const popularThreshold = 1000;
    return artist.followerCount >= popularThreshold;
  }

  /// Check if artist is prolific based on sticker count
  bool isArtistProlific(StickerlyArtist artist) {
    const prolificThreshold = 50;
    return artist.stickerCount >= prolificThreshold;
  }

  /// Get top artists by follower count
  List<StickerlyArtist> getTopArtistsByFollowers({int limit = 10}) {
    final sortedArtists = allArtists.toList()
      ..sort((a, b) => b.followerCount.compareTo(a.followerCount));
    
    return sortedArtists.take(limit).toList();
  }

  /// Get top artists by sticker count
  List<StickerlyArtist> getTopArtistsByStickerCount({int limit = 10}) {
    final sortedArtists = allArtists.toList()
      ..sort((a, b) => b.stickerCount.compareTo(a.stickerCount));
    
    return sortedArtists.take(limit).toList();
  }
}