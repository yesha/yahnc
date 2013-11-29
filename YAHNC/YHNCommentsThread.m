//
//  YHNCommentsThread.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNCommentsThread.h"

@interface YHNCommentsThread ()

// Re-declare properties to make them readwrite privately
@property (nonatomic, strong, readwrite) YHNArticle *article;
@property (nonatomic, strong, readwrite) NSArray *parentComments;

@end

@implementation YHNCommentsThread

- (id)initWithArticle:(YHNArticle *)article comments:(NSArray *)parentComments
{
    self = [self init];
    if (self) {
        self.article = article;
        self.parentComments = parentComments;
    }

    return self;
}

- (YHNComment *)commentWithIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger first = [indexPath indexAtPosition:0];
    if (first >= [self.parentComments count]) {
        return nil;
    }
    YHNComment *comment = self.parentComments[first];

    NSUInteger indexes[[indexPath length]];
    [indexPath getIndexes:indexes];

    // &indexes[1] essentially "pops" off the first element
    NSIndexPath *poppedPath = [NSIndexPath indexPathWithIndexes:&indexes[1]
                                                         length:([indexPath length] - 1)];

    return [comment childCommentAtIndexPath:poppedPath];
}

@end
