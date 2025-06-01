import 'package:be_careful_hind/core/app_export.dart';
import 'package:be_careful_hind/core/utils/state_renderer/state_renderer_impl.dart';
import 'package:flutter/material.dart';
 import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../mian_screen/controller/main_controller.dart';
import 'controller/car_navigation_controller.dart';

 
class CarNavigationScreen extends GetView<CarNavigationController> {
  const CarNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>controller.flowState.value.getScreenWidget(_body(context), (){
          if(controller.flowState.value is ErrorState){
            controller.getAllRadar();
          }
          else{
            controller.flowState.value = ContentState();
          }
        }),
      ),
    );
  }

  _body(context)=>Stack(
    children: [
      // Google Map Widget
      Obx(() => GoogleMap(
        mapType: MapType.normal,
        buildingsEnabled:false,
        onMapCreated: (controller) {
          this.controller.mapController = controller;
          if ( this.controller.currentLocation.value != null && this.controller.mapController != null) {
            this.controller.updateCameraPosition();
          }
          print('ready');
          this.controller.updateThemeIcon();

          if(Get.find<MainController>().isDark.value){
              this.controller.setNightTheme();
            } else{
              this.controller.setSilverTheme();
            }

        },
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 19,
        ),
        markers: controller.currentLocation.value != null && controller.carIcon != null
            ? {
          Marker(
            markerId: MarkerId('car'),
            position: LatLng(
              controller.currentLocation.value!.latitude!,
              controller.currentLocation.value!.longitude!,
            ),
            rotation: controller.currentBearing?.value ?? 0,
            icon: controller.carIcon!,
            anchor: Offset(0.5, 0.5),
            flat: true,
            zIndex: 2,
          ),
          for(var i = 0; i < controller.radars.length; i++)
            Marker(
              markerId: MarkerId('radar$i'),
              infoWindow: InfoWindow(title: controller.radars[i].name, snippet: controller.radars[i].distance.toString()),
              position: LatLng(
                controller.radars[i].geoPoint?.latitude??00.0,
                controller.radars[i].geoPoint?.longitude??00.0,
              ),
              icon: controller.radarIcons[i],
              anchor: Offset(0.5, 0.5),
              flat: true,
              zIndex: 2,
            ),
        }
            : {},
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
      )),

      // Speedometer Widget
      Positioned(
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
                offset: Offset(0.0, 3.0),
              ),
            ],
          ),
          child: Obx(() => SfRadialGauge(
            enableLoadingAnimation: true,
            axes: [
              RadialAxis(
                minimum: 0,
                maximum: 220,
                showLabels: false,
                showTicks: false,
                annotations: [
                  GaugeAnnotation(
                    widget: Obx(
                      () => Text(
                        '${controller.filteredSpeed.value.toStringAsFixed(1)} km/h',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: (controller.theNearestRadar.value?.speed??0.0) <= controller.filteredSpeed.value ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.8,
                  ),
                ],
                axisLineStyle: AxisLineStyle(
                  thickness: 0.2,
                  thicknessUnit: GaugeSizeUnit.factor,
                  color: theme.primaryColor,
                ),
                ranges: [
                  GaugeRange(
                    startValue: 0,
                    endValue: 40,
                    color: theme.primaryColor,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                  GaugeRange(
                    startValue: 42,
                    endValue: 80,
                    color: theme.primaryColor,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                  GaugeRange(
                    startValue: 82,
                    endValue: 120,
                    color: theme.primaryColor,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                  GaugeRange(
                    startValue: 122,
                    endValue: 160,
                    color: theme.primaryColor,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                  GaugeRange(
                    startValue: 162,
                    endValue: 200,
                    color: theme.primaryColor,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                  GaugeRange(
                    startValue: 202,
                    endValue: 220,
                    color: theme.primaryColor,
                    startWidth: 10,
                    endWidth: 10,
                  ),
                ],
                pointers: [
                  NeedlePointer(
                    value: controller.filteredSpeed.value,
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
                  )
              ),
            ],
          )),
        ),
      ),

      // Notification Widget
      Positioned(
        top: 20,
        left: 20,
        child: GestureDetector(
          onTap: () {
            if(controller.nearbyRadars.isNotEmpty){
              Get.bottomSheet(
                controller.nearbyRadarBottomSheet(),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              );
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                 ImageConstant.notification,
                color:Get.find<MainController>().isDark.value ? Colors.white :null,
                height: 150,
                width: 150,
              ),
              Obx(
                () => Text(
                  '${controller.nearbyRadars.length}',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.white,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.white,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.white,
                        offset: Offset(0, 0),
                      ),
                    ],
                    fontSize: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // GPS Status Indicator
      Obx(() => !controller.isTracking.value
          ? Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.gps_not_fixed, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Acquiring GPS...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      )
          : SizedBox.shrink()),

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
  );
}