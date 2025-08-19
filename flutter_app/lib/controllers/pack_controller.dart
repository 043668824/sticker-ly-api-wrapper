import 'package:get/get.dart';
import '../models/pack_models.dart';
import '../models/sticker_models.dart';
import '../models/api_response.dart';
import '../models/misc_models.dart';
import '../services/api_service.dart';
import '../services/whatsapp_service.dart';

/// Controller for managing sticker pack functionality
class PackController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final WhatsAppService _whatsappService = Get.find<WhatsAppService>();

  // Search state
  final _isSearching = false.obs;
  final _searchResults = <ApiSticker>[].obs;
  final _searchQuery = ''.obs;
  final _searchMeta = Rxn<SearchMeta>();
  final _currentPage = 1.obs;
  final _hasMoreResults = true.obs;

  // Recommended packs state
  final _isLoadingRecommended = false.obs;
  final _recommendedPacks = Rxn<RecommendedPacksResult>();

  // Pack details state
  final _isLoadingPackDetails = false.obs;
  final _currentPackDetails = Rxn<StickerPackResult>();
  final _currentPackId = ''.obs;

  // Related packs state
  final _isLoadingRelated = false.obs;
  final _relatedPacks = <ApiStickerPack>[].obs;

  // WhatsApp integration state
  final _isAddingToWhatsApp = false.obs;
  final _whatsappInstalled = false.obs;
  final _whatsappBusinessInstalled = false.obs;

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
  RecommendedPacksResult? get recommendedPacks => _recommendedPacks.value;
  List<dynamic> get regularPacks => _recommendedPacks.value?.packs ?? [];
  List<dynamic> get premiumPacks => _recommendedPacks.value?.premium ?? [];

  bool get isLoadingPackDetails => _isLoadingPackDetails.value;
  StickerPackResult? get currentPackDetails => _currentPackDetails.value;
  String get currentPackId => _currentPackId.value;

  bool get isLoadingRelated => _isLoadingRelated.value;
  List<ApiStickerPack> get relatedPacks => _relatedPacks;

  bool get isAddingToWhatsApp => _isAddingToWhatsApp.value;
  bool get whatsappInstalled => _whatsappInstalled.value;
  bool get whatsappBusinessInstalled => _whatsappBusinessInstalled.value;
  bool get canAddToWhatsApp => _whatsappInstalled.value || _whatsappBusinessInstalled.value;

  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadRecommendedPacks();
    checkWhatsAppInstallation();
  }

  /// Search for sticker packs with pagination support
  Future<void> searchPacks(String query, {bool isNewSearch = true}) async {
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

      final response = await _apiService.searchPacks(
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

        // Parse search metadata
        if (response.meta != null) {
          try {
            _searchMeta.value = SearchMeta.fromJson(response.meta!);
            
            final paginationMeta = _searchMeta.value?.pagination;
            if (paginationMeta != null) {
              _hasMoreResults.value = paginationMeta.page < paginationMeta.pageCount;
            }
          } catch (e) {
            print('Error parsing search metadata: $e');
          }
        }

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
      _error.value = 'Failed to search packs: $e';
      print('Error searching packs: $e');
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
    await searchPacks(_searchQuery.value, isNewSearch: false);
  }

  /// Load recommended packs
  Future<void> loadRecommendedPacks() async {
    try {
      _isLoadingRecommended.value = true;
      _error.value = '';

      final response = await _apiService.getRecommendedPacks();
      
      if (response.isSuccess && response.data != null) {
        _recommendedPacks.value = response.data!;
      } else {
        _error.value = response.message;
      }
    } catch (e) {
      _error.value = 'Failed to load recommended packs: $e';
      print('Error loading recommended packs: $e');
    } finally {
      _isLoadingRecommended.value = false;
    }
  }

  /// Load detailed information for a specific pack
  Future<void> loadPackDetails(String packId) async {
    if (packId.isEmpty) return;

    try {
      _isLoadingPackDetails.value = true;
      _error.value = '';
      _currentPackId.value = packId;

      final response = await _apiService.getPackById(packId);
      
      if (response.isSuccess && response.data != null) {
        _currentPackDetails.value = response.data!;
        
        // Also load related packs
        await loadRelatedPacks(packId);
      } else {
        _error.value = response.message;
        _currentPackDetails.value = null;
      }
    } catch (e) {
      _error.value = 'Failed to load pack details: $e';
      print('Error loading pack details: $e');
      _currentPackDetails.value = null;
    } finally {
      _isLoadingPackDetails.value = false;
    }
  }

  /// Load related packs for a specific pack ID
  Future<void> loadRelatedPacks(String packId) async {
    if (packId.isEmpty) return;

    try {
      _isLoadingRelated.value = true;

      final response = await _apiService.getRelatedPacks(packId);
      
      if (response.isSuccess && response.data != null) {
        _relatedPacks.assignAll(response.data!);
      } else {
        _relatedPacks.clear();
      }
    } catch (e) {
      print('Error loading related packs: $e');
      _relatedPacks.clear();
    } finally {
      _isLoadingRelated.value = false;
    }
  }

  /// Add sticker pack to WhatsApp
  Future<bool> addPackToWhatsApp(StickerPackResult pack) async {
    if (!canAddToWhatsApp) {
      Get.snackbar(
        'WhatsApp Not Found',
        'Please install WhatsApp or WhatsApp Business to add sticker packs.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      _isAddingToWhatsApp.value = true;
      _error.value = '';

      Get.snackbar(
        'Downloading Stickers',
        'Please wait while we prepare the sticker pack...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      final success = await _whatsappService.addStickerPack(pack);
      
      if (success) {
        Get.snackbar(
          'Success!',
          'Sticker pack "${pack.name}" has been added to WhatsApp.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _error.value = 'Failed to add sticker pack to WhatsApp';
        Get.snackbar(
          'Error',
          'Failed to add sticker pack to WhatsApp. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _error.value = 'Failed to add pack to WhatsApp: $e';
      print('Error adding pack to WhatsApp: $e');
      Get.snackbar(
        'Error',
        'An error occurred while adding the sticker pack. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isAddingToWhatsApp.value = false;
    }
  }

  /// Check WhatsApp installation status
  Future<void> checkWhatsAppInstallation() async {
    try {
      _whatsappInstalled.value = await _whatsappService.isWhatsAppInstalled();
      _whatsappBusinessInstalled.value = await _whatsappService.isWhatsAppBusinessInstalled();
    } catch (e) {
      print('Error checking WhatsApp installation: $e');
      _whatsappInstalled.value = false;
      _whatsappBusinessInstalled.value = false;
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

  /// Clear pack details
  void clearPackDetails() {
    _currentPackDetails.value = null;
    _currentPackId.value = '';
    _relatedPacks.clear();
  }

  /// Refresh recommended packs
  Future<void> refreshRecommended() async {
    _recommendedPacks.value = null;
    await loadRecommendedPacks();
  }

  /// Clear error state
  void clearError() {
    _error.value = '';
  }

  /// Get pack from search results by ID
  ApiSticker? getPackFromSearchById(String packId) {
    try {
      return _searchResults.firstWhere((pack) => pack.pack.id == packId);
    } catch (e) {
      return null;
    }
  }

  /// Check if pack is in favorites (placeholder for future implementation)
  bool isPackFavorite(String packId) {
    // TODO: Implement favorite functionality with local storage
    return false;
  }

  /// Toggle pack favorite status (placeholder for future implementation)
  Future<void> togglePackFavorite(String packId) async {
    // TODO: Implement favorite functionality with local storage
  }
}