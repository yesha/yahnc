//
//  YHNArticle.h
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHNArticle : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *originSite;
@property (nonatomic, strong) NSURL *commentsUrl;

@property (nonatomic) NSInteger rank;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger commentCount;
@property (nonatomic, strong) NSString *timeInfo;

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSURL *userUrl;

@end
