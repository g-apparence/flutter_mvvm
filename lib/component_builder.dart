import 'package:flutter/material.dart';
import 'presenter_builder.dart';
import 'component_animated_builder.dart';
import 'mvvm_context.dart';
import 'mvvm_model.dart';

/// builds a child for a [MVVMContent]
typedef MvvmContentBuilder<P extends Presenter, M extends MVVMModel> = Widget Function(MvvmContext context, P presenter, M model);

/// functions to handle animation state without refresh page
typedef MvvmAnimationListener<P extends Presenter, M extends MVVMModel> = void Function(MvvmContext context, P presenter, M model);

/// builds a single [AnimationController]
typedef MvvmAnimationControllerBuilder = AnimationController Function(TickerProvider tickerProvider);

/// builds a list of [AnimationController]
typedef MvvmAnimationsControllerBuilder = List<AnimationController> Function(TickerProvider tickerProvider);

/// builds a presenter
typedef PresenterBuilder<P> = P Function(BuildContext context);


/// -----------------------------------------------
/// MVVMPageBuilder
/// -----------------------------------------------
/// Creates a static cached page from a builder method
/// Prefer use this to keep presenter state from unwanted rebuild
class MVVMPageBuilder<P extends Presenter, M extends MVVMModel> {

  P presenter;

  Widget build({Key key,
      @required BuildContext context,
      @required PresenterBuilder presenterBuilder,
      @required MvvmContentBuilder<P, M> builder,
      MvvmAnimationListener<P, M> animListener,
      MvvmAnimationControllerBuilder singleAnimControllerBuilder,
      MvvmAnimationsControllerBuilder multipleAnimControllerBuilder,
      bool forceRebuild = false,
  }) {
    
    if(presenter == null || forceRebuild) {
      presenter = presenterBuilder(context);
    }

    assert(builder != null);
    Widget content;

    if(singleAnimControllerBuilder == null && multipleAnimControllerBuilder == null) {
      content = MVVMContent<P, M>();
    } else if (singleAnimControllerBuilder != null) {
      content = AnimatedMvvmContent<P, M>(
        singleAnimController: singleAnimControllerBuilder,
        animListener: animListener);
    } else if (multipleAnimControllerBuilder != null) {
      content = MultipleAnimatedMvvmContent<P,M>(
        multipleAnimController: multipleAnimControllerBuilder,
        animListener: animListener);
    }

    return PresenterInherited<P,M>(
      key: key,
      presenter: presenter,
      builder: builder,
      child: content,
    );
  }
}



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

    assert(_builder != null);
    Widget content;

    if(_singleAnimControllerBuilder == null && _multipleAnimControllerBuilder == null) {
      content = MVVMContent<P, M>();
    } else if (_singleAnimControllerBuilder != null) {
      content = AnimatedMvvmContent<P, M>(
        singleAnimController: _singleAnimControllerBuilder,
        animListener: _animListener);
    } else if (_multipleAnimControllerBuilder != null) {
      content = MultipleAnimatedMvvmContent<P,M>(
        multipleAnimController: _multipleAnimControllerBuilder,
        animListener: _animListener);
    }

    return PresenterInherited<P,M>(
      presenter: _presenter,
      builder: _builder,
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
  void forceRefreshView();

  /// calls refresh animation state
  Future<void> refreshAnimation();
}

/// -----------------------------------------------
/// CONTENT WIDGET
/// -----------------------------------------------
class MVVMContent<P extends Presenter, M extends MVVMModel> extends StatefulWidget {

  MVVMContent({Key key}) : super(key: key);

  @override
  _MVVMContentState<P, M> createState() => _MVVMContentState<P, M>();
}

class _MVVMContentState<P extends Presenter, M extends MVVMModel> extends State<MVVMContent> implements MVVMView {

  bool hasInit = false;

  _MVVMContentState();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(presenter != null, "Presenter must be not null");
    if(!hasInit) {
      presenter.view = this;
      presenter.onInit();
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.afterViewInit());
    }
    hasInit = true;
  }

  @override
  void deactivate() {
    presenter.onDestroy();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => builder(mvvmContext, presenter, presenter.viewModel);

  @override
  void forceRefreshView() {
    if(mounted) {
      setState(() {});
    }
  }

  MvvmContext get mvvmContext => MvvmContext(context);

  P get presenter => PresenterInherited.of<P,M>(context).presenter;

  MvvmContentBuilder<P, M> get builder => PresenterInherited.of<P,M>(context).builder;

  @override
  Future<void> refreshAnimation() => throw UnimplementedError();
}



