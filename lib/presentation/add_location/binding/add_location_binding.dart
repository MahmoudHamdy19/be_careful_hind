import '../../../core/app_export.dart';
import '../controller/add_location_controller.dart';

class AddLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddLocationController());
  }
}