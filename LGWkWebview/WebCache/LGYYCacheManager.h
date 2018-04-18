//
//  LGYYCacheManager.h
//  LGWkWebview
//
//  Created by carnet on 2018/4/18.
//  Copyright © 2018年 LG. All rights reserved.
//


#define DL_SINGLETON_DEF(_type_) + (_type_ *)sharedInstance;\
+(instancetype) alloc __attribute__((unavailable("call sharedInstance instead")));\
+(instancetype) new __attribute__((unavailable("call sharedInstance instead")));\
-(instancetype) copy __attribute__((unavailable("call sharedInstance instead")));\
-(instancetype) mutableCopy __attribute__((unavailable("call sharedInstance instead")));\

#define DL_SINGLETON_IMP(_type_) + (_type_ *)sharedInstance{\
static _type_ *theSharedInstance = nil;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
theSharedInstance = [[super alloc] init];\
});\
return theSharedInstance;\
}

#import <Foundation/Foundation.h>

#import "YYCache.h"

@interface LGYYCacheManager : NSObject

@property (nonatomic,strong) YYCache *cache;

@property (nonatomic,assign) NSInteger countLimit;
@property (nonatomic,assign) NSInteger costLimit;
@property (nonatomic,assign) NSTimeInterval ageLimit;
@property (nonatomic,assign) NSInteger freeDiskSpaceLimit;

DL_SINGLETON_DEF(LGYYCacheManager)

@end
