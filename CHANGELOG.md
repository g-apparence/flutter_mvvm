## 2.1.4
* Fix dispose singleTickerAnimation controller automatically
* Fix reload view instance to presenter on didChangedependancy
* add presenter.afterViewDestroyed() to destroy some stream or notifier after views are really destroyed

## 2.1.3+3
* Fix dispose & stop all animations

## 2.1.3+2
* Fix animation get context with controller

## 2.1.3+1
* Fix _MVVMContentState check if context exists in post frame callback
* Fix _MVVMSingleTickerProviderContentState check if context exists in post frame callback
* Fix _MVVMMultipleTickerProviderContentState check if context exists in post frame callback


## 2.1.2+1
* Fix _MVVMSingleTickerProviderContentState which didn't recognize types correctly
* Fix _MVVMMultipleTickerProviderContentState which didn't recognize types correctly

## 2.1.1+1
* upgrade dartlang to 2.8.0

## 2.1.0+1
* code cleaning and comments
* removed translations file
* MVVM Model should never be instantiated alone.
* You're never supposed to build a Presenter directly
* Major change : OnInit, OnDestroy... are not async anymore
* Pass it through dartfmt
* The builder is required.
* Exports cleaning


## 2.0.0+2
* code cleaning for tests

## 2.0.0+1
* NEW - MVVMPageBuilder to delay build a MVVMPage and Presenter. You can use it with OnGenerateRouteMethods to keep a page state / presenters across rebuilds
* add a setter to presenter to change completely viewModel in order to use an external adapter
* add Presenter init method to defer initialisation of viewInterface and make presenter final in your StatelessWidgets 
* Breaking change - context is now MvvmContext, this holds the context and other flutter ressources
* singleAnimControllerBuilder is now available in MVVMPageBuilder, you can use it to create an AnimationController which you can access in MvvmContext
* multipleAnimControllerBuilder same as singleAnimController but to create multiple animations controllers
* animListener is now available in MVVMPageBuilder. Handle animations start, reset... without refreshing entire page. Check related example.
* performance : now builder / presenter are only available from top inheritedWidget
* fix a documentation error on creating presenter


## 1.0.8+4
* Add function to be called after view init in presenter

## 1.0.8+3
* Calling setState now verify if object is mounted to avoid memory leaks

## 1.0.8+2
* Presenter will no longer crash if call refreshView with a mockedView

## 1.0.8
* adding presenter getter for MVVMPage in order to test
* adding Key to MVVMPage

## 1.0.7+4
* fix documentation 

## 1.0.7+3
* fix kotlin version to 1.3.10

## 1.0.7+2
* fix build error on iOS : ld: symbol(s) not found for architecture arm64

## 1.0.7+1
* fix build error on iOS : ld: symbol(s) not found for architecture arm64

## 1.0.7
* update to swift 5

## 1.0.6
* fix ios import swift file

## 1.0.5
* fix pod swift version in podspec

## 1.0.4
* fix pod swift version to => config.build_settings['SWIFT_VERSION'] = '4.2'

## 1.0.3
* _MVVMContentState now call super.dispose first

## 1.0.2
* kotlin_version is now '1.3.0'

## 1.0.1
* Fix formatting i18N
* fix pubspec descrption, removed author

## 1.0.0
* Fix formatting
* Removed deprecated method inheritFromWidgetOfExactType from presenter_builder

## 0.0.1
* First version : Creates a MMVMPage with MVVM design pattern
