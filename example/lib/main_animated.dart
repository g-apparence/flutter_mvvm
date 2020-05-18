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
          var animation = new CurvedAnimation(
            parent: context.animationController,
            curve: Curves.easeIn,
          );
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(model.title)),
            body: ListView.separated(
              itemBuilder: (context, index) => InkWell(
                onTap: () => presenter.onClickItem(index),
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Opacity(opacity: animation.value, child: child),
                  child: ListTile(
                    title: Text(model.todoList[index].title),
                    subtitle: Text(model.todoList[index].subtitle),
                  ),
                ),
              ),
              separatorBuilder: (context, index) => Divider(height: 1) ,
              itemCount: model.todoList.length
            )
          );
        },
        presenter: MyPresenter(new MyViewModel(), this),
        singleAnimControllerBuilder: (tickerProvider) => AnimationController(vsync: tickerProvider, duration: Duration(seconds: 1)),
        animListener: (context, presenter, model) {
          if(model.fadeInAnimation) {
            context.animationController
              .forward()
              .then((value) => presenter.onFadeInAnimationEnd());
          }
        },
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
    this.viewModel.fadeInAnimation = false;
    this.viewModel.show = false;
    this.viewModel.title = "My todo list";
    this.viewModel.todoList = List();
    for(int i = 0; i < 15; i++) {
      this.viewModel.todoList.add(new TodoModel("TODO $i", "my task $i"));
    }
    this.refreshView();
    // lets show an animation 1 seconds after init
    await Future.delayed(Duration(seconds: 1), () {
      this.viewModel.fadeInAnimation = true;
      this.viewModel.show = true;
      this.refreshAnimations();
    });
  }

  onClickItem(int index) {
    viewInterface.showMessage("Item clicked $index");
  }

  onFadeInAnimationEnd() {
    this.viewModel.fadeInAnimation = true;
  }
}


class MyViewModel extends MVVMModel {
  String title;
  List<TodoModel> todoList;

  bool fadeInAnimation;
  bool show;
}

class TodoModel {
  String title, subtitle;

  TodoModel(this.title, this.subtitle);
}