import 'package:be_careful_hind/core/app_export.dart';
import 'package:be_careful_hind/presentation/mian_screen/controller/main_controller.dart';
import 'package:be_careful_hind/presentation/navigation_map/controller/car_navigation_controller.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFf1eee7),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  print('object');
                  Get.bottomSheet(_buildRadarBottomSheet());
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 5.0,
                  ),
                  color: theme.primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          spacing: 10.0,
                          children: [
                            FractionallySizedBox(
                              heightFactor: 1.5,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                ImageConstant.location_1,
                                height: 110,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Be Careful Hind',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'مواقع الرادارات القريبة منك',
                          style: TextStyle(color: Colors.white, fontSize: 24.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50.0),
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 5.0,
                ),
                color: theme.primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        spacing: 10.0,
                        children: [
                          Expanded(
                            child: Text(
                              'مسافة التحذير',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                          FractionallySizedBox(
                            heightFactor: 2,
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(ImageConstant.handIcon),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => Slider(
                          value: Get.find<CarNavigationController>().radarWarningDistance.value,
                          activeColor: theme.colorScheme.secondary,
                          inactiveColor: Colors.white,
                          onChanged: (value) {
                            final roundedValue = value.round().toInt();
                            if (roundedValue == 100 || roundedValue == 300 || roundedValue == 500) {
                              Get.find<CarNavigationController>().changeRadarWarningDistance(roundedValue.toDouble());
                            }
                          },
                          max: 500,
                          min: 100,
                          divisions: 2,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '100م',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '300م',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '500م',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                color: theme.primaryColor,
                child: Column(
                  spacing: 10.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نمط الخريطة',
                      style: TextStyle(color: Colors.white, fontSize: 24.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              Get.find<MainController>().toggleTheme(Get.isPlatformDarkMode);
                              },
                            child: Image.asset(ImageConstant.phoneIcon, height: 70.0)),
                        InkWell(
                          onTap: () {
                            Get.find<MainController>().toggleTheme(true);
                          },
                            child: Image.asset(ImageConstant.nightIcon, height: 70.0)),
                        InkWell(
                          onTap: () {
                            Get.find<MainController>().toggleTheme(false);
                          },
                            child: Image.asset(ImageConstant.sunIcon, height: 70.0)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                color: theme.primaryColor,
                child: Column(
                  spacing: 20.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفعيل التنبيهات الصويتة',
                      style: TextStyle(color: Colors.white, fontSize: 24.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20.0,
                      children: [
                        Image.asset(ImageConstant.mic_mute, height: 50.0),
                        Obx(
                          () => Switch(
                            value: !Get.find<CarNavigationController>().muteNotification.value,
                            activeColor: theme.colorScheme.secondary,
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey,
                            trackOutlineColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            thumbColor: WidgetStateProperty.all(Colors.white),
                            onChanged: (value) {
                              Get.find<CarNavigationController>().toggleMuteNotification();
                            },
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                          ),
                        ),
                        Image.asset(ImageConstant.mic, height: 50.0),
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(onPressed: () {
                        Get.find<CarNavigationController>().playRadarAlertSound();
                      }, child: Text('Test Sounde'),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
                        backgroundColor:  MaterialStateProperty.all(Colors.white),
                        foregroundColor: MaterialStateProperty.all(theme.primaryColor),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                       ),),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarBottomSheet()=> Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      color: theme.primaryColor.withAlpha(200),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: Get.find<CarNavigationController>().radars.length,
              shrinkWrap: true,
              itemBuilder:
                  (context, index) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.radar,
                        color: Colors.orangeAccent,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'الرادار: ${Get.find<CarNavigationController>().radars[index].name}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.map, color: Colors.orangeAccent, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'المسافة: ${Get.find<CarNavigationController>().radars[index].distance?.round()} كم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        color: Colors.orangeAccent,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'السرعة المسموحة: ${Get.find<CarNavigationController>().radars[index].speed} كم/ساعة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              separatorBuilder:
                  (context, index) =>
                  Divider(color: Colors.white, height: 20.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(Icons.close, color: theme.primaryColor),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    ),
  );
}
