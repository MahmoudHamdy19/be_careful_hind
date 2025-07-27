import 'package:be_careful_hind/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:get/get.dart';

import '../mian_screen/controller/main_controller.dart';
import 'controller/car_navigation_controller.dart';

class CarNavigationScreen extends GetView<CarNavigationController> {
  const CarNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Optimized Google Map Widget
          _buildMapWidget(context),

          // Speedometer Widget (optimized rebuilds)
          /*   Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 150.0,
              height: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 3.0),
                  ),
                ],
              ),
              child: Obx(() => _buildSpeedometer(context)),
            ),
          ),*/

          // Notification Widget (optimized)
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: () => _showRadarBottomSheet(),
              child: Obx(() => _buildNotificationIcon()),
            ),
          ),

          // GPS Status Indicator (optimized)
          Obx(
                () =>
            controller.isTracking.value
                ? const SizedBox.shrink()
                : Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              child: _buildGpsStatusIndicator(),
            ),
          ),

          // Recenter Button
          Positioned(
            right: 20,
            bottom: 50,
            child: FloatingActionButton(
              mini: true,
              onPressed: controller.centerMapOnLocation,
              backgroundColor: Colors.white,
              child: Icon(Icons.navigation, color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // Extracted Widget Builders for better readability and performance

  Widget _buildMapWidget(BuildContext context) {
    return Obx(() {
      // Minimal rebuild - only when markers change
      return GoogleMap(
        mapType: MapType.normal,
        buildingsEnabled: false,
        onMapCreated: (controller) => _onMapCreated(controller),
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 19,
        ),
        markers: controller.markers.value,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,

        onCameraMove: (position) {
          // Optional: Implement viewport-based marker filtering
          // controller.updateVisibleMarkers(position.visibleRegion.bounds);
        },
      );
    });
  }
  void _onMapCreated(GoogleMapController mapController) {
    controller.mapController = mapController;
    if (controller.currentLocation.value != null) {
      controller.updateCameraPosition();
    }

    // Set initial theme
    if (Get.find<MainController>().isDark.value) {
      controller.setNightTheme();
    } else {
      controller.setSilverTheme();
    }
  }

  Widget _buildSpeedometer(BuildContext context) {
    final nearestRadarSpeed = controller.theNearestRadar.value?.speed ?? 0.0;
    final currentSpeed = controller.filteredSpeed.value;

    return SfRadialGauge(
      enableLoadingAnimation: true,
      axes: [
        RadialAxis(
          minimum: 0,
          maximum: 220,
          showLabels: false,
          showTicks: false,
          annotations: [
            GaugeAnnotation(
              widget: Text(
                '${currentSpeed.toStringAsFixed(1)} km/h',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color:
                  nearestRadarSpeed <= currentSpeed
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              angle: 90,
              positionFactor: 0.8,
            ),
          ],
          axisLineStyle: const AxisLineStyle(
            thickness: 0.2,
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          ranges: _buildSpeedRanges(),
          pointers: [
            NeedlePointer(
              value: currentSpeed,
              enableAnimation: true,
              animationType: AnimationType.ease,
              needleLength: 0.7,
              needleColor: theme.primaryColor,
              knobStyle: KnobStyle(
                color: Colors.white,
                borderWidth: 0.08,
                borderColor: theme.primaryColor,
                sizeUnit: GaugeSizeUnit.factor,
              ),
              needleStartWidth: 1,
              needleEndWidth: 8,
            ),
          ],
        ),
        RadialAxis(
          minimum: 0,
          maximum: 200,
          showLabels: false,
          showTicks: true,
          majorTickStyle: MajorTickStyle(
            color: Colors.white,
            length: 20,
            thickness: 5,
          ),
          minorTickStyle: MinorTickStyle(
            color: Colors.white,
            length: 20,
            thickness: 5,
          ),
          minorTicksPerInterval: 2,
          tickOffset: -10,
          ticksPosition: ElementsPosition.inside,
          axisLineStyle: AxisLineStyle(
            thickness: 0.1,
            thicknessUnit: GaugeSizeUnit.factor,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  List<GaugeRange> _buildSpeedRanges() {
    return [
      GaugeRange(startValue: 0, endValue: 40, color: theme.primaryColor),
      GaugeRange(startValue: 40, endValue: 80, color: theme.primaryColor),
      GaugeRange(startValue: 80, endValue: 120, color: theme.primaryColor),
      GaugeRange(startValue: 120, endValue: 160, color: theme.primaryColor),
      GaugeRange(startValue: 160, endValue: 200, color: theme.primaryColor),
      GaugeRange(startValue: 200, endValue: 220, color: theme.primaryColor),
    ]
        .map(
          (range) => GaugeRange(
        startValue: range.startValue,
        endValue: range.endValue,
        color: range.color,
        startWidth: 10,
        endWidth: 10,
      ),
    )
        .toList();
  }

  Widget _buildNotificationIcon() {
    final isDark = Get.find<MainController>().isDark.value;
    final nearbyCount = controller.nearbyRadars.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          ImageConstant.notification,
          color: isDark ? Colors.white : null,
          height: 150,
          width: 150,
        ),
        Text(
          '$nearbyCount' ,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(blurRadius: 5.0, color: Colors.white),
              Shadow(blurRadius: 5.0, color: Colors.white),
              Shadow(blurRadius: 5.0, color: Colors.white),
            ],
            fontSize: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildGpsStatusIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.gps_not_fixed, color: Colors.orange),
          SizedBox(width: 8),
          Text('Acquiring GPS...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showRadarBottomSheet() {
    if (controller.nearbyRadars.isNotEmpty) {
      Get.bottomSheet(
        _buildRadarBottomSheet(),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );
    }
  }

  Widget _buildRadarBottomSheet() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor.withAlpha(200),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.nearbyRadars.length,
                itemBuilder: (context, index) => _buildRadarListItem(index),
                separatorBuilder:
                    (context, index) =>
                const Divider(color: Colors.white, height: 20.0),
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

  Widget _buildRadarListItem(int index) {
    final radar = controller.nearbyRadars[index];
    final distance = radar.distance?.round() ?? 0.0;
    final distanceText =
    distance > 1000
        ? '${(distance / 1000).toStringAsFixed(1)} كم بعيد جدا'
        : '$distance م';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.radar, color: Colors.orangeAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              'الرادار: ${radar.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.map, color: Colors.orangeAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              'المسافة: $distanceText',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.speed, color: Colors.orangeAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              'السرعة المسموحة: ${radar.speed} كم/ساعة',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
