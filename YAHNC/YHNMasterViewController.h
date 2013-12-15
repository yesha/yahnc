//
//  YHNMasterViewController.h
//  YAHNC
//
//  Created by Daniel Ge on 11/11/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHNThreadViewController;

@interface YHNMasterViewController : UITableViewController

@property (strong, nonatomic) YHNThreadViewController *threadViewController;

typedef NS_ENUM(NSUInteger, menuBarEnum) {
    HOT = 0,
    NEW = 1,
    ASK = 2
};

@end
