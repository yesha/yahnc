//
//  DDURLParser.h
//
//
//  Created by Dimitris Doukas on 09/02/2010.
//  Copyright 2010 doukasd.com. All rights reserved.
//
//  Modified by Daniel Ge on 11/29/2013
//

#import <Foundation/Foundation.h>

@interface DDURLParser : NSObject

@property (nonatomic, retain, readonly) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end