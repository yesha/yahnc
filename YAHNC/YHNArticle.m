//
//  YHNArticle.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNArticle.h"

@implementation YHNArticle

- (void)setTitle:(NSString *)title
{
    if ([YHNUtils string:title startsWith:@"Show HN"]) {
        _isShowHN = YES;
    } else if ([YHNUtils string:title startsWith:@"Ask HN"]) {
        _isAskHN = YES;
    }
}

@end
