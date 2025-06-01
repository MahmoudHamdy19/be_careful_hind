
import 'package:be_careful_hind/presentation/add_location/binding/add_location_binding.dart';
import 'package:be_careful_hind/presentation/mian_screen/main_screen.dart';
import 'package:be_careful_hind/presentation/navigation_map/binding/car_navigation_binding.dart';
import 'package:be_careful_hind/presentation/start_screen/binding/start_binding.dart';
import 'package:be_careful_hind/presentation/start_screen/start_screen.dart';

import '../core/app_export.dart';
import '../presentation/mian_screen/binding/main_binding.dart';
import '../presentation/splash_screen/binding/splash_binding.dart';
import '../presentation/splash_screen/splash_screen.dart';


class AppRoutes {
  // Splash and Onboarding Routes
  static const String splashScreen = '/splash_screen';
  static const String startScreen = '/start_screen';
  static const String mainScreen = '/main_screen';



  static List<GetPage> pages = [
    // Splash and Onboarding
    GetPage(
      name: splashScreen,
      page: () => SplashScreen(),
      bindings: [
        SplashBinding(),
      ],
    ),
    GetPage(
      name: startScreen,
      page: () => StartScreen(),
      bindings: [
        StartBinding()
      ],
    ),
    GetPage(
      name: mainScreen,
      page: () => MainScreen(),
      bindings: [
        MainBinding(),
        AddLocationBinding(),
        CarNavigationBinding()
      ],
    ),
  ];
}