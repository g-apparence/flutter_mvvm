import 'package:flutter/material.dart';
import 'package:mvvm_builder/presenter_builder.dart';

import 'component_builder.dart';
import 'mvvm_context.dart';
import 'mvvm_model.dart';

/// -----------------------------------------------
/// SINGLE ANIMATION CONTENT WIDGET
/// should extends MVVMContent but dartlang extends Generics bug
/// -----------------------------------------------
class AnimatedMvvmContent<P extends Presenter, M extends MVVMModel> extends StatefulWidget {

  final MvvmContentBuilder<P, M> _builder;
  final MvvmAnimationControllerBuilder singleAnimController;
  final MvvmAnimationListener<P, M> animListener;

  AnimatedMvvmContent({
    Key key,
    @required MvvmContentBuilder<P, M> builder,
    @required this.singleAnimController,
    this.animListener,
  }) : this._builder = builder,
      super(key: key);

  @override
  _MVVMSingleTickerProviderContentState<P, M> createState() =>
    _MVVMSingleTickerProviderContentState<P, M>(_builder, this.singleAnimController, this.animListener);
}


class _MVVMSingleTickerProviderContentState<P extends Presenter, M extends MVVMModel> extends State<AnimatedMvvmContent> with SingleTickerProviderStateMixin implements MVVMView {

  P _presenter;
  final MvvmAnimationControllerBuilder animationControllerBuilder;
  final MvvmAnimationListener<P, M> animListener;
  final MvvmContentBuilder<P, M> _builder;
  AnimationController _controller;

  _MVVMSingleTickerProviderContentState(this._builder, this.animationControllerBuilder, this.animListener)
    : super();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this._presenter = PresenterInherited.of<P>(context).presenter;
    assert(this._presenter != null);
    _presenter.view = this;
    _presenter.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => _presenter.afterViewInit());
    _controller = animationControllerBuilder(this);
  }

  @override
  void dispose() {
    super.dispose();
    this._presenter.onDestroy();
  }

  @override
  forceRefreshView() {
    if(this.mounted) {
      setState(() {});
    }
  }

  MvvmContext get mvvmContext => MvvmContext(context);


  @override
  Widget build(BuildContext context) =>
    _builder(MvvmContext(context, animationController: _controller), _presenter, _presenter.viewModel);

  @override
  refreshAnimation() async {
    animListener(MvvmContext(context, animationController: _controller), _presenter, _presenter.viewModel);
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
