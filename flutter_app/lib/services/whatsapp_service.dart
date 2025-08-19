import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_stickers_plus/whatsapp_stickers_plus.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;
import '../models/pack_models.dart';

/// Service for integrating sticker packs with WhatsApp
/// Handles downloading, processing, and adding sticker packs to WhatsApp
class WhatsAppService extends GetxService {
  late Dio _dio;
  
  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  // ==========================
  // WHATSAPP INTEGRATION
  // ==========================

  /// Check if WhatsApp is installed on the device
  Future<bool> isWhatsAppInstalled() async {
    try {
      return await WhatsappStickers.isWhatsAppInstalled();
    } catch (e) {
      print('Error checking WhatsApp installation: $e');
      return false;
    }
  }

  /// Check if WhatsApp Business is installed on the device
  Future<bool> isWhatsAppBusinessInstalled() async {
    try {
      return await WhatsappStickers.isWhatsAppBusinessInstalled();
    } catch (e) {
      print('Error checking WhatsApp Business installation: $e');
      return false;
    }
  }

  /// Add a sticker pack to WhatsApp
  /// Downloads and processes the pack, then adds it to WhatsApp
  Future<bool> addStickerPack(StickerPackResult pack) async {
    try {
      // Check permissions
      if (!await _requestPermissions()) {
        throw Exception('Storage permissions required to download stickers');
      }

      // Check WhatsApp installation
      final whatsappInstalled = await isWhatsAppInstalled();
      final whatsappBusinessInstalled = await isWhatsAppBusinessInstalled();
      
      if (!whatsappInstalled && !whatsappBusinessInstalled) {
        throw Exception('WhatsApp or WhatsApp Business is not installed');
      }

      // Download and prepare sticker pack
      final stickerPack = await downloadAndPrepareStickers(pack);
      
      // Add to WhatsApp
      final result = await WhatsappStickers.addStickerPack(
        identifier: pack.id,
        name: pack.name.trim().isNotEmpty ? pack.name : 'Sticker Pack',
        publisher: pack.authorName.trim().isNotEmpty ? pack.authorName : 'StickerHub',
        trayImageFileName: stickerPack.trayImageFileName,
        publisherWebsite: pack.website.isNotEmpty ? pack.website : 'https://sticker-ly-api.sergiooak.com.br',
        privacyPolicyWebsite: 'https://sticker-ly-api.sergiooak.com.br',
        licenseAgreementWebsite: 'https://sticker-ly-api.sergiooak.com.br',
        imageDataVersion: pack.resourceVersion.toString(),
        avoidCache: false,
        animatedStickerPack: pack.isAnimated,
        stickers: stickerPack.stickers,
      );
      
      if (result) {
        // Clean up temporary files
        await _cleanupTemporaryFiles(stickerPack.tempDirectory);
      }
      
      return result;
    } catch (e) {
      print('Error adding sticker pack to WhatsApp: $e');
      return false;
    }
  }

  /// Download and prepare stickers for WhatsApp integration
  Future<PreparedStickerPack> downloadAndPrepareStickers(StickerPackResult pack) async {
    try {
      // Create temporary directory for processing
      final tempDir = await _createTempDirectory(pack.id);
      
      // Determine if we need to download from ZIP or individual URLs
      final stickers = <WhatsappStickerImage>[];
      String trayImageFileName = '';
      
      if (pack.resourceZip.isNotEmpty) {
        // Download and extract ZIP file
        final zipData = await _downloadFile(pack.resourceZip);
        final archive = ZipDecoder().decodeBytes(zipData);
        
        for (final file in archive) {
          if (file.isFile) {
            final fileName = file.name;
            final fileData = file.content as List<int>;
            
            // Process sticker image
            if (_isValidStickerImage(fileName)) {
              final processedImage = await _processStickerImage(fileData, fileName);
              final localPath = '${tempDir.path}/$fileName';
              
              // Save processed image
              await File(localPath).writeAsBytes(processedImage);
              
              stickers.add(WhatsappStickerImage(
                imageFileName: fileName,
                emojis: _getEmojisForSticker(fileName),
              ));
              
              // Use first sticker as tray image if not set
              if (trayImageFileName.isEmpty) {
                trayImageFileName = fileName;
              }
            }
          }
        }
      } else if (pack.stickerUrls.isNotEmpty) {
        // Download individual sticker files
        for (int i = 0; i < pack.stickerUrls.length; i++) {
          final url = pack.stickerUrls[i];
          final fileName = 'sticker_${i.toString().padLeft(2, '0')}.webp';
          
          try {
            final imageData = await _downloadFile(url);
            final processedImage = await _processStickerImage(imageData, fileName);
            final localPath = '${tempDir.path}/$fileName';
            
            // Save processed image
            await File(localPath).writeAsBytes(processedImage);
            
            stickers.add(WhatsappStickerImage(
              imageFileName: fileName,
              emojis: _getEmojisForSticker(fileName),
            ));
            
            // Use first sticker as tray image
            if (trayImageFileName.isEmpty) {
              trayImageFileName = fileName;
            }
          } catch (e) {
            print('Failed to download sticker from $url: $e');
            // Continue with other stickers
          }
        }
      }
      
      if (stickers.isEmpty) {
        throw Exception('No valid stickers found in pack');
      }
      
      // Ensure we have a tray image
      if (trayImageFileName.isEmpty && stickers.isNotEmpty) {
        trayImageFileName = stickers.first.imageFileName;
      }
      
      return PreparedStickerPack(
        stickers: stickers,
        trayImageFileName: trayImageFileName,
        tempDirectory: tempDir,
      );
    } catch (e) {
      print('Error preparing stickers: $e');
      rethrow;
    }
  }

  // ==========================
  // PRIVATE HELPER METHODS
  // ==========================

  /// Request necessary permissions for file operations
  Future<bool> _requestPermissions() async {
    try {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Download file from URL
  Future<Uint8List> _downloadFile(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } catch (e) {
      print('Error downloading file from $url: $e');
      rethrow;
    }
  }

  /// Create temporary directory for processing
  Future<Directory> _createTempDirectory(String packId) async {
    try {
      final appDir = await getTemporaryDirectory();
      final tempDir = Directory('${appDir.path}/stickers/$packId');
      
      // Clean existing directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      await tempDir.create(recursive: true);
      return tempDir;
    } catch (e) {
      print('Error creating temp directory: $e');
      rethrow;
    }
  }

  /// Process sticker image to meet WhatsApp requirements
  /// - WebP format
  /// - Max 500KB file size
  /// - 512x512 max dimensions
  /// - Transparent background for static stickers
  Future<Uint8List> _processStickerImage(List<int> imageData, String fileName) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(Uint8List.fromList(imageData));
      if (image == null) {
        throw Exception('Failed to decode image: $fileName');
      }

      // Resize if too large (maintaining aspect ratio)
      if (image.width > 512 || image.height > 512) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 512 : null,
          height: image.height > image.width ? 512 : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // Ensure minimum size (required by WhatsApp)
      if (image.width < 96 || image.height < 96) {
        image = img.copyResize(
          image,
          width: image.width < 96 ? 96 : null,
          height: image.height < 96 ? 96 : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // Convert to WebP format
      List<int> webpData = img.encodeWebP(image);

      // Check file size (max 500KB for WhatsApp)
      if (webpData.length > 500 * 1024) {
        // Reduce quality to meet size requirements
        int quality = 80;
        while (webpData.length > 500 * 1024 && quality > 10) {
          webpData = img.encodeWebP(image, quality: quality);
          quality -= 10;
        }
      }

      return Uint8List.fromList(webpData);
    } catch (e) {
      print('Error processing image $fileName: $e');
      rethrow;
    }
  }

  /// Check if file is a valid sticker image
  bool _isValidStickerImage(String fileName) {
    final validExtensions = ['.webp', '.png', '.jpg', '.jpeg'];
    final lowerFileName = fileName.toLowerCase();
    
    return validExtensions.any((ext) => lowerFileName.endsWith(ext)) &&
           !lowerFileName.contains('tray') &&
           !lowerFileName.contains('icon');
  }

  /// Get appropriate emojis for a sticker based on filename or content
  List<String> _getEmojisForSticker(String fileName) {
    // Simple emoji mapping based on filename patterns
    final lowerFileName = fileName.toLowerCase();
    
    if (lowerFileName.contains('happy') || lowerFileName.contains('smile')) {
      return ['😊', '😄'];
    } else if (lowerFileName.contains('sad') || lowerFileName.contains('cry')) {
      return ['😢', '😭'];
    } else if (lowerFileName.contains('angry')) {
      return ['😠', '😡'];
    } else if (lowerFileName.contains('love') || lowerFileName.contains('heart')) {
      return ['❤️', '😍'];
    } else if (lowerFileName.contains('funny') || lowerFileName.contains('laugh')) {
      return ['😂', '🤣'];
    } else if (lowerFileName.contains('cool')) {
      return ['😎', '👍'];
    } else if (lowerFileName.contains('surprised')) {
      return ['😲', '😮'];
    }
    
    // Default emojis
    return ['😊', '👍'];
  }

  /// Clean up temporary files
  Future<void> _cleanupTemporaryFiles(Directory tempDir) async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error cleaning up temporary files: $e');
    }
  }
}

// ==========================
// HELPER CLASSES
// ==========================

/// Prepared sticker pack ready for WhatsApp integration
class PreparedStickerPack {
  final List<WhatsappStickerImage> stickers;
  final String trayImageFileName;
  final Directory tempDirectory;

  PreparedStickerPack({
    required this.stickers,
    required this.trayImageFileName,
    required this.tempDirectory,
  });
}