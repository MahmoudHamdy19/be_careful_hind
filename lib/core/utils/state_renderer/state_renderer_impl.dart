 import 'package:be_careful_hind/core/utils/state_renderer/state_renderer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_export.dart';
import '../app_strings.dart';

abstract class FlowState {
  StateRendererType getStateRendererType();
  String getMessage();
}

class LoadingState extends FlowState {
  final StateRendererType stateRendererType;
  final String message;

  LoadingState({
    required this.stateRendererType,
    this.message =  'جار التحميل',
  });

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => stateRendererType;
}

class ErrorState extends FlowState {
  final StateRendererType stateRendererType;
  final String message;

  ErrorState(this.stateRendererType, this.message);

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => stateRendererType;
}

class SuccessState extends FlowState {
  final StateRendererType stateRendererType;
  final String message;

  SuccessState(this.stateRendererType, this.message);

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => stateRendererType;
}

class ContentState extends FlowState {
  @override
  String getMessage() => '';

  @override
  StateRendererType getStateRendererType() => StateRendererType.contentState;
}

class EmptyState extends FlowState {
  final String message;

  EmptyState(this.message);

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => StateRendererType.fullScreenEmptyState;
}

extension FlowStateExtension on FlowState {
  Widget getScreenWidget(Widget contentScreenWidget, Function retryActionFunction) {
    dismissDialog();

    if (this is LoadingState) {
      return _handleState(contentScreenWidget, retryActionFunction, StateRendererType.popupLoadingState);
    } else if (this is ErrorState) {
      return _handleState(contentScreenWidget, retryActionFunction, StateRendererType.popupErrorState);
    } else if (this is SuccessState) {
      return _handleState(contentScreenWidget, retryActionFunction, StateRendererType.popupSuccessState);
    } else if (this is EmptyState) {
      return StateRenderer(
        stateRendererType: getStateRendererType(),
        message: getMessage(),
        retryActionFunction: retryActionFunction,
      );
    } else {
      return contentScreenWidget;
    }
  }

  Widget _handleState(Widget contentScreenWidget, Function retryActionFunction, StateRendererType popupType) {
    if (getStateRendererType() == popupType) {
      _showPopup(getStateRendererType(), getMessage(), retryActionFunction);
      return contentScreenWidget;
    } else {
      return StateRenderer(
        message: getMessage(),
        stateRendererType: getStateRendererType(),
        retryActionFunction: retryActionFunction,
      );
    }
  }

  bool _isCurrentDialogShowing() => Get.isOverlaysOpen;

  void dismissDialog() {
    if (_isCurrentDialogShowing()) {
      Get.back();
    }
  }

  void _showPopup(StateRendererType stateRendererType, String message, Function retryActionFunction) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isCurrentDialogShowing()) {
        Get.dialog(
          barrierDismissible: false,
          StateRenderer(
            stateRendererType: stateRendererType,
            message: message,
            retryActionFunction: retryActionFunction,
          ),
        );
      }
    });
  }
}