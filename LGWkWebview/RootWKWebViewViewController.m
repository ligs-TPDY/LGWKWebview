//
//  RootWKWebViewViewController.m
//  AppBasicFramework
//
//  Created by 李广帅 on 2017/12/12.
//  Copyright © 2017年 IGS. All rights reserved.
//

#import "RootWKWebViewViewController.h"

//自动布局第三方库
#import "Masonry.h"

//导入头文件
#import <WebKit/WebKit.h>
//避免JS交互时的循环引用导致内存泄漏
#import "WKDelegateController.h"
//webview缓存
#import "YMWebCacheProtocol.h"

//webview单例
#import "LGWebView.h"
//清空返回列表
#import "WKWebView+BackListDetail.h"

@interface RootWKWebViewViewController ()<WKUIDelegate,WKNavigationDelegate,WKJSDelegate>
//webview
@property (nonatomic,strong) LGWebView *webView;

//进度条
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) NSTimer *progressTimer;
@property (nonatomic,assign) NSInteger progressing;
@property (nonatomic,strong) dispatch_source_t timer;//  注意:此处应该使用强引用 strong

//控制器的加载地址列表
@property (nonatomic,strong) NSMutableArray *mutArrForBackList;
@property (nonatomic,strong) NSString *markObjectExist;
@property (nonatomic,strong) NSString *markURLRedirection;
@end

@implementation RootWKWebViewViewController
#pragma mark - ----ControllerLifeCycle----
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册，设置缓存配置
    [YMWebCacheProtocol start];
    
    //初始化导航栏
    [self layoutUIWithBarButtonItem];
    [self layoutUIWithBarWebView];
    //初始化进度
    _progressing = 0;
    //初始化数据源
    _mutArrForBackList = [[NSMutableArray alloc]init];
    //加载请求
    [self loadRequset];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if ([_markObjectExist isEqualToString:@"存在"]) {
        self.webView = [LGWebView sharedInstance];
        [self.view addSubview:self.webView];
        [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.view).offset(64);
        }];
        
        [self.webView goBack];
    }
    
    //注册KVO
    [self setKVO];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    _markObjectExist = @"存在";
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    //移除KVO
    [self deallocKVO];
}
//加载请求
- (void)loadRequset
{
    NSString * strForNewUserActivity = _requsetURL;
    NSMutableURLRequest *requset = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strForNewUserActivity]];
    [self.webView loadRequest:requset];
}
#pragma mark - ----KVO----
- (void)setKVO
{
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.webView.estimatedProgress == 1.0) {
            self.progressing = 100;
        }
    }
    if ([keyPath isEqualToString:@"title"]) {
        self.navigationItem.title = self.webView.title;
    }
}
- (void)deallocKVO
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    
    [YMWebCacheProtocol end];
}
#pragma mark ----进度相关----
- (void)setProgressing:(NSInteger)progressing
{
    _progressing = progressing;
    //当进度为100时，隐藏进度条
    if (_progressing == 100) {
        [self.progressView setProgress:1 animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
            });
        });
    }
}
- (void)ProgressRunUp
{
    //80后停止定时器
    if (_progressing >= 80) {
        dispatch_source_cancel(_timer);
    }else{
        _progressing += 10;//每次进度+10
        [self.progressView setProgress:_progressing/100.0 animated:YES];
    }
}
- (void)startTime{
    //开始加载
    self.progressView.hidden = NO;
    self.navigationItem.title = @"加载中......";
    //开启定时器
    dispatch_queue_t queue = dispatch_get_main_queue();
    //1.创建GCD中的定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //2.设置时间等
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //3.要调用的任务
    dispatch_source_set_event_handler(timer, ^{
        //        NSLog(@"GCD-----%@",[NSThread currentThread]);
        [self ProgressRunUp];
    });
    //4.开始执行
    dispatch_resume(timer);
    self.timer = timer;
}
#pragma mark - --WKNavigationDelegate--
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"在发送请求之前，决定是否跳转");
    NSLog(@"当前请求的URL = %@",navigationAction.request.URL.absoluteString);
    [_mutArrForBackList addObject:webView.URL];
    [self startTime];
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面开始加载时调用===%@",webView.URL);
}
// 接收到服务器跳转请求之后调用，主机地址被重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"接收到服务器跳转请求之后调用===%@",webView.URL);
    [_mutArrForBackList removeLastObject];
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
    NSLog(@"当内容开始返回时调用===%@",webView.URL);
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载完成之后调用===%@",webView.URL);
    NSLog(@"%@",webView.title);
    self.navigationItem.title = webView.title;
    self.progressing = 100;
    
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载失败时调用===%@",webView.URL);
}
#pragma mark ----WKScriptMessageHandler----
///JS==>Native交互
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"\n JS==>Native交互 \n url = %@",self.webView.URL.absoluteString);
    NSLog(@"\n JS==>Native交互 \n message.name = %@",message.name);
//    NSString *body = [message.body objectForKey:@"body"];
    if (![[message.body objectForKey:@"body"] isKindOfClass:[NSString class]]) {
        return ;
    }
//    NSString *encodeBody = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([message.name isEqualToString:@"WebArticalModel"]) {
        NSLog(@"%@",message.name);
    }else if([message.name isEqualToString:@"CMDModel"]){
        NSLog(@"%@",message.name);
    }else if([message.name isEqualToString:@"BuyGoodsModel"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"ShareModel"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"GiveGift"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"SelfMail"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"ChatDetail"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"StockEdit"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"Attent"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"InvestBuy"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"workRoomInvestJump"]){
        NSLog(@"%@",message.name);
    }else if ([message.name isEqualToString:@"CallNaBullets"]){
        NSLog(@"%@",message.name);
    }else{
        NSLog(@"注意，出现了未注册的前端协议");
    }
}
#pragma mark - ----NavigationControllerEvent----
- (void)goBack
{
    if (self.mutArrForBackList.count == 1) {
        //当webview界面返回时，显示上一控制器底部的tabbar
        [self noHidesBottomBarWhenPushed];
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.webView.canGoBack) {
        [self.webView goBack];
        [self.webView reload];
    }else{
        //当webview界面返回时，显示上一控制器底部的tabbar
        [self noHidesBottomBarWhenPushed];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//当该界面返回上一界面时，需要显示tabbar。
- (void)noHidesBottomBarWhenPushed{
    NSLog(@"返回webview的上一界面");
    NSArray *array = [self.navigationController viewControllers];
    NSInteger count = array.count;
    NSLog(@"pushViewControllersCount == %d",count);
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    NSInteger webviewCount = 0;
    for (NSInteger i=0; i<count; i++) {
        UIViewController *vc = array[i];
        if ([vc isKindOfClass:[self class]]) {
            webviewCount ++;
            [mutArr addObject:[NSString stringWithFormat:@"%ld",i]];
        }
    }
    NSLog(@"pushViewControllersWebviewCount == %ld",webviewCount);
    if (webviewCount == 1 && mutArr.count ==1) {
        NSString *str = mutArr.firstObject;
        NSInteger index = [str integerValue];
        NSLog(@"pushViewControllersWebviewIndex == %ld",index);
        if (index >= 1) {
            //取出当前控制器前一个控制器。
            UIViewController *vc = array[index-1];
            //显示底部的tabbar
            vc.hidesBottomBarWhenPushed = NO;
            NSLog(@"显示底部的tabba == %@",[vc class]);
        }
    }
}
- (void)goNext
{
    NSLog(@"goNext");
}
#pragma mark - ----InitUI----
///导航表头设置
- (void)layoutUIWithBarButtonItem{
    //返回
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = left;
    //分享
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"下一个"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(goNext)];
    self.navigationItem.rightBarButtonItem = right;
}
///初始化webview
- (void)layoutUIWithBarWebView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    //        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuretion];
    self.webView = [LGWebView sharedInstance];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
    }];
    //设置代理
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    //加载进度
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(0, 64, self.view.frame.size.width, 5);
    self.progressView.tintColor = [UIColor redColor];
    [self.view addSubview:self.progressView];

    self.webView.DelegateController.delegate = self;
    
//    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
//    [self.webView addGestureRecognizer:pan];
}
//#pragma mark - WKUIDelegate
///**
// 输入框
// @param webView 当前的webview对象
// @param prompt 提示信息
// @param defaultText 输入框提示信息
// @param frame 当前webview的布局信息
// @param completionHandler 数据结果的回调
// */
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
//    //创建一个提示框控制器
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框"
//                                                                   message:prompt
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    //添加输入框
//    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = defaultText;
//    }];
//    //添加确定按钮
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        //将输入值传递给前端
//        completionHandler(alert.textFields.firstObject.text);
//    }];
//    [alert addAction:action];
//    //弹出提示框
//    [self presentViewController:alert animated:YES completion:nil];
//}
///**
// 确认框
//
// @param webView 当前的webview
// @param message 提示信息
// @param frame webview的布局信息
// @param completionHandler 回调
// */
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框"
//                                                                   message:message
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    //添加确定按钮
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction * _Nonnull action) {
//        //将结果返回给前端
//        completionHandler(YES);
//    }];
//    [alert addAction:action];
//    [self presentViewController:alert animated:YES completion:nil];
//}
///**
// 警告框
//
// @param webView 当前的webview
// @param message 提示信息
// @param frame webview的布局信息
// @param completionHandler 回调
// */
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告框"
//                                                                   message:message
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    //添加确定按钮
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [alert addAction:action];
//    [self presentViewController:alert animated:YES completion:nil];
//}
///**
// webview关闭时回调
//
// @param webView 当前的webview
// */
//- (void)webViewDidClose:(WKWebView *)webView {
//    NSLog(@"webview被关闭了");
//}
///**
//
// 当用户在当前页面点击新的跳转链接时，会首先调用WKNavigationDelegate协议中的
// - (void)webView:(WKWebView *)webView
// decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
// decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
// WKFrameInfo *sFrame = navigationAction.sourceFrame;//navigationAction的出处
// WKFrameInfo *tFrame = navigationAction.targetFrame;//navigationAction的目标
// //只有当  tFrame.mainFrame == NO；时，表明这个 WKNavigationAction 将会新开一个页面。
// //此时会调用下面的方法，创建一个新的webview来加载新的链接（如果有必要);
// }
//
// 创建一个新的WebView，或者在原对象上加载新链接
//
// @param webView 当前的webview
// @param configuration 配置信息
// @param navigationAction 导航动作对象
// @param windowFeatures window特性
// @return 下个页面执行加载任务的webview
// */
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
//
//    //如果只是打开一个新的地址，为此创建一个新的对象会消耗不必要的资源，所以此时可以在该协议方法中写入以下代码，在当前对象中加载新界面。
//    WKFrameInfo *frameInfo = navigationAction.targetFrame;
//    if (![frameInfo isMainFrame]) {
//        [webView loadRequest:navigationAction.request];
//    }else{
//
//    }
//    return nil;
//}
@end
