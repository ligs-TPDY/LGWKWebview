//
//  WKWebView+BackListDetail.m
//  LGWkWebview
//
//  Created by carnet on 2018/4/26.
//  Copyright © 2018年 LG. All rights reserved.
//

#import "WKWebView+BackListDetail.h"

#import <objc/runtime.h>

@interface WKWebView ()

@end

@implementation WKWebView (BackListDetail)

static char kFirstName;

- (WKBackForwardList *)backForwardList;
{
    return objc_getAssociatedObject(self, &kFirstName);
}

- (void)setBackForwardList:(WKBackForwardList *)backForwardList;
{
    objc_setAssociatedObject(self, &kFirstName, backForwardList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}


@end
