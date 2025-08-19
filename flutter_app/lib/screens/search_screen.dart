import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sticker_controller.dart';
import '../controllers/pack_controller.dart';
import '../widgets/error_widget.dart';

/// Search screen with sticker and pack search functionality
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final StickerController _stickerController = Get.find<StickerController>();
  final PackController _packController = Get.find<PackController>();
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Stickers'),
            Tab(text: 'Packs'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stickers and packs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _stickerController.clearSearchResults();
                          _packController.clearSearchResults();
                        },
                      )
                    : null,
              ),
              onSubmitted: _performSearch,
              onChanged: (value) {
                setState(() {}); // Update UI for clear button
              },
            ),
          ),
          
          // Search Results
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStickerResults(),
                _buildPackResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerResults() {
    return Obx(() {
      if (_stickerController.isSearching && _stickerController.searchResults.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_stickerController.hasError && _stickerController.searchResults.isEmpty) {
        return CustomErrorWidget(
          message: _stickerController.error,
          onRetry: () => _performSearch(_searchController.text),
        );
      }
      
      if (_stickerController.searchResults.isEmpty && _searchController.text.isNotEmpty) {
        return EmptyStateWidget(
          title: 'No Stickers Found',
          message: 'Try searching with different keywords',
          icon: Icons.search_off,
        );
      }
      
      if (_stickerController.searchResults.isEmpty) {
        return EmptyStateWidget(
          title: 'Search Stickers',
          message: 'Enter keywords to find amazing stickers',
          icon: Icons.emoji_emotions_outlined,
        );
      }
      
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _stickerController.searchResults.length + 
                   (_stickerController.hasMoreResults ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _stickerController.searchResults.length) {
            // Load more indicator
            return const Center(child: CircularProgressIndicator());
          }
          
          final sticker = _stickerController.searchResults[index];
          return Card(
            child: InkWell(
              onTap: () {
                // TODO: Show sticker details
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_emotions,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildPackResults() {
    return Obx(() {
      if (_packController.isSearching && _packController.searchResults.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_packController.hasError && _packController.searchResults.isEmpty) {
        return CustomErrorWidget(
          message: _packController.error,
          onRetry: () => _performSearch(_searchController.text),
        );
      }
      
      if (_packController.searchResults.isEmpty && _searchController.text.isNotEmpty) {
        return EmptyStateWidget(
          title: 'No Packs Found',
          message: 'Try searching with different keywords',
          icon: Icons.search_off,
        );
      }
      
      if (_packController.searchResults.isEmpty) {
        return EmptyStateWidget(
          title: 'Search Packs',
          message: 'Enter keywords to find sticker packs',
          icon: Icons.folder_outlined,
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _packController.searchResults.length,
        itemBuilder: (context, index) {
          final pack = _packController.searchResults[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Icon(
                  Icons.folder,
                  color: Colors.grey,
                ),
              ),
              title: Text(pack.pack.name),
              subtitle: Text('${pack.pack.stickerUrls.length} stickers'),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  // TODO: Add to WhatsApp
                },
              ),
              onTap: () {
                // TODO: Show pack details
              },
            ),
          );
        },
      );
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    if (_tabController.index == 0) {
      _stickerController.searchStickers(query);
    } else {
      _packController.searchPacks(query);
    }
  }
}