import 'dart:async';

import 'package:be_careful_hind/core/app_export.dart';
import 'package:be_careful_hind/core/utils/ttsservice.dart';
import 'package:be_careful_hind/data/models/Radar_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:vibration/vibration.dart';

import '../../../core/utils/state_renderer/state_renderer.dart';
import '../../../core/utils/state_renderer/state_renderer_impl.dart';
import '../../../data/remote_data_source/remote_data_source.dart';
import '../../mian_screen/controller/main_controller.dart';

class CarNavigationController extends GetxController {
  GoogleMapController? mapController;
  RxList<RadarModel> radars = RxList<RadarModel>([]);
  RxList<RadarModel> nearbyRadars = RxList<RadarModel>([]);
  final RemoteDataSource _remoteDataSource = Get.find<RemoteDataSourceImpl>();

  Rx<FlowState> flowState = Rx<FlowState>(
    LoadingState(stateRendererType: StateRendererType.fullScreenLoadingState),
  );

  Location location = Location();
  Rx<LocationData?> currentLocation = Rx<LocationData?>(null);
  RxDouble? currentBearing;
  BitmapDescriptor? carIcon;
  BitmapDescriptor? redRadarIcon;
  BitmapDescriptor? greenRadarIcon;
  RxDouble radarWarningDistance = 100.0.obs; // 100 meters threshold
  RxBool muteNotification = false.obs;
  bool isStartedVoice = false;
  RxBool isTracking = false.obs;
  List<BitmapDescriptor> radarIcons = [];
  PrefUtils prefUtils = Get.find<PrefUtils>();
  // Speed calculation variables
  final List<double> _speedHistory = [];
  final List<double> _speedAccuracyHistory = [];
  RxDouble filteredSpeed = 0.0.obs;
  RxDouble speedConfidence = 1.0.obs;
  RxBool isVeryFast = false.obs;

  changeRadarWarningDistance(double distance) {
    radarWarningDistance.value = distance;
    prefUtils.setDistance(distance);
    _updateRadarIcons();
  }

  @override
  void onInit() {
    super.onInit();
    radarWarningDistance.value = prefUtils.getDistance();
    muteNotification.value = prefUtils.getMute();
    getAllRadar();
    _createCarIcon();
    _initLocationService();
  }

  toggleMuteNotification() {
    muteNotification.value = !muteNotification.value;
    prefUtils.setMute(muteNotification.value);
  }

  getAllRadar() async {
    flowState.value = LoadingState(
      stateRendererType: StateRendererType.fullScreenLoadingState,
    );
    (await _remoteDataSource.getAllRadar()).fold(
      (l) {
        flowState.value = ErrorState(
          StateRendererType.fullScreenErrorState,
          l.message,
        );
      },
      (r) async {
        radars.value = r;
        await _createRadarIcons();
        _updateRadarIcons();
        flowState.value = ContentState();
      },
    );
  }

  Future<void> _createCarIcon() async {
    carIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(80, 80)),
      Get.find<MainController>().isDark.value ? ImageConstant.car_light: ImageConstant.car,
    );
  }
  updateThemeIcon()  async {
    carIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(80, 80)),
      Get.find<MainController>().isDark.value ? ImageConstant.car_light: ImageConstant.car,
    );

    greenRadarIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(80, 80)),
      Get.find<MainController>().isDark.value ? ImageConstant.location_white :  ImageConstant.location_green,
    );
    radarIcons = List.filled(radars.length, greenRadarIcon!);
    currentLocation.refresh();


  }


  // Update this method to create both colored icons
  Future<void> _createRadarIcons() async {
    redRadarIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(80, 80)),
      ImageConstant.location_red, // Make sure you have this asset
    );
    greenRadarIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(80, 80)),
      Get.find<MainController>().isDark.value ? ImageConstant.location_green :  ImageConstant.location_white,

    );

    // Initialize radarIcons with default color
    radarIcons = List.filled(radars.length, greenRadarIcon!);
  }

  // Add this helper method to calculate distance
  double _calculateDistance(LatLng point1, LatLng point2) {
    return geolocator.Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  Rx<RadarModel?> theNearestRadar  = Rx<RadarModel?>(null);
  // Update this method to check distances and update icons
  void _updateRadarIcons()  {
    if (currentLocation.value == null || radars.isEmpty) return;

    final currentLatLng = LatLng(
      currentLocation.value!.latitude!,
      currentLocation.value!.longitude!,
    );
    theNearestRadar.value = radars.first;

    for (int i = 0; i < radars.length; i++) {
      final radarLatLng = LatLng(
        radars[i].geoPoint!.latitude,
        radars[i].geoPoint!.longitude,
      );

      final distance = _calculateDistance(currentLatLng, radarLatLng);
      radars[i].distance = distance.roundToDouble();
      print("distance of radar ${radars[i].name} is $distance");

      if (distance < radarWarningDistance.value) {
        theNearestRadar.value = radars[i];
      }
      // Update icon based on distance
      radarIcons[i] =
          distance <= radarWarningDistance.value
              ? redRadarIcon!
              :  greenRadarIcon!;

      if (distance <= radarWarningDistance.value &&
          !muteNotification.value &&
          !isStartedVoice &&
          filteredSpeed.value > 0.0) {
        // Add the warning message
        isStartedVoice = true;
        Vibration.vibrate(duration: 3000);
        TTSService.speak(
          'تنبيه! يوجد رادار سرعة قريب، الرجاء تخفيف السرعة والقيادة بحذر.',
        );

        Future.delayed(Duration(seconds: 10), () {
          isStartedVoice = false;
        });
      }
    }
    nearbyRadars.value = radars.where((radar) => radar.distance! <= radarWarningDistance.value).toList();
    update(); // Notify listeners about the change
  }

  _initLocationService() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    await location.changeSettings(
      interval: 1000,
      distanceFilter: 5,
      accuracy: LocationAccuracy.high,
    );
    currentLocation.value = await location.getLocation();

    location.onLocationChanged.listen((LocationData locationData) {
      _processSpeedData(locationData);
      currentLocation.value = locationData;
      currentBearing = RxDouble(locationData.heading ?? 0);
      _updateRadarIcons(); // Add this line
      updateCameraPosition();
    });

    isTracking.value = true;
  }

  void _processSpeedData(LocationData locationData) {
    if (locationData.speed == null) return;
    print('test local speed : ${locationData.speed}');
    double currentSpeedKmh = (locationData.speed ?? 0) * 3.6;
    double? speedAccuracyKmh =
        locationData.speedAccuracy != null
            ? locationData.speedAccuracy! * 3.6
            : null;

    _speedHistory.add(currentSpeedKmh);
    if (_speedHistory.length > 5) {
      _speedHistory.removeAt(0);
    }

    if (speedAccuracyKmh != null) {
      _speedAccuracyHistory.add(speedAccuracyKmh);
      if (_speedAccuracyHistory.length > 5) {
        _speedAccuracyHistory.removeAt(0);
      }
    }

    if (_speedAccuracyHistory.isNotEmpty) {
      double avgAccuracy =
          _speedAccuracyHistory.reduce((a, b) => a + b) /
          _speedAccuracyHistory.length;
      speedConfidence.value = 1.0 - (avgAccuracy / 20.0).clamp(0.0, 1.0);
    }

    if (_speedHistory.length >= 3) {
      double sum = 0;
      double weightSum = 0;

      for (int i = 0; i < _speedHistory.length; i++) {
        double weight =
            _speedAccuracyHistory.length > i
                ? 1.0 / (_speedAccuracyHistory[i] + 0.1)
                : 1.0;
        sum += _speedHistory[i] * weight;
        weightSum += weight;
      }

      filteredSpeed.value = sum / weightSum;
    } else {
      filteredSpeed.value = currentSpeedKmh;
    }

    if (speedConfidence.value < 0.7) {
      filteredSpeed.value = 0.7 * filteredSpeed.value + 0.3 * currentSpeedKmh;
    }
  }

  updateCameraPosition() {
    if (currentLocation.value == null) return;

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            currentLocation.value!.latitude!,
            currentLocation.value!.longitude!,
          ),
          zoom: 19,
          bearing: currentBearing?.value ?? 0,
          tilt: 45,
        ),
      ),
    );
  }

  void centerMapOnLocation() {
    if (currentLocation.value != null) {
      updateCameraPosition();
    }
  }

  Widget bottomSheet() => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      color: theme.primaryColor.withAlpha(200),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: radars.length,
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
                            'الرادار: ${radars[index].name}',
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
                            'المسافة: ${(radars[index].distance ?? 0.0) > 1000 ? '${(radars[index].distance ?? 0.0) / 1000} كم بعيد جدا' : '${radars[index].distance} م'} ',
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
                            'السرعة المسموحة: ${radars[index].speed} كم/ساعة',
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
  Widget nearbyRadarBottomSheet() => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      color: theme.primaryColor.withAlpha(200),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: nearbyRadars.length,
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
                        'الرادار: ${nearbyRadars[index].name}',
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
                        'المسافة: ${(nearbyRadars[index].distance ?? 0.0) > 1000 ? '${(nearbyRadars[index].distance ?? 0.0) / 1000} كم بعيد جدا' : '${nearbyRadars[index].distance} م'} ',
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
                        'السرعة المسموحة: ${nearbyRadars[index].speed} كم/ساعة',
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

  void setSilverTheme() {
    mapController?.setMapStyle(null);
  }

  void setNightTheme() {
    final nightTheme = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#242f3e"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},
    {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},
    {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},
    {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},
    {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},
    {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},
    {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},
    {"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},
    {"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}
  ]
  ''';
    mapController?.setMapStyle(nightTheme);
  }

}
