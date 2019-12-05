import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mvvm_builder/mvvm_builder.dart';

void main() => runApp(MyApp());


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements MyViewInterface{

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MVVMPage<MyPresenter, MyViewModel>(
        builder: (context, presenter, model) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(model.title)),
            body: ListView.separated(
              itemBuilder: (context, index) => InkWell(
                onTap: () => presenter.onClickItem(index),
                child: ListTile(
                  title: Text(model.todoList[index].title),
                  subtitle: Text(model.todoList[index].subtitle),
                ),
              ),
              separatorBuilder: (context, index) => Divider(height: 1) ,
              itemCount: model.todoList.length
            )
          );
        },
        presenter: MyPresenter(new MyViewModel(), this),
      )
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

  MyPresenter(MyViewModel model, MyViewInterface myView) : super(model, myView);

  @override
  Future onInit() async {
    this.viewModel.title = "My todo list";
    this.viewModel.todoList = List();
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