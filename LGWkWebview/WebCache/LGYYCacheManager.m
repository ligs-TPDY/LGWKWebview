
//
//  LGYYCacheManager.m
//  LGWkWebview
//
//  Created by carnet on 2018/4/18.
//  Copyright © 2018年 LG. All rights reserved.
//





#import "LGYYCacheManager.h"

@implementation LGYYCacheManager

DL_SINGLETON_IMP(LGYYCacheManager)

- (void)setCache:(YYCache *)cache
{
    _cache = cache;
    
    _cache.diskCache.countLimit = _countLimit;
    _cache.diskCache.costLimit = _costLimit;
    _cache.diskCache.ageLimit = _ageLimit;
    _cache.diskCache.freeDiskSpaceLimit = _freeDiskSpaceLimit;
}

@end
