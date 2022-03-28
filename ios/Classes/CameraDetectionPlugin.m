#import "CameraDetectionPlugin.h"
#if __has_include(<camera_detection/camera_detection-Swift.h>)
#import <camera_detection/camera_detection-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "camera_detection-Swift.h"
#endif

@implementation CameraDetectionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCameraDetectionPlugin registerWithRegistrar:registrar];
}
@end
