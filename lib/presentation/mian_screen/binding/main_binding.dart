import 'package:be_careful_hind/core/app_export.dart';

import '../../navigation_map/binding/car_navigation_binding.dart';
import '../controller/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
   }
}