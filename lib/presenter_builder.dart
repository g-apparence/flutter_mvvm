import 'package:flutter/material.dart';
import 'package:mvvm_builder/component_builder.dart';
import 'package:mvvm_builder/mvvm_model.dart';

/// Wraps presenter inside a persistent Widget
class PresenterInherited<T extends Presenter, M extends MVVMModel> extends InheritedWidget {
  final T _presenter;
  final MvvmContentBuilder<T, M> builder;

  PresenterInherited({Key key, T presenter, Widget child, this.builder})
      : this._presenter = presenter,
        super(key: key, child: child);

  T get presenter => _presenter;

  static PresenterInherited<T,M> of<T extends Presenter, M extends MVVMModel>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PresenterInherited<T,M>>();

  @override
  bool updateShouldNotify(PresenterInherited oldWidget) => true;
}


/// This class must be overriden too
class Presenter<T extends MVVMModel, I> {
  MVVMView _view;
  I _viewInterface;
  T _model;

  Presenter(T model, I viewInterface) {
    this._model = model;
    this._viewInterface = viewInterface;
  }

  /// if you didn't put a viewInterface use this method before
  init(I viewInterface) {
    this.viewInterface = viewInterface;
  }

  /// called when view init
  Future onInit() => Future.value("Not implemented 1");

  /// called when view has been drawn for the 1st time
  Future afterViewInit() => Future.value("");

  /// called when view is destroyed
  Future onDestroy() => Future.value("Not implemented 2");

  /// get the viewModel from presenter
  T get viewModel => _model;

  /// get a new viewModel in presenter
  set model(T value) => _model = value;

  /// set the view reference to presenter
  set view(MVVMView view) => this._view = view;

  /// call a method from your instance of [MVVMView]
  /// this method must be declared in interface extending MVVMView
  I get viewInterface => this._viewInterface;

  set viewInterface(I value) => _viewInterface = value;

  /// call this to refresh the view
  /// if you mock [I] this will have no effect when calling forceRefreshView
  refreshView() {
    if(_view != null) {
      _view.forceRefreshView();
    }
  }

  /// call this to refresh animations
  /// this will start animations from your animation listener of MvvmBuilder
  Future refreshAnimations() async {
    if(_view != null) {
      await _view.refreshAnimation();
    }
  }
}
