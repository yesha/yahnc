//
//  YHNDetailViewController.m
//  YAHNC
//
//  Created by Daniel Ge on 11/11/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNDetailViewController.h"
#import "YHNScraper.h"
#import "YHNModels.h"

@interface YHNDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) IBOutlet UILabel *postTitle;
@property (strong, nonatomic) IBOutlet UILabel *postVoteNum;
@property (strong, nonatomic) IBOutlet UILabel *postTime;
@property (strong, nonatomic) IBOutlet UILabel *postCommentNum;
@property (strong, nonatomic) IBOutlet UILabel *postLink;

@property (strong, nonatomic) YHNCommentsThread *thread;
- (void)configureView;
@end

@implementation YHNDetailViewController

#pragma mark - Managing the detail item

- (void)setArticle:(id)article
{
    if (_article != article) {
        _article = article;
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)reloadData
{
    [YHNScraper loadThreadAsync:self.article success:^(YHNCommentsThread *thread) {
        self.thread = thread;
        NSLog(@"Thread loaded");
        [self configureView];
    } failure:^(NSError *error) {
        NSLog(@"Well, fuck... %@", error);
    }];
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.article) {
        self.postTitle.text   = [self.article title];
        self.postVoteNum.text = [NSString stringWithFormat:@"%li",
                                 (long)[self.article score]];
        // TODO timestamp
        self.postCommentNum.text = [NSString stringWithFormat:@"%li comments",
                                    (long)[self.article commentCount]];
        // TODO link?
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
