import 'package:flutter/material.dart';
import '../models/success_model.dart';

class SuccessController extends ChangeNotifier {
  final SuccessModel _model;
  final VoidCallback? _onButtonPressed;

  SuccessController({
    SuccessModel? model,
    VoidCallback? onButtonPressed,
  }) : _model = model ?? SuccessModel(),
       _onButtonPressed = onButtonPressed;

  // Getters
  SuccessModel get model => _model;

  void handleContinue() {
    if (_onButtonPressed != null) {
      _onButtonPressed!();
    }
  }
}