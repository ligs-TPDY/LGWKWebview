//
//  LGWebView.m
//  webviewLG
//
//  Created by 李广帅 on 2018/4/18.
//  Copyright © 2018年 天蓬大元. All rights reserved.
//

#import "LGWebView.h"
#import <objc/runtime.h>
@interface LGWebView ()

@end

@implementation LGWebView

+ (LGWebView *)sharedInstance{
    static LGWebView *theSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        NSLog(@"config%@",config);
        theSharedInstance = [[LGWebView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) configuration:config];
    });
    
//    [theSharedInstance getProperties];
    
    return theSharedInstance;
}

//-(void)getProperties{
//    u_int count = 0;
//    Ivar *properties = class_copyIvarList([self class], &count);
//
//    for (int i = 0; i < count; i++) {
//        const char  *propertyName = property_getName(properties[i]);
//        const char  *attributes = property_getAttributes(properties[i]);
//        NSString *str = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
//        NSString *attributesStr = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
//        NSLog(@"propertyName : %&@", propertyName);
//        NSLog(@"attributesStr : %@", attributesStr);
//    }
//}
@end
