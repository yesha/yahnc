//
//  YHNStack.m
//  YAHNC
//
//  Created by Daniel Ge on 11/24/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNStack.h"

@implementation YHNStack

- (void)push:(id)object
{
    mustOverride();
}

- (id)pop
{
    mustOverride();
}

- (id)peek
{
    mustOverride();
}

- (NSUInteger)count
{
    mustOverride();
}

@end
