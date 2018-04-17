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
    
    
    [YMWebCacheProtocol start];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    NSMutableDictionary *dicForPar = [[NSMutableDictionary alloc] initWithDictionary:@{@"fileFullPath":@"tgw/chat/image/25h58pic3eg_114.jpg",@"cover":@1}];

    [manager POST:@"http://172.18.44.128:8051/upload/file" parameters:dicForPar constructingBodyWithBlock:^(id<AFMultipartFormData> formData){

        UIImage *img = [UIImage imageNamed:@"qwe.png"];
        NSData *data = UIImageJPEGRepresentation(img, 1.0);

        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:@"test.jpg"
                                mimeType:@"application/octet-stream"];

    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
    
//    [self.navigationController pushViewController:[[RootWKWebViewViewController alloc]init] animated:YES];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"123" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

@end
