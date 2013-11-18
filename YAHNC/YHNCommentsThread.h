//
//  YHNCommentsThread.h
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YHNArticle.h"

@interface YHNCommentsThread : NSObject

@property (nonatomic, strong, readonly) YHNArticle *article;
@property (nonatomic, strong) NSArray *parentComments;

@end
