import 'package:e_leaningapp/export/curriculum_export.dart';
import 'package:flutter/material.dart';
import '../widgets/loadings/custom_cirular_progress_indicator.dart';

void configEasyLoading() {
  EasyLoading.instance
    ..textColor = Colors.white
    ..backgroundColor = Colors.black
    ..progressColor = Colors.white
    ..indicatorWidget = customCirularProgress()
    ..boxShadow = <BoxShadow>[]
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorColor = Colors.blue
    ..maskColor = Colors.black.withOpacity(.3)
    ..maskType = EasyLoadingMaskType.custom
    ..radius = 10
    ..indicatorSize = 70
    ..loadingStyle = EasyLoadingStyle.custom
    ..userInteractions = false
    ..dismissOnTap = true;
}
