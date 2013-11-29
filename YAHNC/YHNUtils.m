//
//  YHNUtils.m
//  YAHNC
//
//  Created by Daniel Ge on 11/21/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNUtils.h"

@implementation NSString (YHNStringUtilities)

- (BOOL)startsWith:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring options:NSAnchoredSearch];
    return range.location != NSNotFound;
}

@end

@implementation YHNUtils

@end
