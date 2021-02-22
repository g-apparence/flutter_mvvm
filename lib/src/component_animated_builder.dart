import 'package:flutter/material.dart';

import 'component_builder.dart';
import 'mvvm_context.dart';
import 'mvvm_model.dart';
import 'presenter_builder.dart';

/// -----------------------------------------------
/// SINGLE ANIMATION CONTENT WIDGET
/// should extends MVVMContent but dartlang extends Generics bug
/// -----------------------------------------------
class AnimatedMvvmContent<P extends Presenter, M extends MVVMModel>
    extends MVVMContent {
  final MvvmAnimationControllerBuilder? singleAnimController;
  final MvvmAnimationListener<P, M>? animListener;

  AnimatedMvvmContent({
    Key? key,
    required this.singleAnimController,
    this.animListener,
  }) : super(key: key);

  @override
  State<MVVMContent> createState() =>
      _MVVMSingleTickerProviderContentState<P, M>(animListener);
}

class _MVVMSingleTickerProviderContentState<P extends Presenter,
        M extends MVVMModel> extends State<AnimatedMvvmContent>
    with SingleTickerProviderStateMixin
    implements MVVMView {
  AnimationController? _controller;
  bool hasInit = false;
  final MvvmAnimationListener<P, M>? animListener;

  _MVVMSingleTickerProviderContentState(this.animListener);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    presenter.view = this;
    if (!hasInit) {
      hasInit = true;
      presenter.onInit();
      WidgetsBinding.instance!.addPostFrameCallback((_) {
          presenter.afterViewInit();
      });
    }
    _controller ??= widget.singleAnimController!(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    hasInit = false;
  }

  @override
  void deactivate() {
    presenter.onDestroy();
    this.disposeAnimation();
    super.deactivate();
    presenter.afterViewDestroyed();
  }

  @override
  void forceRefreshView() {
    if (mounted) {
      setState(() {});
    }
  }

  P get presenter => PresenterInherited.of<P, M>(context)!.presenter;

  MvvmContext get mvvmContext =>
      MvvmContext(context, animationController: _controller);

  MvvmContentBuilder<P, M>? get builder =>
      PresenterInherited.of<P, M>(context)!.builder;

  @override
  Widget build(BuildContext context) =>
      builder!(mvvmContext, presenter, presenter.viewModel as M);

  @override
  Future<void> refreshAnimation() async {
    animListener!(mvvmContext, presenter, presenter.viewModel as M);
  }

  @override
  Future<void> disposeAnimation() async {
    if (_controller != null) {
      _controller!.stop();
      _controller!.dispose();
    }
  }
}

/// -----------------------------------------------
/// MULTIPLE ANIMATIONS CONTENT WIDGET
/// -----------------------------------------------
class MultipleAnimatedMvvmContent<P extends Presenter, M extends MVVMModel>
    extends StatefulWidget {
  final MvvmAnimationsControllerBuilder? multipleAnimController;
  final MvvmAnimationListener<P, M>? animListener;

  MultipleAnimatedMvvmContent({
    Key? key,
    required this.multipleAnimController,
    this.animListener,
  }) : super(key: key);

  @override
  _MVVMMultipleTickerProviderContentState<P, M> createState() =>
      _MVVMMultipleTickerProviderContentState<P, M>(animListener);
}

class _MVVMMultipleTickerProviderContentState<P extends Presenter,
        M extends MVVMModel> extends State<MultipleAnimatedMvvmContent>
    with TickerProviderStateMixin
    implements MVVMView {
  List<AnimationController>? _controller;
  bool hasInit = false;
  final MvvmAnimationListener<P, M>? animListener;

  _MVVMMultipleTickerProviderContentState(this.animListener);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    presenter.view = this;
    if (!hasInit) {
      hasInit = true;
      presenter.onInit();
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        presenter.afterViewInit();
      });
    }
    _controller ??= widget.multipleAnimController!(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    presenter.onInit();
    hasInit = false;
  }

  @override
  void deactivate() {
    presenter.onDestroy();
    // Dispose all animations
    this.disposeAnimation();
    super.deactivate();
    presenter.afterViewDestroyed();
  }

  @override
  void forceRefreshView() {
    if (mounted) {
      setState(() {});
    }
  }

  P get presenter => PresenterInherited.of<P, M>(context)!.presenter;

  MvvmContext get mvvmContext =>
      MvvmContext(context, animationsControllers: _controller);

  MvvmContentBuilder<P, M>? get builder =>
      PresenterInherited.of<P, M>(context)!.builder;

  @override
  Widget build(BuildContext context) =>
      builder!(mvvmContext, presenter, presenter.viewModel as M);

  @override
  Future<void> refreshAnimation() async {
    animListener!(mvvmContext, presenter, presenter.viewModel as M);
  }

  @override
  Future<void> disposeAnimation() async {
    if (_controller != null && _controller!.length > 0) {
      for (var controller in _controller!) {
        controller.stop();
        controller.dispose();
      }
    }
  }
}
