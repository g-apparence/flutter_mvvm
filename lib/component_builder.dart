import 'package:flutter/material.dart';
import 'presenter_builder.dart';
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

/// builds a presenter
typedef P PresenterBuilder<P>(BuildContext context);


/// -----------------------------------------------
/// MVVMPageBuilder
/// -----------------------------------------------
/// Creates a static cached page from a builder method
/// Prefer use this to keep presenter state from unwanted rebuild
class MVVMPageBuilder<P extends Presenter, M extends MVVMModel> {

  PresenterInherited page;

  Widget build({Key key,
      @required BuildContext context,
      @required PresenterBuilder presenterBuilder,
      @required MvvmContentBuilder<P, M> builder,
      MvvmAnimationListener<P, M> animListener,
      MvvmAnimationControllerBuilder singleAnimControllerBuilder,
      MvvmAnimationsControllerBuilder multipleAnimControllerBuilder
  }) {
    if(page == null) {
      assert(builder != null);
      var content;
      if(singleAnimControllerBuilder == null && multipleAnimControllerBuilder == null) {
        content = new MVVMContent<P, M>();
      } else if (singleAnimControllerBuilder != null) {
        content = new AnimatedMvvmContent<P, M>(
          singleAnimController: singleAnimControllerBuilder,
          animListener: animListener);
      } else if (multipleAnimControllerBuilder != null) {
        content = new MultipleAnimatedMvvmContent<P,M>(
          multipleAnimController: multipleAnimControllerBuilder,
          animListener: animListener);
      }
      page = PresenterInherited<P,M>(
        presenter: presenterBuilder(context),
        builder: builder,
        child: content,
      );
    }
    return page;
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
    assert(this._builder != null);
    var content;
    if(this._singleAnimControllerBuilder == null && this._multipleAnimControllerBuilder == null) {
      content = new MVVMContent<P, M>();
    } else if (this._singleAnimControllerBuilder != null) {
      content = new AnimatedMvvmContent<P, M>(
        singleAnimController: _singleAnimControllerBuilder,
        animListener: _animListener);
    } else if (this._multipleAnimControllerBuilder != null) {
      content = new MultipleAnimatedMvvmContent<P,M>(
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
  forceRefreshView();

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

  _MVVMContentState();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(presenter != null, "Presenter must be not null");
    presenter.view = this;
    presenter.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => presenter.afterViewInit());
  }

  @override
  void deactivate() {
    presenter.onDestroy();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => builder(mvvmContext, presenter, this.presenter.viewModel);

  @override
  forceRefreshView() {
    if(this.mounted) {
      setState(() {});
    }
  }

  MvvmContext get mvvmContext => MvvmContext(context);

  P get presenter => PresenterInherited.of<P,M>(context).presenter;

  MvvmContentBuilder<P, M> get builder => PresenterInherited.of<P,M>(context).builder;

  @override
  Future<void> refreshAnimation() => throw UnimplementedError();
}



