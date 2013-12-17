//
//  YHNFlatComment.h
//  YAHNC
//
//  Created by Daniel Ge on 12/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YHNCommentsThread.h"
#import "YHNComment.h"

@interface YHNFlatComment : NSObject

@property (nonatomic, strong, readonly) YHNComment *comment;
@property (nonatomic, readonly) NSInteger nesting;

- (id)initWithComment:(YHNComment *)comment nesting:(NSInteger)nesting;

+ (NSArray *)flattenCommentThread:(YHNCommentsThread *)thread;

@end
