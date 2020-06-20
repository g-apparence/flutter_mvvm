import 'package:flutter/widgets.dart';

class MvvmContext {
  final BuildContext buildContext;
  final AnimationController animationController;
  final List<AnimationController> animationsControllers;

  MvvmContext(
    this.buildContext, {
    this.animationController,
    this.animationsControllers,
  });
}
