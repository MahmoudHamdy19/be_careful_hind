import 'package:get/get.dart';

import '../controller/car_navigation_controller.dart';

class CarNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CarNavigationController());
  }
}