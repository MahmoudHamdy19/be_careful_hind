import 'package:be_careful_hind/core/app_export.dart';
import 'package:be_careful_hind/presentation/add_location/add_location_screen.dart';
import 'package:be_careful_hind/presentation/navigation_map/navigation_map_screen.dart';
import 'package:be_careful_hind/presentation/setting/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainController extends GetxController {
  PersistentTabController pageController = PersistentTabController(initialIndex: 1,);
  PrefUtils prefUtils = Get.find<PrefUtils>();
  RxBool isDark = false.obs;
  RxBool isNotification = true.obs;

  RxInt currentIndex = 1.obs;
  List<Widget> get pages => [
    AddLocationScreen(),
    CarNavigationScreen(),
    SettingScreen(),
  ];

  @override
  onInit() {
    super.onInit();
    prefUtils.init();
    isDark.value = prefUtils.getMapTheme() == 'dark';
  }

  List<String> get titles => [
    'قائمة الردادارت المضافة ',
    'ساحة المعركة',
    'الاعدادات',
  ];

  void changePage(int index) {
    pageController.jumpToTab(
      index,
    );
    currentIndex.value = index;
  }

  toggleTheme(bool isDarkModel) {
    isDark.value = isDarkModel;
    if (isDark.value) {
      prefUtils.setMapTheme('dark');
    } else {
      prefUtils.setMapTheme('light');
    }

    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          IconButton(
            icon:   Icon(
              Icons.close,
              color: isDarkModel ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          Spacer(),
          Text(
            isDarkModel ? 'تم تغيير الوضع الداكن' : 'تم تغيير الوضع الفاتح',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: isDarkModel ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: isDarkModel ? Colors.black : Colors.white,
      colorText: isDarkModel ? Colors.white : Colors.black,
    );
   }
}
