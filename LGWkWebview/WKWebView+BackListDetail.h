//
//  WKWebView+BackListDetail.h
//  LGWkWebview
//
//  Created by carnet on 2018/4/26.
//  Copyright © 2018年 LG. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (BackListDetail)

- (WKBackForwardList *)backForwardList;

- (void)setBackForwardList:(WKBackForwardList *)backForwardList;

@end
