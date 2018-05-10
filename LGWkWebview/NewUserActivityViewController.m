//
//  NewUserActivityViewController.m
//  LGWkWebview
//
//  Created by carnet on 2018/5/2.
//  Copyright © 2018年 LG. All rights reserved.
//

#import "NewUserActivityViewController.h"
#import "UpLoadFileViewController.h"
@interface NewUserActivityViewController ()

@end

@implementation NewUserActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)goNext{
    UpLoadFileViewController *con = [[UpLoadFileViewController alloc]init];
    con.requsetURL = @"https://www.baidu.com/";
    [self.navigationController pushViewController:con animated:YES];
}

@end
