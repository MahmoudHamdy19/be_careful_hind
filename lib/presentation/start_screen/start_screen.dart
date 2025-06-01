import 'package:be_careful_hind/core/utils/image_constant.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body: Column(
        children: [
          Image.asset(ImageConstant.logo),
          Expanded(
              child: Image.asset(ImageConstant.route,
                width: double.infinity,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.mainScreen);
              },
              child: Image.asset(
                  ImageConstant.startButton,
                height: 170,
                width: double.infinity,
                fit:BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
