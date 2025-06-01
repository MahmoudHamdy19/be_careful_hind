import 'package:be_careful_hind/core/app_export.dart';

import '../controller/start_controller.dart';

class StartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StartController());
  }
}