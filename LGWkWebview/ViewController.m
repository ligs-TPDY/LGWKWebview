//
//  ViewController.m
//  LGWkWebview
//
//  Created by carnet on 2018/4/17.
//  Copyright © 2018年 LG. All rights reserved.
//

#import "ViewController.h"

#import "ViewController2.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    ViewController2 *root = [[ViewController2 alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:root];
    
    [self presentViewController:nav animated:YES completion:nil];
}

@end
