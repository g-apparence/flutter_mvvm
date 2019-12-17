import 'package:flutter/material.dart';
import 'package:mvvm_builder/component_builder.dart';
import 'package:mvvm_builder/mvvm_model.dart';

class PresenterInherited<T extends Presenter> extends InheritedWidget {
  final T _presenter;

  PresenterInherited({Key key, T presenter, Widget child})
      : this._presenter = presenter,
        super(key: key, child: child);

  T get presenter => _presenter;

  static PresenterInherited<T> of<T extends Presenter>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PresenterInherited<T>>();

  @override
  bool updateShouldNotify(PresenterInherited oldWidget) => false;
}

/// This class must be overriden to
class Presenter<T extends MVVMModel, I> {
  MVVMView _view;
  I _viewInterface;
  T _model;

  Presenter(T model, I viewInterface) {
    this._model = model;
    this._viewInterface = viewInterface;
  }

  /// called when view init
  Future onInit() => Future.value("Not implemented 1");

  /// called when view is destroyed
  Future onDestroy() => Future.value("Not implemented 2");

  /// get the viewModel from presenter
  T get viewModel => _model;

  /// set the view reference to presenter
  set view(MVVMView view) => this._view = view;

  /// call a method from your instance of [MVVMView]
  /// this method must be declared in interface extending MVVMView
  I get viewInterface => this._viewInterface;

  /// call this to refresh the view
  refreshView() => _view.forceRefreshView();
}
