import 'package:be_careful_hind/core/app_export.dart';
import 'package:be_careful_hind/core/constants/constant.dart';
import 'package:be_careful_hind/core/utils/state_renderer/state_renderer_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/models/Radar_model.dart';
import 'controller/add_location_controller.dart';
import 'package:geocoding/geocoding.dart';

class AddLocationScreen extends GetWidget<AddLocationController> {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf1eee7),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(
          () => controller.flowState.value.getScreenWidget(_body(), () {
            if (controller.flowState.value is ErrorState) {
              controller.getAllRadar();
            } else {
              controller.flowState.value = ContentState();
            }
          }),
        ),
      ),
    );
  }

  _body() => SingleChildScrollView(
    padding: const EdgeInsets.all(30.0),
    child: Column(
      spacing: 20.0,
      children: [
        GestureDetector(
          onTap: () {
            _addLocation();
          },
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                spacing: 10.0,
                children: [
                  FractionallySizedBox(
                    heightFactor: 1.5,
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(ImageConstant.location_2),
                  ),
                  Expanded(
                    child: Text(
                      "اضافة رادار جديد",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.radars.length,
          itemBuilder:
              (context, index) => GestureDetector(
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: SizedBox(
                            height: 250,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "اختر",
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text("تعديل"),
                                    onTap: () {
                                      controller.cityEditingController.text =
                                          controller.radars[index].city ?? "";
                                      controller.latEditingController.text =
                                          controller.radars[index].geoPoint?.latitude
                                              .toString()
                                              ??
                                              "";
                                      controller.longEditingController.text =
                                          controller.radars[index].geoPoint?.longitude
                                              .toString()
                                               ??
                                              "";
                                      controller.radarEditingController.text =
                                          controller.radars[index].name ?? "";
                                      controller.speedEditingController.text =
                                          controller.radars[index].speed
                                              .toString();


                                      _addLocation(isUpdate: true,updatedRadar: controller.radars[index]);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text("حذف"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      controller.deleteRadar(
                                        controller.radars[index].uid ?? "",
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(color: theme.colorScheme.primary),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10.0,
                            children: [
                              Text(
                                controller.radars[index].name ?? "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              _item(
                                ImageConstant.buildings,
                                'المدينة :${controller.radars[index].city}',
                              ),
                              _item(
                                ImageConstant.location_icon,
                                'الموقع:${controller.radars[index].address}',
                              ),
                              _item(
                                ImageConstant.speedIcon,
                                'السرعه المحدده:${controller.radars[index].speed} km/h',
                              ),
                            ],
                          ),
                        ),
                        Image.asset(ImageConstant.oldCamVideo, height: 100),
                      ],
                    ),
                  ),
                ),
              ),
          separatorBuilder: (context, index) => const SizedBox(height: 20.0),
        ),
      ],
    ),
  );
  _item(String icon, String title) => Row(
    spacing: 10.0,
    children: [
      Image.asset(icon, height: 25),
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ],
  );

  _addLocation({bool isUpdate = false,RadarModel? updatedRadar}) async {
    return showDialog<void>(
      context: Get.context!,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('إضافة موقع جديد'),
            content: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: controller.radarEditingController,
                      decoration: InputDecoration(hintText: 'رادار'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'يرجى ادخال اسم رادار';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: controller.cityEditingController,
                      decoration: InputDecoration(hintText: 'اسم المدينة'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'يرجى ادخال اسم المدينة';
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Text(
                            'الموقع',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                         /* IconButton(
                            onPressed: () {
                              showLocationPicker(context: context).then((
                                value,
                              ) {
                                if (value != null) {
                                  controller.latEditingController.text =
                                      value.latitude.toString();
                                  controller.longEditingController.text =
                                      value.longitude.toString();
                                  List<Placemark> placemarks = [];
                                  placemarkFromCoordinates(
                                    value.latitude,
                                    value.longitude,
                                  ).then((value) {
                                    placemarks = value;
                                    if (placemarks.isNotEmpty) {
                                      Placemark place = placemarks[0];
                                      var text =
                                          '${place.subLocality},${place.locality}';
                                      print('address $text');
                                      controller.cityEditingController.text =
                                          text;
                                    }
                                  });
                                }
                              });
                            },
                            icon: Icon(Icons.location_on_outlined),
                          ),*/
                        ],
                      ),
                    ),
                    TextFormField(
                       decoration: InputDecoration(hintText: '  لينك '),
                      validator: (value) {
                        if (controller.latEditingController.text.isEmpty || controller.longEditingController.text.isEmpty) {
                          return 'يرجى ادخال لينك صالح';
                        }
                        return null;
                      },
                      onChanged: (value) {
                      try {
                        var latlong = extractLatLngFromUrl(value);
                        controller.latEditingController.text = latlong.latitude.toString();
                        controller.longEditingController.text = latlong.longitude.toString();
                      } catch (e) {
                         controller.latEditingController.clear();
                        controller.longEditingController.clear();                       }
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.latEditingController,
                              decoration: InputDecoration(
                                border:  InputBorder.none
                              ),
                           readOnly: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: TextFormField(
                              controller: controller.longEditingController,
                              decoration: InputDecoration(
                              border:  InputBorder.none),
                              readOnly: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: controller.speedEditingController,
                      decoration: InputDecoration(hintText: 'السرعة المحددة'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'يرجى ادخال سرعة المحددة';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: theme.primaryColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
               isUpdate ? 'تعديل' :   'إضافة',
                  style: TextStyle(color: theme.primaryColor),
                ),
                onPressed: () {
                  if (controller.formKey.currentState!.validate()) {

                    if(isUpdate && updatedRadar != null){
                      updatedRadar.name = controller.radarEditingController.text;
                      updatedRadar.city = controller.cityEditingController.text;
                      updatedRadar.geoPoint = GeoPoint(
                        double.parse(controller.latEditingController.text),
                        double.parse(controller.longEditingController.text),
                      );
                      updatedRadar.speed = double.parse(
                        controller.speedEditingController.text,
                      );
                      controller.editRadar(
                        updatedRadar.uid ?? "",
                        updatedRadar,
                      );
                     }else{
                      var radar = RadarModel(
                        name: controller.radarEditingController.text,
                        city: controller.cityEditingController.text,
                        geoPoint: GeoPoint(
                          double.parse(controller.latEditingController.text),
                          double.parse(controller.longEditingController.text),
                        ),
                        speed: double.parse(
                          controller.speedEditingController.text,
                        ),
                      );
                      controller.addRadar(radar);
                    }
                    Get.back();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
