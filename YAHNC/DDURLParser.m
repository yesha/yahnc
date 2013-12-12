//
//  DDURLParser.m
//
//
//  Created by Dimitris Doukas on 09/02/2010.
//  Copyright 2010 doukasd.com. All rights reserved.
//
//  Modified by Daniel Ge on 11/29/2013
//

#import "DDURLParser.h"

@interface DDURLParser ()
@property (nonatomic, retain, readwrite) NSArray *variables;
@end

@implementation DDURLParser

- (id) initWithURLString:(NSString *)url{
    self = [super init];
    if (self != nil) {
        NSString *string = url;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
        NSString *tempString;
        NSMutableArray *vars = [NSMutableArray new];
		//ignore the beginning of the string and skip to the vars
        [scanner scanUpToString:@"?" intoString:nil];
        while ([scanner scanUpToString:@"&" intoString:&tempString]) {
            [vars addObject:tempString];
        }
        self.variables = vars;
    }
    return self;
}

- (NSString *)valueForVariable:(NSString *)varName {
    for (NSString *var in self.variables) {
        if ([var length] > [varName length]+1 && [[var substringWithRange:NSMakeRange(0, [varName length]+1)] isEqualToString:[varName stringByAppendingString:@"="]]) {
            NSString *varValue = [var substringFromIndex:[varName length]+1];
            return varValue;
        }
    }
    return nil;
}

@end
