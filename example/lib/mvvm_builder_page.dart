import 'package:flutter/material.dart';
import 'package:mvvm_builder/component_builder.dart';

import 'mvvm_page.dart';

class MyMvvmPageWithBuilder extends StatelessWidget implements MyViewInterface {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final builder = MVVMPageBuilder<MyPresenter, MyViewModel>();

  @override
  Widget build(BuildContext context) {
    return builder.build(
      key: ValueKey("page"),
      context: context,
      presenterBuilder: (context) => MyPresenter(new MyViewModel(), this),
      builder: (context, presenter, model) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text(model?.title ?? "", key: ValueKey("title"),)),
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
      }
    );
  }

  @override
  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text(message)));
  }
}
