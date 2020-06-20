import 'package:flutter/material.dart';

import 'component_builder.dart';
import 'mvvm_context.dart';
import 'mvvm_model.dart';
import 'presenter_builder.dart';

/// -----------------------------------------------
/// SINGLE ANIMATION CONTENT WIDGET
/// should extends MVVMContent but dartlang extends Generics bug
/// -----------------------------------------------
class AnimatedMvvmContent<P extends Presenter, M extends MVVMModel> extends MVVMContent {

  final MvvmAnimationControllerBuilder singleAnimController;
  final MvvmAnimationListener<P, M> animListener;

  AnimatedMvvmContent({
    Key key,
    @required this.singleAnimController,
    this.animListener,
  }) : super(key: key);

  @override
  State<MVVMContent> createState() =>
    _MVVMSingleTickerProviderContentState<Presenter, MVVMModel>();
}


class _MVVMSingleTickerProviderContentState<P extends Presenter, M extends MVVMModel> extends State<AnimatedMvvmContent> with SingleTickerProviderStateMixin implements MVVMView {

  AnimationController _controller;
  bool hasInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(presenter != null);
    presenter.view = this;
    if(!hasInit) {
      presenter.onInit();
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.afterViewInit());
    }
    _controller ??= widget.singleAnimController(this);
    hasInit = true;
  }

  @override
  void deactivate() {
    presenter.onDestroy();
    super.deactivate();
  }

  @override
  void forceRefreshView() {
    if(mounted) {
      setState(() {});
    }
  }

  P get presenter => PresenterInherited.of<P,M>(context).presenter;

  MvvmContext get mvvmContext => MvvmContext(context);

  MvvmContentBuilder<P, M> get builder => PresenterInherited.of<P,M>(context).builder;

  @override
  Widget build(BuildContext context) =>
    builder(MvvmContext(context, animationController: _controller), presenter, presenter.viewModel);

  @override
  Future<void> refreshAnimation() async {
    widget.animListener(MvvmContext(context, animationController: _controller), presenter, presenter.viewModel);
  }
}


//class AnimatedMvvmContent<P extends Presenter, M extends MVVMModel> extends MVVMContent {
//
//  final MvvmAnimationControllerBuilder singleAnimController;
//  final MvvmAnimationListener<P, M> animListener;
//
//  AnimatedMvvmContent({
//    Key key,
//    @required MvvmContentBuilder<P, M> builder,
//    @required this.singleAnimController,
//    this.animListener,
//  }) : super(key: key, builder: builder);
//
//  @override
//  _MVVMSingleTickerProviderContentState<P, M> createState() =>
//    _MVVMSingleTickerProviderContentState<P, M>(_builder, this.singleAnimController, this.animListener);
//}
//
//
//class _MVVMSingleTickerProviderContentState<P extends Presenter, M extends MVVMModel> extends _MVVMContentState with SingleTickerProviderStateMixin {
//
//  final MvvmAnimationControllerBuilder animationControllerBuilder;
//  final MvvmAnimationListener<P, M> animListener;
//  AnimationController _controller;
//
//  _MVVMSingleTickerProviderContentState(dynamic builder, this.animationControllerBuilder, this.animListener) : super(builder);
//
//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//    _controller = animationControllerBuilder(this);
//  }
//
//  @override
//  Widget build(BuildContext context) =>
//    _builder(MvvmContext(context, animationController: _controller), _presenter, _presenter.viewModel);
//
//  @override
//  refreshAnimation() async {
//    animListener(MvvmContext(context, animationController: _controller), _presenter, _presenter.viewModel);
//  }
//}




/// -----------------------------------------------
/// MULTIPLE ANIMATIONS CONTENT WIDGET
/// -----------------------------------------------
class MultipleAnimatedMvvmContent<P extends Presenter, M extends MVVMModel> extends StatefulWidget {

  final MvvmAnimationsControllerBuilder multipleAnimController;
  final MvvmAnimationListener<P, M> animListener;

  MultipleAnimatedMvvmContent({
    Key key,
    @required this.multipleAnimController,
    this.animListener,
  }) : super(key: key);

  @override
  _MVVMMultipleTickerProviderContentState<P, M> createState() =>
    _MVVMMultipleTickerProviderContentState<P, M>();
}


class _MVVMMultipleTickerProviderContentState<P extends Presenter, M extends MVVMModel> extends State<MultipleAnimatedMvvmContent> with TickerProviderStateMixin implements MVVMView {

  List<AnimationController> _controller;
  bool hasInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(presenter != null);
    if(!hasInit) {
      presenter.view = this;
      presenter.onInit();
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.afterViewInit());
    }
    _controller ??= widget.multipleAnimController(this);
    hasInit = true;
  }

  @override
  void deactivate() {
    presenter.onDestroy();
    super.deactivate();
  }

  @override
  void forceRefreshView() {
    if(mounted) {
      setState(() {});
    }
  }

  P get presenter => PresenterInherited.of<P,M>(context).presenter;

  MvvmContext get mvvmContext => MvvmContext(context);

  MvvmContentBuilder<P, M> get builder => PresenterInherited.of<P,M>(context).builder;

  @override
  Widget build(BuildContext context) =>
    builder(MvvmContext(context, animationsControllers: _controller), presenter, presenter.viewModel);

  @override
  Future<void> refreshAnimation() async {
    widget.animListener(MvvmContext(context, animationsControllers: _controller), presenter, presenter.viewModel);
  }
}


//class MultipleAnimatedMvvmContent<P extends Presenter, M extends MVVMModel> extends MVVMContent {
//
//  final MvvmAnimationsControllerBuilder multipleAnimController;
//
//  MultipleAnimatedMvvmContent({
//    Key key,
//    @required MvvmContentBuilder<P, M> builder,
//    @required this.multipleAnimController,
//  }) : super(key: key, builder: builder);
//
//  @override
//  _MVVMMultipleTickerProviderContentState<P, M> createState() =>
//    _MVVMMultipleTickerProviderContentState<P, M>(_builder, this.multipleAnimController);
//}
//
//
//class _MVVMMultipleTickerProviderContentState<P extends Presenter, M extends MVVMModel> extends _MVVMContentState with TickerProviderStateMixin {
//
//  final MvvmAnimationsControllerBuilder animationControllerBuilder;
//  List<AnimationController> _controllers;
//
//  _MVVMMultipleTickerProviderContentState(MvvmContentBuilder<P, M> builder, this.animationControllerBuilder) : super(builder);
//
//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//    _controllers = animationControllerBuilder(this);
//  }
//
//  @override
//  Widget build(BuildContext context) =>
//    _builder(MvvmContext(context, animationsControllers: _controllers), _presenter, this._presenter.viewModel);
//
//  @override
//  refreshAnimation() async {
//    // TODO: implement refreshAnimation
//    throw UnimplementedError();
//  }
//
//
//}
