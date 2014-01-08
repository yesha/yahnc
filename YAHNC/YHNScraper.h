//
//  YHNScraper.h
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YHNFrontpage.h"
#import "YHNCommentsThread.h"

@interface YHNScraper : NSObject

+ (void)loadFrontpageAsync:(NSUInteger)pageType
                   success:(void (^) (YHNFrontpage *frontpage))success
                   failure:(void (^) (NSError *error))failure;
+ (void)loadThreadAsync:(YHNArticle *)article
                success:(void (^) (YHNCommentsThread *thread))success
                failure:(void (^) (NSError *error))failure;

@end
