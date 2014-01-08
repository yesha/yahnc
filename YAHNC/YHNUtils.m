//
//  YHNUtils.m
//  YAHNC
//
//  Created by Daniel Ge on 11/21/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNUtils.h"

@implementation YHNUtils

+ (NSString *)currentDateTimeAsString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    return [formatter stringFromDate:[NSDate date]];
}

@end
