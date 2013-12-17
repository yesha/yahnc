//
//  YHNWebViewController.m
//  YAHNC
//
//  Created by Christian Barcenas on 12/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNWebViewController.h"

#import "MBProgressHUD/MBProgressHUD.h"

@interface YHNWebViewController ()

@property (nonatomic, strong, readwrite) YHNArticle *article;

@end

@implementation YHNWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadWebPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshButtonPressed:(id)sender
{
    [self loadWebPage];
}

- (void)loadWebPage
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:self.article.url]];
        
        while (self.webView.loading);
        
        self.title = self.article.title;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

@end
