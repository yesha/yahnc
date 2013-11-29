//
//  YHNFrontpage.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNFrontpage.h"

@interface YHNFrontpage ()

@property (nonatomic, strong, readwrite) NSArray *articles;
@property (nonatomic, strong, readwrite) NSURL *moreUrl;

@end

@implementation YHNFrontpage

- (id)initWithArticles:(NSArray *)articles moreUrl:(NSURL *)moreUrl
{
    if (self = [self init]) {
        self.articles = articles;
        self.moreUrl = moreUrl;
    }
    
    return self;
}

@end
