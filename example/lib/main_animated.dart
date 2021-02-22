import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mvvm_builder/mvvm_builder.dart';


Route<dynamic>? route(RouteSettings settings) {
  print("...[call route] ${settings.name}");
//  switch (settings.name) {
//    case "/":
//      return MaterialPageRoute(builder: homePageBuilder.build);
//  }
}


void main() {
  print("...[main animated]");
  return runApp(
    MaterialApp(onGenerateRoute: route, home: MyApp())
  );
}


class MyApp extends StatelessWidget implements MyViewInterface{

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late MyPresenter mPresenter;

  MyApp() {
    /// must be called to be able to use [MyViewInterface] in our presenter
    /// or simply use MvvmPageBuilder that handle this for you
    this.mPresenter = MyPresenter.create(this);
  }

  @override
  Widget build(BuildContext context) {
    return MVVMPage<MyPresenter, MyViewModel>(
        builder: (context, presenter, model) {
          var animation = new CurvedAnimation(
            parent: context.animationController!,
            curve: Curves.easeIn,
          );
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text(model.title ?? "")),
            body: ListView.separated(
              itemBuilder: (context, index) => InkWell(
                onTap: () => presenter.onClickItem(index),
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Opacity(opacity: animation.value, child: child),
                  child: ListTile(
                    title: Text(model.todoList![index].title, style: TextStyle(color: Colors.black87),),
                    subtitle: Text(model.todoList![index].subtitle, style: TextStyle(color: Colors.black87)),
                  ),
                ),
              ),
              separatorBuilder: (context, index) => Divider(height: 1) ,
              itemCount: model.todoList?.length ?? 0
            )
          );
        },
        presenter: mPresenter,
        singleAnimControllerBuilder: (tickerProvider) => AnimationController(vsync: tickerProvider, duration: Duration(seconds: 1)),
        animListener: (context, presenter, model) {
          if(model.fadeInAnimation) {
            context.animationController!
              .forward()
              .then((value) => presenter.onFadeInAnimationEnd());
          }
        },
      );
  }

  @override
  void showMessage(String message) {
    _scaffoldKey.currentState?.showSnackBar(new SnackBar(content: Text(message)));
  }

}

abstract class MyViewInterface {

  void showMessage(String message);

}


class MyPresenter extends Presenter<MyViewModel, MyViewInterface> {

  MyPresenter(MyViewModel model, MyViewInterface myView) : super(model, myView);

  factory MyPresenter.create(MyViewInterface myView) => MyPresenter(MyViewModel(), myView);

  @override
  Future onInit() async {
    this.viewModel.fadeInAnimation = false;
    this.viewModel.show = false;
    this.viewModel.title = "My todo list";
    this.viewModel.todoList = [];
    for(int i = 0; i < 15; i++) {
      this.viewModel.todoList?.add(new TodoModel("TODO $i", "my task $i"));
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
  String? title;
  List<TodoModel>? todoList;

  late bool fadeInAnimation;
  late bool show;
}

class TodoModel {
  String title, subtitle;

  TodoModel(this.title, this.subtitle);
}