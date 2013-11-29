//
//  YHNArrayStack.h
//  YAHNC
//
//  Created by Daniel Ge on 11/24/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHNStack.h"

@interface YHNArrayStack : YHNStack

- (void)push:(id)object;

- (id)pop;

- (id)peek;

- (NSUInteger)count;

@end
