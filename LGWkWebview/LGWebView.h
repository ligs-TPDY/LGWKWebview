//
//  LGWebView.h
//  webviewLG
//
//  Created by 李广帅 on 2018/4/18.
//  Copyright © 2018年 天蓬大元. All rights reserved.
//

@class WKDelegateController;

#import <WebKit/WebKit.h>

@interface LGWebView : WKWebView

//标记是否已经注册过方法
@property (nonatomic,strong) NSString *mark;
@property (nonatomic,strong) WKDelegateController *DelegateController;


+ (LGWebView *)sharedInstance;


@end
