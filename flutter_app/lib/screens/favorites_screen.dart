import 'package:flutter/material.dart';
import '../widgets/error_widget.dart';

/// Favorites screen for saved stickers and packs
/// TODO: Implement with local storage for favorites functionality
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              // TODO: Clear all favorites with confirmation dialog
              _showClearAllDialog(context);
            },
          ),
        ],
      ),
      body: EmptyStateWidget(
        title: 'No Favorites Yet',
        message: 'Tap the heart icon on stickers and packs to add them to favorites',
        icon: Icons.favorite_outline,
        action: ElevatedButton.icon(
          onPressed: () {
            // Navigate to search
            DefaultTabController.of(context)?.animateTo(1);
          },
          icon: const Icon(Icons.search),
          label: const Text('Discover Stickers'),
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Are you sure you want to remove all favorites? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear all favorites
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/// Profile screen with app settings and user preferences
/// TODO: Implement user preferences and app settings
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Avatar Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'StickerHub User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover and share amazing stickers',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Settings Section
          _buildSectionTitle('Settings'),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark theme',
            trailing: Switch(
              value: false, // TODO: Implement theme switching
              onChanged: (value) {
                // TODO: Implement theme switching
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'Change app language',
            onTap: () {
              // TODO: Navigate to language settings
            },
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionTitle('About'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About StickerHub',
            subtitle: 'App version and information',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: () {
              // TODO: Open terms of service
            },
          ),
          _buildSettingsTile(
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            subtitle: 'Help us improve the app',
            onTap: () {
              // TODO: Open bug report
            },
          ),
          
          const SizedBox(height: 24),
          
          // WhatsApp Integration Section
          _buildSectionTitle('WhatsApp Integration'),
          _buildSettingsTile(
            icon: Icons.message_outlined,
            title: 'WhatsApp Status',
            subtitle: 'Check WhatsApp installation',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Connected',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'StickerHub',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.emoji_emotions,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'StickerHub is a comprehensive Flutter application for browsing, discovering, and adding amazing stickers to WhatsApp.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Built with Flutter and powered by the Sticker.ly API.',
        ),
      ],
    );
  }
}