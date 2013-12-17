//
//  YHNWebViewController.h
//  YAHNC
//
//  Created by Christian Barcenas on 12/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YHNArticle.h"

@interface YHNWebViewController : UIViewController

@property (nonatomic, strong, readonly) YHNArticle *article;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
