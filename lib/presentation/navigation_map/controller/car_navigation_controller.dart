import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:be_careful_hind/core/app_export.dart';
import 'package:be_careful_hind/data/models/Radar_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as pri;
import 'package:the_widget_marker/the_widget_marker.dart';
import 'package:vibration/vibration.dart';
import '../../../data/remote_data_source/remote_data_source.dart';
import '../../mian_screen/controller/main_controller.dart';
import 'notification_service.dart';

class CarNavigationController extends GetxController {
  // Map Controller
  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final NotificationService notificationService = NotificationService();

  // Radar Data
  final RxList<RadarModel> radars = <RadarModel>[].obs;
  final RxList<RadarModel> nearbyRadars = <RadarModel>[].obs;
  final Rx<RadarModel?> theNearestRadar = Rx<RadarModel?>(null);
  final _radarDistanceCache = <int, double>{};
  final _visibleRadarIndices = <int>[];

  // Location Services
  final Location location = Location();
  final Rx<LocationData?> currentLocation = Rx<LocationData?>(null);
  RxDouble? currentBearing;
  final RxBool isTracking = false.obs;
  Timer? _debounceTimer;

  // Speed Calculation
  final List<double> _speedHistory = [];
  final RxDouble filteredSpeed = 0.0.obs;

  // Icons
  BitmapDescriptor? carIcon;
  BitmapDescriptor? redRadarIcon;
  BitmapDescriptor? greenRadarIcon;
  final RxList<BitmapDescriptor> radarIcons = <BitmapDescriptor>[].obs;

  // Settings
  final RxDouble radarWarningDistance = 100.0.obs;
  final RxBool muteNotification = false.obs;
  bool isStartedVoice = false;
  // Add compass stream subscription
  StreamSubscription<CompassEvent>? _compassSubscription;
  final RxDouble compassHeading = 0.0.obs;

  @override
  void onInit() async {
    super.onInit();
    await notificationService.initialize();
    _initializeSettings();
    _startCompassListening();
    await _precacheIcons();
    await _initLocationService();
    await _enableBackgroundExecution(); // ⬅️ إضافة هذا السطر
    _createCarMarker();
    getAllRadar();
  }

  Future<void> _enableBackgroundExecution() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "🚗 تنبيه الرادار مفعل",
      notificationText: "يتم تتبع موقعك في الخلفية",
      enableWifiLock: true,
    );

    final hasPermissions = await FlutterBackground.hasPermissions;
    if (hasPermissions) {
      await FlutterBackground.initialize(androidConfig: androidConfig);
      await FlutterBackground.enableBackgroundExecution();
    } else {
      print('🚫 لا توجد صلاحيات لتفعيل الخلفية');
    }
  }

  Future<void> requestBackgroundPermission() async {
    // تأكد أولاً من أن صلاحية الموقع مفعلة

    final fineStatus = await await pri.Permission.location.request();
    if (fineStatus.isGranted) {
      // بعدها اطلب صلاحية الخلفية
      final bgStatus = await pri.Permission.locationAlways.request();
      if (bgStatus.isGranted) {
        print('✅ صلاحية الخلفية مفعلة');
      } else {
        print('🚫 لا توجد صلاحيات لتفعيل الخلفية');
      }
    } else {
      print('🚫 صلاحية الموقع غير مفعلة أصلاً');
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    mapController?.dispose();
    location.onLocationChanged.drain();
    super.onClose();
  }

  void _initializeSettings() {
    final prefUtils = Get.find<PrefUtils>();
    radarWarningDistance.value = prefUtils.getDistance();
    muteNotification.value = prefUtils.getMute();
  }

  void _startCompassListening() async {
    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        if (event.heading != null) {
          updateCompassHeading(event.heading!);
        }
      },
      onError: (e) => print("Compass error: $e"),
      cancelOnError: true,
    );
  }

  void _updateCarMarker() {
    if (currentLocation.value == null) return;

    // Find and remove existing car marker
    markers.removeWhere((m) => m.markerId.value == 'car');

    // Add new car marker with updated rotation
    markers.add(
      Marker(
        markerId: const MarkerId('car'),
        position: LatLng(
          currentLocation.value!.latitude!,
          currentLocation.value!.longitude!,
        ),
        rotation: compassHeading.value,
        icon: carIcon!,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        zIndex: 2,
      ),
    );
  }

  Future<void> _precacheIcons() async {
    final isDark = Get.find<MainController>().isDark.value;

    carIcon = await MarkerIcon.markerFromIcon(
      Icons.location_history,
      isDark ? Colors.white : Colors.black,
      150,
    );

    redRadarIcon = await MarkerIcon.markerFromIcon(
      Icons.radar,
      Colors.red,
      150,
    );

    greenRadarIcon = await MarkerIcon.markerFromIcon(
      Icons.radar,
      isDark ? Colors.white : Colors.green,
      150,
    );
  }

  Future<void> updateThemeIcons() async {
    await _precacheIcons();
    _updateRadarIcons();
    _updateMarkers();
  }

  Future<void> getAllRadar() async {
    try {
      final remoteDataSource = Get.find<RemoteDataSourceImpl>();
      final result = await remoteDataSource.getAllRadar();

      result.fold(
        (failure) {
          print('Error: ${failure.message}');
          Get.snackbar('Error', failure.message);
        },
        (data) {
          radars.assignAll(data);
          _initializeRadarIcons();
          _updateRadarDistances();
          _updateMarkers();
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load radar data');
    }
  }

  void _initializeRadarIcons() {
    radarIcons.assignAll(List.filled(radars.length, greenRadarIcon!));
  }

  Future<void> _initLocationService() async {
    try {
      await requestBackgroundPermission();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permission = await location.hasPermission();
      await location.enableBackgroundMode();
      var iswoek = await location.isBackgroundModeEnabled();
      print('work or not $iswoek');
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) return;
      }

      await location.changeSettings(
        interval: 100,
        accuracy: LocationAccuracy.high,
      );

      currentLocation.value = await location.getLocation();
      _startLocationUpdates();
      isTracking.value = true;
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Location services failed: $e');
    }
  }

  void _startLocationUpdates() {
    location.onLocationChanged.listen((LocationData locationData) {
      _processLocationUpdate(locationData);
    });
  }

  void _processLocationUpdate(LocationData locationData) {
    _processSpeedData(locationData);
    currentLocation.value = locationData;
    currentBearing?.value = locationData.heading ?? 0;

    /* if (_hasSignificantMovement(locationData)) {

    }*/
    _updateRadarDistances();
    _updateMarkers();
    updateCameraPosition();
    _updateCarMarker();
  }

  bool _hasSignificantMovement(LocationData newLocation) {
    if (currentLocation.value == null) return true;

    return geolocator.Geolocator.distanceBetween(
          currentLocation.value!.latitude!,
          currentLocation.value!.longitude!,
          newLocation.latitude!,
          newLocation.longitude!,
        ) >
        10;
  }

  void _processSpeedData(LocationData locationData) {
    if (locationData.speed == null) return;

    _speedHistory.add(locationData.speed! * 3.6);
    if (_speedHistory.length > 3) _speedHistory.removeAt(0);

    filteredSpeed.value =
        _speedHistory.reduce((a, b) => a + b) / _speedHistory.length;
  }

  void _updateRadarDistances() {
    if (currentLocation.value == null) return;
    _radarDistanceCache.clear();

    final currentLatLng = LatLng(
      currentLocation.value!.latitude!,
      currentLocation.value!.longitude!,
    );

    RadarModel? nearestRadar;
    double minDistance = double.infinity;

    for (int i = 0; i < radars.length; i++) {
      final distance = _calculateDistance(
        currentLatLng,
        LatLng(radars[i].geoPoint!.latitude, radars[i].geoPoint!.longitude),
      );

      _radarDistanceCache[i] = distance;
      radars[i].distance = distance;

      if (distance < minDistance) {
        minDistance = distance;
        nearestRadar = radars[i];
      }

      _updateRadarIcon(i, distance);
    }

    theNearestRadar.value = nearestRadar;
    nearbyRadars.value =
        radars.where((r) => r.distance! <= radarWarningDistance.value).toList();
    if (nearbyRadars.isEmpty) {
      {
        Get.find<CarNavigationController>().toggleSound = true;
        print('restore Sound');
      }
    }
  }

  void _updateRadarIcon(int index, double distance) {
    if (distance <= radarWarningDistance.value) {
      radarIcons[index] = redRadarIcon!;
      _triggerRadarWarning(radars[index]);
    } else {
      radarIcons[index] = greenRadarIcon!;
    }
  }

  void _updateRadarIcons() {
    for (int i = 0; i < radars.length; i++) {
      final distance =
          _radarDistanceCache[i] ??
          _calculateDistance(
            LatLng(
              currentLocation.value!.latitude!,
              currentLocation.value!.longitude!,
            ),
            LatLng(radars[i].geoPoint!.latitude, radars[i].geoPoint!.longitude),
          );

      _updateRadarIcon(i, distance);
    }
  }

  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playRadarAlertSound() async {
    try {
      await audioPlayer.play(AssetSource('sound/worry_vice.mp3'));
      print("✅ تم تشغيل الصوت المسجل بنجاح");
    } catch (e) {
      print("🚫 فشل في تشغيل الصوت: $e");
    }
  }

  bool toggleSound = true;

  Future<void> _triggerRadarWarning(RadarModel radar) async {
    if (muteNotification.value ||
        isStartedVoice ||
        filteredSpeed.value <= 0.0) {
      return;
    }

    isStartedVoice = true;
    if (toggleSound == true) {
    Vibration.vibrate(duration: 3000);
    /*TTSService.speak(
      'تنبيه! يوجد رادار سرعة قريب، الرجاء تخفيف السرعة والقيادة بحذر.',
    );*/

      playRadarAlertSound();
      notificationService.showBackgroundNotification(
        title: 'تنبيه رادار سرعة',
        body:
            'يوجد رادار سرعة ${radar.distance! < radarWarningDistance.value ? 'أقل من' : 'أكثر من'} ${radarWarningDistance.value.toInt()} متر منك، الرجاء تخفيف السرعة والقيادة بحذر.',
      );
      toggleSound = false;
    }

    /*  notificationService.showRadarSnackbar(
      'تنبيه رادار سرعة',
      'يوجد رادار سرعة قريب على بعد ${radar.distance!.toStringAsFixed(0)} متر',
    );*/
    Future.delayed(const Duration(seconds: 10), () {
      isStartedVoice = false;
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return geolocator.Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  void _updateMarkers() {
    if (currentLocation.value == null) return;

    final newMarkers = <Marker>{
      //    _createCarMarker(),
      ..._createVisibleRadarMarkers(),
    };

    markers.assignAll(newMarkers);
  }

  Marker _createCarMarker() {
    return Marker(
      markerId: const MarkerId('car'),
      position: LatLng(
        currentLocation.value!.latitude!,
        currentLocation.value!.longitude!,
      ),
      rotation: currentBearing?.value ?? 0,
      icon: carIcon!,
      infoWindow: const InfoWindow(title: 'موقعك الحالي'),
      anchor: const Offset(0.5, 0.5),
      flat: true,
      zIndex: 2,
    );
  }

  double _smoothedHeading = 0.0;

  void updateCompassHeading(double newHeading) {
    const double smoothingFactor = 0.1; // lower = smoother
    _smoothedHeading =
        (_smoothedHeading * (1 - smoothingFactor)) +
        (newHeading * smoothingFactor);

    compassHeading.value = _smoothedHeading % 360;
  }

  double getCameraBearing() {
    if (currentLocation.value?.speed != null &&
        currentLocation.value!.speed! > 2.0 &&
        currentLocation.value?.heading != null) {
      return currentLocation.value!.heading!; // GPS-based direction
    } else {
      return compassHeading.value;
    }
    return compassHeading.value;
  }

  Set<Marker> _createVisibleRadarMarkers() {
    final markers = <Marker>{};
    final currentPos = LatLng(
      currentLocation.value!.latitude!,
      currentLocation.value!.longitude!,
    );

    for (int i = 0; i < radars.length; i++) {
      /* if (_shouldShowRadar(i, currentPos)) {
        markers.add(
          Marker(
            markerId: MarkerId('radar$i'),
            position: LatLng(
              radars[i].geoPoint!.latitude,
              radars[i].geoPoint!.longitude,
            ),
            icon: radarIcons[i],
            infoWindow: InfoWindow(title: radars[i].name, snippet: radars[i].address),
            anchor: const Offset(0.5, 0.5),
            flat: true,
            zIndex: 2,
          ),
        );
      }*/
      markers.add(
        Marker(
          markerId: MarkerId('radar$i'),
          position: LatLng(
            radars[i].geoPoint!.latitude,
            radars[i].geoPoint!.longitude,
          ),
          icon: radarIcons[i],
          infoWindow: InfoWindow(
            title: radars[i].name,
            snippet: radars[i].address,
          ),
          anchor: const Offset(0.5, 0.5),
          flat: true,
          zIndex: 2,
        ),
      );
    }

    return markers;
  }

  bool _shouldShowRadar(int index, LatLng currentPos) {
    final distance =
        _radarDistanceCache[index] ??
        _calculateDistance(
          currentPos,
          LatLng(
            radars[index].geoPoint!.latitude,
            radars[index].geoPoint!.longitude,
          ),
        );

    return distance < 2000;
  }

  void updateCameraPosition() {
    if (currentLocation.value == null || mapController == null) return;

    final position = currentLocation.value!;
    final bearing = getCameraBearing();

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude!, position.longitude!),
          zoom: 16,
          bearing: bearing,
        ),
      ),
      duration: const Duration(milliseconds: 100),
    );
  }

  void centerMapOnLocation() {
    if (currentLocation.value != null) {
      updateCameraPosition();
    }
  }

  void setSilverTheme() {
    mapController?.setMapStyle(null);
    updateThemeIcons();
  }

  void setNightTheme() {
    const nightTheme = '''
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
    updateThemeIcons();
  }

  void changeRadarWarningDistance(double distance) {
    radarWarningDistance.value = distance;
    Get.find<PrefUtils>().setDistance(distance);
    _updateRadarDistances();
    _updateMarkers();
  }

  void toggleMuteNotification() {
    muteNotification.value = !muteNotification.value;
    Get.find<PrefUtils>().setMute(muteNotification.value);
  }
}
