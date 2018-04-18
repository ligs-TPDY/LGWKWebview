//
//  ViewController2.m
//  LGWkWebview
//
//  Created by carnet on 2018/4/17.
//  Copyright © 2018年 LG. All rights reserved.
//

#import "ViewController2.h"

#import "RootWKWebViewViewController.h"

#import "YMWebCacheProtocol.h"

#import "AFNetworking.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *arr = @[@"https://www.jianshu.com",
                     @"https://github.com",
                     @"https://www.baidu.com",
                     @"https://www.csdn.net"];
    for (int i = 0; i < arr.count; i++) {
        NSString *str = arr[i];
        
        UIButton* button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:str forState:UIControlStateNormal];
        
        button.frame = CGRectMake(10, 100 * (i + 1), 300, 50);
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button.tag = i;
    }
}
- (void)click:(UIButton *)button
{
    if (button.tag == 0) {
        [self testAFN_NSURLProtocol];
    }else{
        RootWKWebViewViewController *webview = [[RootWKWebViewViewController alloc]init];
        webview.strForUrl = button.titleLabel.text;
        [self.navigationController pushViewController:webview animated:YES];
    }
}

- (void)testAFN_NSURLProtocol
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://api.douban.com/v2/book/isbn/9787505715660" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *bookInfo = (NSDictionary*)responseObject;
        NSLog(@"bookInfo:%@",bookInfo);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request faile:%@",error.description);
    }];
}


@end
