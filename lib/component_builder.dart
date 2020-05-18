import 'package:flutter/material.dart';
import 'package:mvvm_builder/presenter_builder.dart';

import 'component_animated_builder.dart';
import 'mvvm_context.dart';
import 'mvvm_model.dart';

/// builds a child for a [MVVMContent]
typedef Widget MvvmContentBuilder<P extends Presenter, M extends MVVMModel>(MvvmContext context, P presenter, M model);

/// functions to handle animation state without refresh page
typedef void MvvmAnimationListener<P extends Presenter, M extends MVVMModel>(MvvmContext context, P presenter, M model);

/// builds a single [AnimationController]
typedef AnimationController MvvmAnimationControllerBuilder(TickerProvider tickerProvider);

/// builds a list of [AnimationController]
typedef List<AnimationController> MvvmAnimationsControllerBuilder(TickerProvider tickerProvider);

/// -----------------------------------------------
/// PAGE WIDGET
/// -----------------------------------------------
/// Creates a new MVVM widget to split business logic easylly from rendering
/// [singleAnimControllerBuilder] creates a single AnimationController inside the page
/// [multipleAnimControllerBuilder] creates a list of AnimationController inside the page
class MVVMPage<P extends Presenter, M extends MVVMModel> extends StatelessWidget {
  final P _presenter;
  final Key key;
  final MvvmContentBuilder<P, M> _builder;
  final MvvmAnimationListener<P, M> _animListener;
  final MvvmAnimationControllerBuilder _singleAnimControllerBuilder;
  final MvvmAnimationsControllerBuilder _multipleAnimControllerBuilder;

  MVVMPage({
    Key key,
    @required P presenter,
    MvvmContentBuilder<P, M> builder,
    MvvmAnimationListener<P, M> animListener,
    MvvmAnimationControllerBuilder singleAnimControllerBuilder,
    MvvmAnimationsControllerBuilder multipleAnimControllerBuilder,
  }) : this._presenter = presenter,
        this.key = key,
        this._builder = builder,
        this._animListener = animListener,
        this._singleAnimControllerBuilder = singleAnimControllerBuilder,
        this._multipleAnimControllerBuilder = multipleAnimControllerBuilder,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(this._builder != null);
    var content;
    if(this._singleAnimControllerBuilder == null && this._multipleAnimControllerBuilder == null) {
      content = new MVVMContent<P, M>(builder: this._builder);
    } else if (this._singleAnimControllerBuilder != null) {
      content = new AnimatedMvvmContent<P, M>(
        builder: this._builder,
        singleAnimController: _singleAnimControllerBuilder,
        animListener: _animListener);
    } else if (this._multipleAnimControllerBuilder != null) {
      content = new MultipleAnimatedMvvmContent<P,M>(
        builder: this._builder,
        multipleAnimController: _multipleAnimControllerBuilder);
    }
    return PresenterInherited<P>(
      presenter: _presenter,
      child: content,
    );
  }

  @visibleForTesting
  P get presenter => _presenter;
}

/// -----------------------------------------------
/// VIEW interface
/// -----------------------------------------------
abstract class MVVMView {
  /// force to refresh all view
  forceRefreshView();

  /// calls refresh animation state
  Future<void> refreshAnimation();
}

/// -----------------------------------------------
/// CONTENT WIDGET
/// -----------------------------------------------
class MVVMContent<P extends Presenter, M extends MVVMModel> extends StatefulWidget {

  final MvvmContentBuilder<P, M> _builder;

  MvvmContentBuilder get builder => _builder;

  MVVMContent({Key key, @required MvvmContentBuilder<P, M> builder})
      : this._builder = builder,
        super(key: key);

  @override
  _MVVMContentState<P, M> createState() => _MVVMContentState<P, M>(_builder);
}

class _MVVMContentState<P extends Presenter, M extends MVVMModel> extends State<MVVMContent> implements MVVMView {

  P _presenter;
  final MvvmContentBuilder<P, M> _builder;

  _MVVMContentState(this._builder);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this._presenter = PresenterInherited.of<P>(context).presenter;
    assert(this._presenter != null);
    _presenter.view = this;
    _presenter.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => _presenter.afterViewInit());
  }

  @override
  void dispose() {
    super.dispose();
    this._presenter.onDestroy();
  }

  @override
  Widget build(BuildContext context) => _builder(mvvmContext, _presenter, this._presenter.viewModel);

  @override
  forceRefreshView() {
    if(this.mounted) {
      setState(() {});
    }
  }

  MvvmContext get mvvmContext => MvvmContext(context);

  @override
  Future<void> refreshAnimation() => throw UnimplementedError();
}




/// -----------------------------------------------
/// MULTIPLE ANIMATIONS CONTENT WIDGET
/// -----------------------------------------------
class MultipleAnimatedMvvmContent<P extends Presenter, M extends MVVMModel> extends MVVMContent {

  final MvvmAnimationsControllerBuilder multipleAnimController;

  MultipleAnimatedMvvmContent({
    Key key,
    @required MvvmContentBuilder<P, M> builder,
    @required this.multipleAnimController,
  }) : super(key: key, builder: builder);

  @override
  _MVVMMultipleTickerProviderContentState<P, M> createState() =>
    _MVVMMultipleTickerProviderContentState<P, M>(_builder, this.multipleAnimController);
}


class _MVVMMultipleTickerProviderContentState<P extends Presenter, M extends MVVMModel> extends _MVVMContentState with TickerProviderStateMixin {

  final MvvmAnimationsControllerBuilder animationControllerBuilder;
  List<AnimationController> _controllers;

  _MVVMMultipleTickerProviderContentState(MvvmContentBuilder<P, M> builder, this.animationControllerBuilder) : super(builder);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controllers = animationControllerBuilder(this);
  }

  @override
  Widget build(BuildContext context) =>
    _builder(MvvmContext(context, animationsControllers: _controllers), _presenter, this._presenter.viewModel);

  @override
  refreshAnimation() async {
    // TODO: implement refreshAnimation
    throw UnimplementedError();
  }


}
