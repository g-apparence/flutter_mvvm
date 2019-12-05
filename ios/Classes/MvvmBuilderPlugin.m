#import "MvvmBuilderPlugin.h"
#import <mvvm_builder/mvvm_builder-Swift.h>

@implementation MvvmBuilderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMvvmBuilderPlugin registerWithRegistrar:registrar];
}
@end
