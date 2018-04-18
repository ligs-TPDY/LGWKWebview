//
//  RootWKWebViewViewController.m
//  AppBasicFramework
//
//  Created by 李广帅 on 2017/12/12.
//  Copyright © 2017年 IGS. All rights reserved.
//

#import "RootWKWebViewViewController.h"

//导入头文件
#import <WebKit/WebKit.h>
//避免JS交互时的循环引用导致内存泄漏
#import "WKDelegateController.h"
//webview缓存
#import "YMWebCacheProtocol.h"

@interface RootWKWebViewViewController ()<WKUIDelegate,WKNavigationDelegate,WKJSDelegate>
//加载webview
@property (nonatomic,strong) WKWebView *wkwebview;
//js交互对象
@property (nonatomic,strong) WKUserContentController* userContentController;
// 设置加载进度条
@property(nonatomic,strong) UIProgressView *  ProgressView;
@end

@implementation RootWKWebViewViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //注册，设置缓存配置
    [YMWebCacheProtocol start];
    
    {
        //初始化webview
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        _userContentController =[[WKUserContentController alloc]init];
        config.userContentController = _userContentController;
        _wkwebview = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:config];
        [self.view addSubview:_wkwebview];
        _wkwebview.UIDelegate = self;
        _wkwebview.navigationDelegate = self;
        //左右滑动上下翻页
        [_wkwebview setAllowsBackForwardNavigationGestures:YES];
        
        //进度条
        self.ProgressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.ProgressView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 10);
        [self.ProgressView setTrackTintColor:[UIColor clearColor]];
        self.ProgressView.progressTintColor = [UIColor blueColor];
        [self.view addSubview:self.ProgressView];
        
        //加载URL
        [_wkwebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_strForUrl]]];
        
        //监听加载进度
        [_wkwebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    //注册方法，使得前端可以到用我们的原生方法
    WKDelegateController * delegateController = [[WKDelegateController alloc]init];
    delegateController.delegate = self;
    [_userContentController addScriptMessageHandler:delegateController  name:@"sayhello"];
}
- (void)dealloc{
    //取消去进度的监听
    [_wkwebview removeObserver:self forKeyPath:@"estimatedProgress"];
    
    //这里需要注意，前面增加过的方法一定要remove掉。
    [_userContentController removeScriptMessageHandlerForName:@"sayhello"];
    
    [YMWebCacheProtocol end];
}
#pragma mark --进度监听回调方法--
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    // 首先，判断是哪个路径
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        // 判断是哪个对象
        if (object == _wkwebview) {
            NSLog(@"进度信息：%lf",_wkwebview.estimatedProgress);
            if (_wkwebview.estimatedProgress == 1.0) {
                //隐藏
                self.ProgressView.hidden = YES;
            }else{
                // 添加进度数值
                self.ProgressView.progress = _wkwebview.estimatedProgress;
            }
        }
    }
}
#pragma mark - --WKNavigationDelegate--
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"在发送请求之前，决定是否跳转");
    NSLog(@"当前请求的URL = %@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面开始加载时调用");
}
// 接收到服务器跳转请求之后调用，主机地址被重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"接收到服务器跳转请求之后调用");
}
// 在收到服务器响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"在收到服务器响应后，决定是否跳转");
    NSLog(@"重定向URL = %@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"当内容开始返回时调用");
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载完成之后调用");
    
    self.navigationItem.title = webView.title;
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载失败时调用");
}
#pragma mark - WKUIDelegate
/**
 输入框

 @param webView 当前的webview对象
 @param prompt 提示信息
 @param defaultText 输入框提示信息
 @param frame 当前webview的布局信息
 @param completionHandler 数据结果的回调
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    //创建一个提示框控制器
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框"
                                                                   message:prompt
                                                            preferredStyle:UIAlertControllerStyleAlert];
    //添加输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    //添加确定按钮
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //将输入值传递给前端
        completionHandler(alert.textFields.firstObject.text);
    }];
    [alert addAction:action];
    //弹出提示框
    [self presentViewController:alert animated:YES completion:nil];
}
/**
 确认框

 @param webView 当前的webview
 @param message 提示信息
 @param frame webview的布局信息
 @param completionHandler 回调
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    //添加确定按钮
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        //将结果返回给前端
        completionHandler(YES);
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
/**
 警告框

 @param webView 当前的webview
 @param message 提示信息
 @param frame webview的布局信息
 @param completionHandler 回调
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告框"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    //添加确定按钮
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
/**
 webview关闭时回调

 @param webView 当前的webview
 */
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"webview被关闭了");
}
/**
 
 当用户在当前页面点击新的跳转链接时，会首先调用WKNavigationDelegate协议中的
 - (void)webView:(WKWebView *)webView
 decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
 decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
 WKFrameInfo *sFrame = navigationAction.sourceFrame;//navigationAction的出处
 WKFrameInfo *tFrame = navigationAction.targetFrame;//navigationAction的目标
 //只有当  tFrame.mainFrame == NO；时，表明这个 WKNavigationAction 将会新开一个页面。
 //此时会调用下面的方法，创建一个新的webview来加载新的链接（如果有必要);
 }
 
 创建一个新的WebView，或者在原对象上加载新链接

 @param webView 当前的webview
 @param configuration 配置信息
 @param navigationAction 导航动作对象
 @param windowFeatures window特性
 @return 下个页面执行加载任务的webview
 */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    //如果只是打开一个新的地址，为此创建一个新的对象会消耗不必要的资源，所以此时可以在该协议方法中写入以下代码，在当前对象中加载新界面。
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }else{
        
    }
    return nil;
}

#pragma mark --WKJSDelegate--
/**
 JS调用原生方法回调

 @param userContentController 交互控制器
 @param message 信息
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
}
@end
