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
@property (nonatomic, strong) NSString *commentsId;

@property (nonatomic) NSInteger rank;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger commentCount;
@property (nonatomic, strong) NSString *timeInfo;

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, readonly) BOOL isShowHN;
@property (nonatomic, readonly) BOOL isAskHN;
@property (nonatomic, readonly) BOOL isJobPost;

@end
