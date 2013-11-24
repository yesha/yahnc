//
//  YHNArrayStack.m
//  YAHNC
//
//  Created by Daniel Ge on 11/24/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNArrayStack.h"

#define DEFAULT_STACK_CAPACITY 8

@interface YHNArrayStack ()

@property (nonatomic, strong) NSMutableArray *stack;

@end

@implementation YHNArrayStack

- (id)init
{
    self = [self init];
    if (self) {
        self.stack = [[NSMutableArray alloc] initWithCapacity:DEFAULT_STACK_CAPACITY];
    }

    return self;
}

- (void)push:(id)object
{
    [self.stack addObject:object];
}

- (id)peek
{
    return [self.stack lastObject];
}

- (id)pop
{
    id object = [self.stack lastObject];
    [self.stack removeLastObject];
    return object;
}

- (NSUInteger)count
{
    return [self.stack count];
}

@end
