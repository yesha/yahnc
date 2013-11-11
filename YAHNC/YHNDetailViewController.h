//
//  YHNDetailViewController.h
//  YAHNC
//
//  Created by Daniel Ge on 11/11/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHNDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
