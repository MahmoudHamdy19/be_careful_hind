import 'package:be_careful_hind/core/app_export.dart';
import 'package:be_careful_hind/presentation/mian_screen/controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainScreen extends GetWidget<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf1eee7),
      appBar: AppBar(
        leadingWidth: 140,
        toolbarHeight: 80,
        leading: Image.asset(ImageConstant.logo),
        actions: [
          Obx(
            () => Text(
              controller.titles[controller.currentIndex.value],
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 24.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 20.0),
        ],
      ),
      body: PersistentTabView(
        controller: controller.pageController,
        onTabChanged: (value) {
          controller.currentIndex.value = value;
        },
         navBarOverlap: NavBarOverlap.custom(
           overlap: 30
         ),
         tabs: [
          PersistentTabConfig(
            item: ItemConfig(
              icon: Image.asset(ImageConstant.mapIcon, height: 40.0),
              title: 'الرادارات',
            ),
            screen: controller.pages[0],
          ),
          PersistentTabConfig(
            item: ItemConfig(
              icon: CircleAvatar(
                radius: 35,
                child: Image.asset(ImageConstant.aim, height: 40.0),
              ),
              title: '',
            ),
            screen: controller.pages[1],
          ),
          PersistentTabConfig(
            item: ItemConfig(
              icon: Image.asset(ImageConstant.settingIcon, height: 40.0),
              title: 'الإعدادات',
            ),
            screen: controller.pages[2],
          ),
        ],
        backgroundColor: Colors.transparent,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: false,
        stateManagement: false,
       avoidBottomPadding: false,
        navBarBuilder: (NavBarConfig navBarConfig) {
          return Style13BottomNavBar(
              navBarConfig: navBarConfig,
            height: 70,
          );
        },
      ),
    );
  }
}
