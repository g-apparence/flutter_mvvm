import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_builder/mvvm_builder.dart';


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mvvm_page.dart';

void main() {
  group('MyMvvmPage test', () {

    MyPresenter getPresenter() {
      var pageFinder = find.byKey(ValueKey("page"));
      var page = pageFinder.evaluate().first.widget as MVVMPage<MyPresenter, MyViewModel>;
      return page.presenter;
    }

    MyMvvmPage component = MyMvvmPage();

    testWidgets('create page, check ok', (WidgetTester tester) async {
      var app = MaterialApp(home: component);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle(Duration(seconds: 1));
      var presenter = getPresenter();
      expect(find.byKey(ValueKey('page')), findsOneWidget);
      expect(find.text("My todo list"), findsOneWidget);
      expect(find.text("my task 0"), findsOneWidget);
      expect(find.text("my task 5"), findsOneWidget);
      expect(presenter.viewModel.todoList.length, 15);
      expect(presenter, isNotNull);
    });

  });
}