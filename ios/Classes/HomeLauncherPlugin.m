#import "HomeLauncherPlugin.h"
#import <home_launcher/home_launcher-Swift.h>

@implementation HomeLauncherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHomeLauncherPlugin registerWithRegistrar:registrar];
}
@end
