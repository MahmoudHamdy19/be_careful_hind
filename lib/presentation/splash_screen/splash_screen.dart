
import '../../core/app_export.dart';
import 'controller/splash_controller.dart';
import 'package:flutter/material.dart';
class SplashScreen extends GetWidget<SplashController> {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:  Center(
          child: CustomImageView(
            width: 250,
            imagePath: ImageConstant.imgLogo,
          ),
        ),
      )
    );
  }
}
