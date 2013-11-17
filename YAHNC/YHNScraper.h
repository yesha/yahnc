//
//  YHNScraper.h
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YHNFrontpage.h"

@interface YHNScraper : NSObject

+ (YHNFrontpage *)loadFrontpage;
+ (YHNFrontpage *)loadFrontpageWithUrl:(NSURL *)frontpageUrl;

@end
