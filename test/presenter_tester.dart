import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_builder/mvvm_builder.dart';


P getMvvmPagePresenter<P extends Presenter, M extends MVVMModel>(WidgetTester tester, Key key) {
  var pageFinder = find.byKey(key);
  var page = pageFinder.evaluate().first.widget as MVVMPage<P, M>;
  return page.presenter;
}