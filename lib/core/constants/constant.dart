
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../widgets/location_picker_dialog.dart';

bool passwordValidation (String password){
  RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  return regex.hasMatch(password);

}

bool emailValidation(String email){
  RegExp regex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
  return regex.hasMatch(email);
}
bool accountNumberValidation(String accountNumber){
  RegExp regex = RegExp(r'^\d{14}$');
  return regex.hasMatch(accountNumber);
}

bool ibanValidation(String iban){
  RegExp regex = RegExp(r'^[0-9]{22}$');
  return regex.hasMatch(iban);
}
bool phoneValidation(String phone){
  RegExp regex = RegExp(r'^5\d{8}$');
  return regex.hasMatch(phone);
}

bool nameValidation(String name){
  RegExp regex = RegExp(r'^[a-zA-Z]+$');
  return regex.hasMatch(name);
}

Future<LatLng?> showLocationPicker({
  required BuildContext context,
  LatLng? initialPosition,
}) async {
  return await showDialog<LatLng>(
    context: context,
    builder: (context) => LocationPickerDialog(
      initialPosition: initialPosition,
    ),
  );
}


bool isMarkerInFront({
  required LatLng userLocation,
  required double userHeading, // degrees from 0 to 360
  required LatLng markerLocation,
  double frontAngleThreshold = 45, // how wide the "forward cone" is
}) {
  double getBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * (pi / 180);
    double lon1 = start.longitude * (pi / 180);
    double lat2 = end.latitude * (pi / 180);
    double lon2 = end.longitude * (pi / 180);

    double dLon = lon2 - lon1;
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360; // Normalize to 0–360
  }

  double bearingToMarker = getBearing(userLocation, markerLocation);
  double angleDifference = (bearingToMarker - userHeading + 360) % 360;

  return angleDifference < frontAngleThreshold || angleDifference > (360 - frontAngleThreshold);
}


LatLng extractLatLngFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final regex = RegExp(r'@([-.\d]+),([-.\d]+)');

    final match = regex.firstMatch(uri.toString());
    if (match != null && match.groupCount == 2) {
      String latitude = match.group(1)!;
      String longitude = match.group(2)!;
      //return 'Latitude: $latitude, Longitude: $longitude';
      return LatLng(double.parse(latitude), double.parse(longitude));
    } else {
      throw 'Coordinates not found in the URL';
    }
  } catch (e) {
    throw 'Error parsing URL: $e';
  }
}


