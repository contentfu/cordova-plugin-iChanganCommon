#import "iChanganCommon.h"
#import "AppDelegate.h"
#import "ChameleonCDVViewController.h"
#import "SSKeychain.h"
#import "SSKeychainQuery.h"
#import "BaiduPilotViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "NaviRoutesViewController.h"
#import "QrCodeScanViewController.h"



@interface iChanganCommon()<CLLocationManagerDelegate>

@property (strong, nonatomic)CLLocationManager *locationManager;

@end

@implementation iChanganCommon
@synthesize locationManager = _locationManager;
/*
 * 打开文件下载，或者安装应用
 * 安装应用的url格式: itms-services://?action=download-manifest&url=your_plist_url
 * 如 itms-services://?action=download-manifest&url=https://m.changan.com.cn:5222/bsl-web/mam/attachment/
 * download/5405fb87e4b0139f354cbfee'
 */
- (void)download:(CDVInvokedUrlCommand*)command
{
    CDVCommandStatus status = CDVCommandStatus_ERROR;
    
    if(command.arguments && command.arguments.count > 0)
    {
        NSString* url = [command argumentAtIndex:0];
        NSURL* installURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", url]];
        BOOL ok = [[UIApplication sharedApplication] openURL:installURL];
        status = ok ? CDVCommandStatus_OK:CDVCommandStatus_ERROR;
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)appExists:(CDVInvokedUrlCommand *)command
{
    CDVCommandStatus status = CDVCommandStatus_OK;
    CDVPluginResult* pluginResult;
    
    // TODO: 采用MDM方式获取应用列表
    if (command.arguments && command.arguments.count == 0) {
        status = CDVCommandStatus_ERROR;
        pluginResult = [CDVPluginResult resultWithStatus:status messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"exists", @"", @"version", nil]];
    }else {
        BOOL exists = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",[command argumentAtIndex:0]]]];
        pluginResult = [CDVPluginResult resultWithStatus:status messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:exists], @"exists", @"", @"version", nil]];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getDeviceId:(CDVInvokedUrlCommand *)command
{
    CDVCommandStatus status = CDVCommandStatus_OK;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:status messageAsString:[iChanganCommon getUniqueDeviceIdentifierAsString]];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openApp:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    
    if (command.arguments && command.arguments.count == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
    }else {
        BOOL exists = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",[command argumentAtIndex:0]]]];
        
        pluginResult = [CDVPluginResult resultWithStatus:exists?CDVCommandStatus_OK:CDVCommandStatus_ERROR messageAsBool:YES];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

+(NSString *)getUniqueDeviceIdentifierAsString
{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
}

- (void)getLocationPermission:(CDVInvokedUrlCommand*)command {

    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

- (void)openAutoNaviRouteView:(CDVInvokedUrlCommand*)command{
    
    BaiduPilotViewController *temp = [[BaiduPilotViewController alloc] init];
    temp.dataSource = command.arguments;
    temp.cordovaWebView = self.webView;
    [(UINavigationController*)[self getCurrentVC] pushViewController:temp animated:YES];
}

- (void)startNavi:(CDVInvokedUrlCommand *)command{
    NSDictionary *startInfo = command.arguments[0];
    NSDictionary *endInfo = command.arguments[1];
    
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake([[startInfo objectForKey:@"lat"] floatValue], [[startInfo objectForKey:@"lng"] floatValue]);
    CLLocationCoordinate2D end = CLLocationCoordinate2DMake([[endInfo objectForKey:@"lat"] floatValue], [[endInfo objectForKey:@"lng"] floatValue]);
    NaviRoutesViewController *vc = [[NaviRoutesViewController alloc]initWithSrc:start dst:end addr:[endInfo objectForKey:@"address"]];
    [[AppDelegate instance].naviController pushViewController:vc animated:YES];
}
//获取当前viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (void)scanBarCode:(CDVInvokedUrlCommand*)command
{
    QrCodeScanViewController *temp = [[QrCodeScanViewController alloc] init];
    temp.scanResultBlock = ^(NSString *data){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:data];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    };
    [(UINavigationController*)[self getCurrentVC] pushViewController:temp animated:YES];
    return;
}

- (BOOL)shouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = [request URL];
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked:{
            // Note that the rejection strings will *only* print if
            // it's a link click (and url is not whitelisted by <allow-*>)
            // the url *is* in a <allow-intent> tag, push to the system
            return [self openInSystemBrowser:url];
        }
            // fall through, to check whether you can load this in the webview
        default:
            // check whether we can internally navigate to this url
            return NO;
    }
}

- (BOOL)openInSystemBrowser:(NSURL *)url{
    NSString *urlString = url.absoluteString;
    NSRange range = [urlString rangeOfString:@"?"];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *parameters = [urlString substringFromIndex:(int)(range.location+1)];
    NSArray *subArray = [parameters componentsSeparatedByString:@"&"];
    for (int i = 0; i < subArray.count; i ++) {
        NSArray *dicArr = [subArray[i] componentsSeparatedByString:@"="];
        [dict setObject:dicArr[1] forKey:dicArr[0]];
    }
    NSString * flag = [dict objectForKey:@"__open-system-browser__"];
    if (flag && [flag isEqualToString:@"true"]) {
        
        NSRange range = [urlString rangeOfString:@"&" options:NSBackwardsSearch];
        
        NSString *fixedUrlStr = [urlString substringWithRange:NSMakeRange(0, range.location)];
        
        NSURL *fixedUrl = [NSURL URLWithString:fixedUrlStr];
        
        [[UIApplication sharedApplication] openURL:fixedUrl];
        
        return YES;
        
    }else{
        
        return NO;
        
    }
}

#pragma mark --- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _locationManager = nil;
}


@end
