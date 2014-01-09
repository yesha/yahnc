//
//  YHNThreadViewController.h
//  YAHNC
//
//  Created by Daniel Ge on 12/12/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHNArticle.h"

@interface YHNThreadViewController : UITableViewController <UITextViewDelegate>

@property (strong, nonatomic) YHNArticle *article;

- (CGSize)labelSizeForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
