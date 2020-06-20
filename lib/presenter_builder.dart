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
abstract class Presenter<T extends MVVMModel, I> {
  MVVMView _view;

  /// Interface defining the exposed methods of the view
  I viewInterface;

  /// Model containing the current state of the view
  T viewModel;

  /// Container controlling the current state of the view
  Presenter(this.viewModel, this.viewInterface);

  /// called when view init
  void onInit() {}

  /// called when view has been drawn for the 1st time
  void afterViewInit() {}

  /// called when view is destroyed
  void onDestroy() {}

  /// set the view reference to presenter
  set view(MVVMView view) => _view = view;

  /// call this to refresh the view
  /// if you mock [I] this will have no effect when calling forceRefreshView
  void refreshView() => _view?.forceRefreshView();

  /// call this to refresh animations
  /// this will start animations from your animation listener of MvvmBuilder
  Future<void> refreshAnimations() async => _view?.refreshAnimation();
}
