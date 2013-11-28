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
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic) NSInteger depth;

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSURL *userUrl;

@property (nonatomic, strong) NSURL *permalink;
@property (nonatomic, strong) NSAttributedString *contents;
@property (nonatomic, strong) NSString *timeInfo;

// measure of comment quality (pretty much the only way to represent that)
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) NSURL *replyUrl;

- (void)addChild:(YHNComment *)comment;

- (NSError *)setContentsWithHtml:(NSString *)html;

- (YHNComment *)childCommentAtIndexPath:(NSIndexPath *)indexPath;

@end
