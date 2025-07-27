import 'package:be_careful_hind/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'core/app_export.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KeepScreenOn.turnOn();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: AppLocalization(),
        theme: theme,
        title: 'Be Careful Hind',
        initialBinding: InitialBindings(),
        initialRoute: AppRoutes.splashScreen,
        getPages: AppRoutes.pages,
      );
    });
  }
}
