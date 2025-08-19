import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/whatsapp_service.dart';
import '../controllers/home_controller.dart';
import '../controllers/sticker_controller.dart';
import '../controllers/pack_controller.dart';
import '../controllers/tag_controller.dart';
import '../controllers/artist_controller.dart';

/// Dependency injection configuration for the app
/// Registers all services and controllers with GetX
class DependencyInjection {
  static void init() {
    // Register services (lazy singletons)
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<WhatsAppService>(() => WhatsAppService(), fenix: true);

    // Register controllers (lazy singletons)
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<StickerController>(() => StickerController(), fenix: true);
    Get.lazyPut<PackController>(() => PackController(), fenix: true);
    Get.lazyPut<TagController>(() => TagController(), fenix: true);
    Get.lazyPut<ArtistController>(() => ArtistController(), fenix: true);
  }

  /// Initialize essential services immediately
  /// Call this on app startup for critical services
  static Future<void> initEssentialServices() async {
    // Force instantiation of critical services
    Get.find<ApiService>();
    Get.find<WhatsAppService>();
  }
}