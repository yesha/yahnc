//
//  YHNComment.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNComment.h"

@implementation YHNComment

// Convenience method for adding a child comment
- (void)addChild:(YHNComment *)comment
{
    [self.children addObject:comment];
    comment.parent = self;
}

@end
