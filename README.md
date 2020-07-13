![mvvm builder explanations](https://apparence.io/media/48/mvp_image.jpeg)

# mvvm_builder

mvvm_builder is a Flutter plugin to help you implement MVVM design pattern with flutter. 
MVVM = Model - View - ViewModel

# Installation

To use this plugin, add mvvm_builder as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).  

## Why use MVVM design patterns
Widely used in Android and iOS native development. This pattern is one of the best to handle complex page with testable code.
Implement a good design pattern can just simplify code, make more code testable, allow better performance...
The idea is to split business logic from your view. Your view has to stay dumb, and this plugin will help you 
to respect the pattern. 


# Usage

1 - import MVVMPage Widget from package
```
import 'package:mvvm_builder/mvvm_builder.dart';
```

## 2 - Create your Model
```
class MyViewModel extends MVVMModel {
  String title;
  List<TodoModel> todoList;
}

class TodoModel {
  String title, subtitle;

  TodoModel(this.title, this.subtitle);
}
```


## 3 - Create your Presenter

```
class MyPresenter extends Presenter<MyViewModel, MyViewInterface> {

  MyPresenter(MyViewModel model, MyViewInterface view) : super(model, view);

  @override
  Future onInit() async {
    // do initialisation stuff on your viewmodel here, loading... etc
    this.viewModel.title = "My todo list";
    this.viewModel.todoList = List();
    // init your view model here -- load from network etc ... 
    for(int i = 0; i < 15; i++) {
      this.viewModel.todoList.add(new TodoModel("TODO $i", "my task $i"));
    }
    this.refreshView(); // call this at the end if onInit takes time
  }
}
```
## 4 - define your view interface
for example: 
```
abstract class MyViewInterface {
  
  void showMessage(String message);
  
}
```


## 5 - Create your Page

### Use directly MVVMPage
You page must implement your view interface. 
For example :
```
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
```

### Use a Mvvmbuilder
Using a builder defer build and presenter creation until you actually need it. 
This can be also usefull if you want to keep a page state in your memory. Prefer use this method to use this page within a route. 
**MVVMPageBuilder stores a version of your page in cache after first time it's build.**
Ex: 
```
class MyAppWithBuilder extends StatelessWidget implements MyViewInterface {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final mvvmPageBuilder = MVVMPageBuilder<MyPresenter, MyViewModel>();

  @override
  Widget build(BuildContext context) {
    return mvvmPageBuilder.build(
      presenterBuilder: (context) => MyPresenter(new MyViewModel(), this),
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
    );
  }

  @override
  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text(message)));
  }
}
``` 
## Application routes
As said in previous section, builder can be usefull to keep a page state across rebuilds. 
This only store the way you create a page.
Prefer this method as it's easyer and much better. 
Ex: 
```
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
   MaterialApp(
     onGenerateRoute: route,
   )
  );
}

```


# Test
This pattern is really usefull for testing as it allows you to test business logic separately from rendering. 
The another good thing of this pattern is the ability to test your view with many combination of viewModel settings 
without the need of chaining actions before having the desired view state. 
You can now test your view alone, presenter alone and test them together. 



## Use animations 
MVVMPage can help you construct a simple Page with animations. Just provide a way to create an AnimationController and use the animation listener to handle animations. 
```
class MyApp extends StatelessWidget implements MyViewInterface {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  
  // prefer to create your presenter outside of build method to keep it's state safe
  final MyPresenter mPresenter = MyPresenter.create(null);

  MyApp() {
    // must be called to be able to use [MyViewInterface] in our presenter
    mPresenter.init(this);
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
        presenter: mPresenter, 
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
```
singleAnimControllerBuilder : creates your animations controller.
animListener : handle the state of your animations.

To fire animListener simply call refreshAnimations from your presenter. Now you can handle animations state directly from your presenter. 


# Final note 
**Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.**
