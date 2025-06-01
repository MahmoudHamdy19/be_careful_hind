import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/remote_data_source/remote_data_source.dart';
import '../app_export.dart';
import '../network/network_info.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PrefUtils());
    Connectivity connectivity = Connectivity();
    Get.put(NetworkInfo(connectivity));
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Get.put(RemoteDataSourceImpl(firestore, Get.find<NetworkInfo>()));
  }
}
