//
//  YHNComment.h
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHNComment : NSObject

@property (nonatomic, strong) YHNComment *parent;

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSURL *userUrl;

@property (nonatomic, strong) NSURL *permalink;
@property (nonatomic, strong) NSString *contents;
@property (nonatomic, strong) NSString *timeInfo;

// measure of comment quality (pretty much the only way to represent that)
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) NSURL *replyUrl;

@end
