#import <Cordova/CDVPlugin.h>

@interface iChanganCommon : CDVPlugin {}

- (void)download:(CDVInvokedUrlCommand*)command;
- (void)appExists:(CDVInvokedUrlCommand*)command;
- (void)getDeviceId:(CDVInvokedUrlCommand*)command;
- (void)openApp:(CDVInvokedUrlCommand*)command;

+ (NSString *)getUniqueDeviceIdentifierAsString;

- (void)openAutoNaviRouteView:(CDVInvokedUrlCommand*)command;
- (void)getLocationPermission:(CDVInvokedUrlCommand*)command;
- (void)startNavi:(CDVInvokedUrlCommand*)command;
//二维码扫描
- (void)scanBarCode:(CDVInvokedUrlCommand*)command;
@end
