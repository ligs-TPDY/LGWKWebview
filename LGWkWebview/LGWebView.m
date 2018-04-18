//
//  LGWebView.m
//  webviewLG
//
//  Created by 李广帅 on 2018/4/18.
//  Copyright © 2018年 天蓬大元. All rights reserved.
//

#import "LGWebView.h"

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
    return theSharedInstance;
}

@end
