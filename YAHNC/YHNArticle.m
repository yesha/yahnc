//
//  YHNArticle.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNArticle.h"

@interface YHNArticle ()

@property (nonatomic, readwrite) BOOL isShowHN;
@property (nonatomic, readwrite) BOOL isAskHN;
@property (nonatomic, readwrite) BOOL isJobPost;

@end

@implementation YHNArticle

- (void)setTitle:(NSString *)title
{
    if ([title startsWith:@"Show HN"]) {
        self.isShowHN = YES;
    } else if ([title startsWith:@"Ask HN"]) {
        self.isAskHN = YES;
    }

    _title = title;
}

@end
