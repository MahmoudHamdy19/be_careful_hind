import 'package:be_careful_hind/core/utils/state_renderer/state_renderer.dart';
import 'package:be_careful_hind/core/utils/state_renderer/state_renderer_impl.dart';
import 'package:be_careful_hind/data/remote_data_source/remote_data_source.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/Radar_model.dart';
import '../../navigation_map/controller/car_navigation_controller.dart';

class AddLocationController extends GetxController {
  final RemoteDataSource _remoteDataSource = Get.find<RemoteDataSourceImpl>();
  final formKey = GlobalKey<FormState>();
  final cityEditingController = TextEditingController();
  final latEditingController = TextEditingController();
  final longEditingController = TextEditingController();
  final radarEditingController = TextEditingController();
  final speedEditingController = TextEditingController();

  Rx<FlowState> flowState = Rx<FlowState>(
    LoadingState(stateRendererType: StateRendererType.fullScreenLoadingState),
  );
  RxList<RadarModel> radars = RxList<RadarModel>([]);
  @override
  void onInit() {
    getAllRadar();
     super.onInit();
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
      (r) {
        radars.value = r;
        flowState.value = ContentState();
      },
    );
  }

  addRadar(RadarModel radar) async {
    Get.find<CarNavigationController>().getAllRadar();
    flowState.value = LoadingState(
      stateRendererType: StateRendererType.fullScreenLoadingState,
    );
    (await _remoteDataSource.addRadar(radar)).fold(
      (l) {
        flowState.value = ErrorState(
          StateRendererType.fullScreenErrorState,
          l.message,
        );
      },
      (r) {
        _cleanControllers();
        getAllRadar();
      },
    );
  }
_cleanControllers() {
    cityEditingController.clear();
    latEditingController.clear();
    longEditingController.clear();
    radarEditingController.clear();
    speedEditingController.clear();
}
  editRadar(String id, RadarModel newRadarData) async {
    flowState.value = LoadingState(
      stateRendererType: StateRendererType.fullScreenLoadingState,
    );
    (await _remoteDataSource.editRadar(id, newRadarData)).fold(
      (l) {
        flowState.value = ErrorState(
          StateRendererType.fullScreenErrorState,
          l.message,
        );
      },
      (r) {
        getAllRadar();
      },
    );
  }
  deleteRadar(String id) async {
    flowState.value = LoadingState(
      stateRendererType: StateRendererType.fullScreenLoadingState,
    );
    (await _remoteDataSource.deleteRadar(id)).fold(
      (l) {
        flowState.value = ErrorState(
          StateRendererType.fullScreenErrorState,
          l.message,
        );
      },
      (r) {
        getAllRadar();
      },
    );
  }
}
