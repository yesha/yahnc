//
//  YHNDetailViewController.h
//  YAHNC
//
//  Created by Daniel Ge on 11/11/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YHNArticle.h"

@interface YHNDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) YHNArticle *detailItem;

@end
