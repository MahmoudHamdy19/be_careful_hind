import 'package:cloud_firestore/cloud_firestore.dart';

class RadarModel {
  String? uid;
  String? city;
  String? name;
  GeoPoint? geoPoint;
  double? speed;
  double? distance;
  String? address;

  RadarModel({this.uid, this.city, this.name, this.geoPoint, this.speed});

  factory RadarModel.fromMap(Map<String, dynamic> map) {
    return RadarModel(
      uid: map['uid'] as String?,
      city: map['city'] as String?,
      name: map['name'] as String?,
      geoPoint: map['geoPoint'] as GeoPoint?,
      speed: map['speed'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'city': city,
      'name': name,
      'geoPoint': geoPoint,
      'speed': speed,
    };
  }


}