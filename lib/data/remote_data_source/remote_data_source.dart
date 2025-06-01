import 'package:be_careful_hind/core/app_export.dart';
import 'package:be_careful_hind/core/errors/error_handler.dart';
import 'package:be_careful_hind/core/errors/failure.dart';
import 'package:be_careful_hind/data/models/Radar_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, void>> addRadar(RadarModel radar);
  void autoAddRadarS();
  Future<Either<Failure, List<RadarModel>>> getAllRadar();
  Future<Either<Failure, void>> editRadar(String id, RadarModel newRadarData);
  Future<Either<Failure, void>> deleteRadar(String id);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  FirebaseFirestore _firestore;
  NetworkInfo _networkInfo;
  RemoteDataSourceImpl(this._firestore, this._networkInfo);
  @override
  Future<Either<Failure, void>> addRadar(RadarModel radar) async {
    try {
      if (await _networkInfo.isConnected()) {
        await _firestore.collection('radars').add(radar.toMap());
        return const Right(null);
      } else {
        return Left(
          ErrorHandler.handle(DataSource.NO_INTERNET_CONNECTION).failure,
        );
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()).failure);
    }
  }

  @override
  Future<Either<Failure, void>> editRadar(
    String id,
    RadarModel newRadarData,
  ) async {
    try {
      if (await _networkInfo.isConnected()) {
        await _firestore
            .collection('radars')
            .doc(id)
            .update(newRadarData.toMap());
        return const Right(null);
      } else {
        return Left(
            DataSource.NO_INTERNET_CONNECTION.getFailure()
        );
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()).failure);
    }
  }

  @override
  Future<Either<Failure, List<RadarModel>>> getAllRadar() async {
    try {
      if (await _networkInfo.isConnected()) {
        List<RadarModel> radars = [];
        QuerySnapshot querySnapshot =
            await _firestore.collection('radars').get();
        for (var element in querySnapshot.docs) {
          var radar = RadarModel.fromMap(
            element.data() as Map<String, dynamic>,
          );
          List<Placemark> placemarks = [];
         await placemarkFromCoordinates(
            radar.geoPoint?.latitude ?? 0.0,
            radar.geoPoint?.longitude ?? 0.0,
          ).then((value) {
            placemarks = value;
            if (placemarks.isNotEmpty) {
              Placemark place = placemarks[0];
              var text =
                  '${place.subLocality},${place.locality} ,${place.administrativeArea}, ${place.country}';
              print('address $text');
              radar.address =
                  text;
            }
          });
          radar.uid = element.id;
          radars.add(radar);
        }
        return Right(radars);
      } else {
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()).failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteRadar(String id) async {
    try {
      if (await _networkInfo.isConnected()) {
        await _firestore.collection('radars').doc(id).delete();
        return const Right(null);
      } else {
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()).failure);
    }
  }

  @override
  void autoAddRadarS() async{
     for (int i = 0; i < coordinates.length; i++) {
      var radar = RadarModel();
      radar.geoPoint = GeoPoint(coordinates[i].latitude, coordinates[i].longitude);
      radar.name = 'Radar ${i + 1}';
      List<Placemark> placemarks = [];
      await placemarkFromCoordinates(
      radar.geoPoint?.latitude ?? 0.0,
      radar.geoPoint?.longitude ?? 0.0,
      ).then((value) {
        placemarks = value;
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          var text =
              '${place.subLocality},${place.locality} ,${place.administrativeArea}, ${place.country}';
          print('address $text');
          radar.address =
              text;
          radar.city = place.locality;
        }
      });
      radar.speed = 90.0 ;
      await addRadar(radar);
    }
  }
}
final List<LatLng> coordinates = [
  LatLng(28.3893667, 36.4494167),
  LatLng(28.3670833, 36.4687),
  LatLng(28.3682, 36.4711),
  LatLng(28.3688, 36.4726),
  LatLng(28.3737, 36.4798),
  LatLng(28.3774, 36.4903),
  LatLng(28.3787, 36.4931),
  LatLng(28.3852, 36.5095),
  LatLng(28.3873, 36.5125),
  LatLng(28.39375, 36.5215833),
  LatLng(28.3966833, 36.52535),
  LatLng(28.401, 36.5406833),
  LatLng(28.4101167, 36.5438833),
  LatLng(28.38585, 36.5447333),
  LatLng(28.4117, 36.5496333),
  LatLng(28.3934, 36.5498),
  LatLng(28.3934333, 36.5498),
  LatLng(28.41175, 36.5502),
  LatLng(28.3927, 36.5504),
  LatLng(28.3898333, 36.5841333),
  LatLng(28.3843333, 36.5914667),
  LatLng(28.4023889, 36.5936944),
];