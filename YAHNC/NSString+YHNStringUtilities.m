//
//  NSString+YHNStringUtilities.m
//  YAHNC
//
//  Created by Daniel Ge on 1/6/14.
//  Copyright (c) 2014 YAHNC. All rights reserved.
//

#import "NSString+YHNStringUtilities.h"

@implementation NSString (YHNStringUtilities)

- (BOOL)startsWith:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring options:NSAnchoredSearch];
    return range.location != NSNotFound;
}

@end
