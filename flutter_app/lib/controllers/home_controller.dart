import 'package:get/get.dart';
import '../models/misc_models.dart';
import '../models/pack_models.dart';
import '../services/api_service.dart';

/// Controller for managing home screen state and data
class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observable state variables
  final _isLoading = false.obs;
  final _homeTabs = <ApiHomeTab>[].obs;
  final _homeTabPacks = <int, List<ApiStickerPack>>{}.obs;
  final _error = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<ApiHomeTab> get homeTabs => _homeTabs;
  Map<int, List<ApiStickerPack>> get homeTabPacks => _homeTabPacks;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadHomeTabs();
  }

  /// Load home tabs overview
  Future<void> loadHomeTabs() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.getHomeTabs();
      
      if (response.isSuccess && response.data != null) {
        _homeTabs.assignAll(response.data!);
        
        // Load packs for each tab
        for (final tab in response.data!) {
          await loadHomeTabPacks(tab.id);
        }
      } else {
        _error.value = response.message;
      }
    } catch (e) {
      _error.value = 'Failed to load home tabs: $e';
      print('Error loading home tabs: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load packs for a specific home tab
  Future<void> loadHomeTabPacks(int tabId) async {
    try {
      final response = await _apiService.getHomeTabPacks(tabId);
      
      if (response.isSuccess && response.data != null) {
        _homeTabPacks[tabId] = response.data!;
        _homeTabPacks.refresh(); // Trigger UI update
      }
    } catch (e) {
      print('Error loading packs for tab $tabId: $e');
    }
  }

  /// Get packs for a specific tab ID
  List<ApiStickerPack> getPacksForTab(int tabId) {
    return _homeTabPacks[tabId] ?? [];
  }

  /// Refresh home data
  Future<void> refresh() async {
    _homeTabPacks.clear();
    await loadHomeTabs();
  }

  /// Clear error state
  void clearError() {
    _error.value = '';
  }
}