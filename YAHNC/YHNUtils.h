//
//  YHNUtils.h
//  YAHNC
//
//  Created by Daniel Ge on 11/21/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]
#define methodNotImplemented() mustOverride()

@interface NSString (YHNStringUtilities)

- (BOOL)startsWith:(NSString *)substring;

@end

@interface YHNUtils : NSObject

@end
