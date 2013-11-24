//
//  YHNUtils.m
//  YAHNC
//
//  Created by Daniel Ge on 11/21/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNUtils.h"

@implementation YHNUtils

+ (BOOL)string:(NSString *)string startsWith:(NSString *)substring
{
    NSRange range = [string rangeOfString:substring options:NSAnchoredSearch];
    return range.location != NSNotFound;
}

@end
