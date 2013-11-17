//
//  YHNFrontpage.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNFrontpage.h"

@implementation YHNFrontpage

- (id)initWithArticles:(NSArray *)articles moreUrl:(NSURL *)moreUrl
{
    if (self = [self init]) {
        _articles = articles;
        _moreUrl = moreUrl;
    }
    
    return self;
}

@end
