//
//  YHNFrontpage.h
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHNFrontpage : NSObject

@property (nonatomic, strong, readonly) NSArray *articles;
@property (nonatomic, strong, readonly) NSURL *moreUrl;

- (id)initWithArticles:(NSArray *)articles moreUrl:(NSURL *)moreUrl;

@end
