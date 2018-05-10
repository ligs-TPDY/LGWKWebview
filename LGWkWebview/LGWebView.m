//
//  LGWebView.m
//  webviewLG
//
//  Created by 李广帅 on 2018/4/18.
//  Copyright © 2018年 天蓬大元. All rights reserved.
//

#import "LGWebView.h"
#import <objc/runtime.h>
#import "WKDelegateController.h"
@interface LGWebView ()

@end

@implementation LGWebView

+ (LGWebView *)sharedInstance{
    static LGWebView *theSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIWebView *userAgentWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *userAgent = [userAgentWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        if (![userAgent containsString:@"TaoGuWang"]) {
            NSString *newUserAgent = [userAgent stringByAppendingString:@" TaoGuWang"];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        }
        
        WKWebViewConfiguration *configuretion = [[WKWebViewConfiguration alloc]init];
        NSLog(@"config%@",configuretion);
        configuretion.preferences = [[WKPreferences alloc] init];
        configuretion.preferences.minimumFontSize = 10;
        configuretion.preferences.javaScriptEnabled = YES;
        configuretion.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuretion.suppressesIncrementalRendering = YES;
        configuretion.selectionGranularity = YES;
        configuretion.userContentController = [[WKUserContentController alloc] init];
        
        // 禁止选择CSS
        NSString *css = @"body{-webkit-user-select:none;-webkit-user-drag:none;}";
        // CSS选中样式取消
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"var style = document.createElement('style');"];
        [javascript appendString:@"style.type = 'text/css';"];
        [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];
        [javascript appendString:@"style.appendChild(cssContent);"];
        [javascript appendString:@"document.body.appendChild(style);"];
        // javascript注入
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        [configuretion.userContentController addUserScript:noneSelectScript];
        
        theSharedInstance = [[LGWebView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) configuration:configuretion];
        theSharedInstance.allowsBackForwardNavigationGestures = YES;
        
        theSharedInstance.DelegateController = [[WKDelegateController alloc]init];
        //约定的方法//
        NSArray *arrayForJS = @[@"WebArticalModel",@"CMDModel",@"BuyGoodsModel",@"ShareModel",
                                @"GiveGift",@"Attent",@"SelfMail",@"ChatDetail",
                                @"StockEdit",@"InvestBuy",@"workRoomInvestJump",@"CallNaBullets"];
        for (NSString *JS in arrayForJS) {
            [configuretion.userContentController addScriptMessageHandler:theSharedInstance.DelegateController name:JS];
        }
        //和js端约定好的方法，在这里注入，js端可以调用
        //注意：前端用这里创建的对象来调用下面约定的方法，所以在注册方法之前，必须要先创建该对象
        NSArray *array =
        @[@"var tgwClient={}",
          @"tgwClient.onShareTGCircle = function(json) { window.webkit.messageHandlers.WebArticalModel.postMessage({body: json}) }",
          @"tgwClient.onShareOther = function(json) { window.webkit.messageHandlers.WebArticalModel.postMessage({body: json}) }",
          @"tgwClient.onCMDParse = function(json) { window.webkit.messageHandlers.CMDModel.postMessage({body: json}) }",
          @"tgwClient.buyCommodity = function(json) { window.webkit.messageHandlers.BuyGoodsModel.postMessage({body: json}) }",
          @"tgwClient.onShareOtherClient = function(json) { window.webkit.messageHandlers.ShareModel.postMessage({body: json}) }",
          @"tgwClient.giveEnjoy = function(json) { window.webkit.messageHandlers.GiveGift.postMessage({body: json}) }",
          @"tgwClient.onSelfMail = function(json) { window.webkit.messageHandlers.SelfMail.postMessage({body: json}) }",
          @"tgwClient.onChatDetail = function(json) { window.webkit.messageHandlers.ChatDetail.postMessage({body: json}) }",
          @"tgwClient.attentConsult = function(json) { window.webkit.messageHandlers.Attent.postMessage({body: json}) }",
          @"tgwClient.onStockEdit = function(json) { window.webkit.messageHandlers.StockEdit.postMessage({body: json}) }",
          @"tgwClient.workRoomInvestBuy = function(json) { window.webkit.messageHandlers.InvestBuy.postMessage({body: json}) }",
          @"tgwClient.workRoomInvestJump = function(json) { window.webkit.messageHandlers.workRoomInvestJump.postMessage({body: json}) }",
          @"tgwClient.callNativeBullets = function(json) { window.webkit.messageHandlers.CallNaBullets.postMessage({body: json}) }"];
        for (NSString *script in array) {
            WKUserScript *user = [[WKUserScript alloc]initWithSource:script
                                                       injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                    forMainFrameOnly:YES];
            [configuretion.userContentController addUserScript:user];
        }
        
        [theSharedInstance loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com"]]];
    });
    return theSharedInstance;
}
@end
