//
//  YHNMasterViewController.m
//  YAHNC
//
//  Created by Daniel Ge on 11/11/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNScraper.h"
#import "YHNFrontpage.h"

#import "YHNMasterViewController.h"

#import "YHNDetailViewController.h"

@interface YHNMasterViewController () {
    NSArray *_articles;
}
@end

@implementation YHNMasterViewController

- (IBAction)buttonTest:(id)sender
{
    [YHNScraper loadFrontpageAsync:^(YHNFrontpage *frontpage) {
        // wooooooooooooo!!!!!!!! 11/18 12:40 am
        NSLog(@"%@", ((YHNArticle*)frontpage.articles[0]).title);
        _articles = frontpage.articles;
        [self.tableView reloadData];
    }
    withFailureHandler:^(NSError *error){
        
    }];
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (YHNDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Post"
                                                            forIndexPath:indexPath];

    YHNArticle *article = _articles[indexPath.row];
    
    UILabel *postTitle = (UILabel*)[cell viewWithTag:1];
    UILabel *postScore = (UILabel*)[cell viewWithTag:2];
    // TODO timestamp
    UILabel *postCommentCount = (UILabel*)[cell viewWithTag:4];
    
    postTitle.text = [article title];
    postScore.text = [NSString stringWithFormat:@"%d", [article score]];
    postCommentCount.text = [NSString stringWithFormat:@"%d comments", [article commentCount]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _articles[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _articles[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
