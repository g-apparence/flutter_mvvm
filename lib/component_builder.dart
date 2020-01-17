import 'package:flutter/material.dart';
import 'package:mvvm_builder/presenter_builder.dart';

import 'mvvm_model.dart';

/// builds a child for a [MVVMContent]
typedef Widget MvvmContentBuilder<P extends Presenter, M extends MVVMModel>(
    BuildContext context, P presenter, M model);

/// -----------------------------------------------
/// PAGE WIDGET
/// -----------------------------------------------
/// Creates a new MVVM widget to split business logic easylly from rendering
class MVVMPage<P extends Presenter, M extends MVVMModel>
    extends StatelessWidget {
  final P _presenter;
  final Key key;
  final MvvmContentBuilder<P, M> _builder;

  MVVMPage({
    Key key,
    @required P presenter,
    @required MvvmContentBuilder<P, M> builder,
  })  : this._presenter = presenter,
        this.key = key,
        this._builder = builder,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(this._builder != null);
    return PresenterInherited<P>(
      presenter: _presenter,
      child: new MVVMContent<P, M>(builder: this._builder),
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
}

/// -----------------------------------------------
/// CONTENT WIDGET
/// -----------------------------------------------
class MVVMContent<P extends Presenter, M extends MVVMModel>
    extends StatefulWidget {
  final MvvmContentBuilder<P, M> _builder;

  MvvmContentBuilder get builder => _builder;

  MVVMContent({Key key, @required MvvmContentBuilder<P, M> builder})
      : this._builder = builder,
        super(key: key);

  @override
  _MVVMContentState<P, M> createState() {
    return _MVVMContentState<P, M>(_builder);
  }
}

class _MVVMContentState<P extends Presenter, M extends MVVMModel>
    extends State<MVVMContent> implements MVVMView {
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
  }

  @override
  void dispose() {
    super.dispose();
    this._presenter.onDestroy();
  }

  @override
  Widget build(BuildContext context) {
    return _builder(context, _presenter, this._presenter.viewModel);
  }

  @override
  forceRefreshView() {
    setState(() {});
  }
}
