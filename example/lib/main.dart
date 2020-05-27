import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mvvm_builder/mvvm_builder.dart';
import 'package:mvvm_builder/presenter_builder.dart';

final homePageBuilder = MyAppWithBuilder();

Route<dynamic> route(RouteSettings settings) {
  print("...[call route] ${settings.name}");
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: homePageBuilder.build);
  }
}


void main() {
  print("...[main]");
  return runApp(
    MaterialApp(onGenerateRoute: route)
  );
}



class MyAppWithBuilder extends StatelessWidget implements MyViewInterface {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final mvvmPageBuilder = MVVMPageBuilder<MyPresenter, MyViewModel>();

  @override
  Widget build(BuildContext context) {
    return mvvmPageBuilder.build(
      context: context,
      key: ValueKey("page"),
      presenterBuilder: (context) => MyPresenter(new MyViewModel(), this),
      builder: (context, presenter, model) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text(model?.title ?? "")),
          body: ListView.separated(
            itemBuilder: (context, index) => InkWell(
              onTap: () => presenter.onClickItem(index),
              child: ListTile(
                title: Text(model.todoList[index].title),
                subtitle: Text(model.todoList[index].subtitle),
              ),
            ),
            separatorBuilder: (context, index) => Divider(height: 1) ,
            itemCount: model.todoList.length ?? 0
          )
        );
      },
    );
  }

  @override
  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text(message)));
  }
}


class MyApp extends StatelessWidget implements MyViewInterface {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MVVMPage<MyPresenter, MyViewModel>(
      key: ValueKey("page"),
      builder: (context, presenter, model) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text(model?.title ?? "")),
          body: ListView.separated(
            itemBuilder: (context, index) => InkWell(
              onTap: () => presenter.onClickItem(index),
              child: ListTile(
                title: Text(model.todoList[index].title),
                subtitle: Text(model.todoList[index].subtitle),
              ),
            ),
            separatorBuilder: (context, index) => Divider(height: 1) ,
            itemCount: model.todoList.length ?? 0
          )
        );
      },
      presenter: MyPresenter(new MyViewModel(), this),
    );
  }

  @override
  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text(message)));
  }
}

abstract class MyViewInterface {

  void showMessage(String message);

}


class MyPresenter extends Presenter<MyViewModel, MyViewInterface> {

  MyPresenter(MyViewModel model, MyViewInterface myView) : super(model, myView) {
    this.viewModel.title = "My todo list";
    this.viewModel.todoList = List();
  }

  @override
  Future onInit() async {
    for(int i = 0; i < 15; i++) {
      this.viewModel.todoList.add(new TodoModel("TODO $i", "my task $i"));
    }
    this.refreshView();
  }

  onClickItem(int index) {
    viewInterface.showMessage("Item clicked $index");
  }
}


class MyViewModel extends MVVMModel {
  String title;
  List<TodoModel> todoList;
}

class TodoModel {
  String title, subtitle;

  TodoModel(this.title, this.subtitle);
}