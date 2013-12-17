//
//  YHNFlatComment.m
//  YAHNC
//
//  Created by Daniel Ge on 12/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNFlatComment.h"

@interface YHNFlatComment ()

@property (nonatomic, strong, readwrite) YHNComment *comment;
@property (nonatomic, readwrite) NSInteger nesting;

@end

@implementation YHNFlatComment

- (id)initWithComment:(YHNComment *)comment nesting:(NSInteger)nesting
{
    self = [super init];
    if (self != nil) {
        self.comment = comment;
        self.nesting = nesting;
    }

    return self;
}

+ (NSArray *)flattenCommentThread:(YHNCommentsThread *)thread
{
    NSMutableArray *flatComments = [NSMutableArray new];
    NSArray *children = thread.parentComments;
    [YHNFlatComment flattenComments:children
                        accumulator:flatComments
                            nesting:0];

    return flatComments;
}

+ (void)flattenComments:(NSArray *)children
            accumulator:(NSMutableArray *)flatComments
                nesting:(NSInteger)nesting
{
    // Perform a pre-order traversal of the comment tree
    for (YHNComment *comment in children) {
        YHNFlatComment *flatComment = [[YHNFlatComment alloc] initWithComment:comment
                                                                      nesting:nesting];
        [flatComments addObject:flatComment];
        [YHNFlatComment flattenComments:comment.children
                            accumulator:flatComments
                                nesting:(nesting + 1)];
    }
}

@end
