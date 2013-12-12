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

- (IBAction)refreshButton:(id)sender
{
    [self reloadData];
}

- (void)reloadData
{
    [YHNScraper loadFrontpageAsync:^(YHNFrontpage *frontpage) {
        _articles = frontpage.articles;
        [self.tableView reloadData];
    }
    withFailureHandler:^(NSError *error){
        // TODO error message
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
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) // header row?
        return 1;
    else
        return _articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) { // header section?
        cell = [tableView dequeueReusableCellWithIdentifier:@"Header"
                                               forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Post"
                                               forIndexPath:indexPath];
        
        YHNArticle *article = _articles[indexPath.row];
        
        UILabel *postTitle = (UILabel*)[cell viewWithTag:1];
        UILabel *postScore = (UILabel*)[cell viewWithTag:2];
        // TODO timestamp
        UILabel *postCommentCount = (UILabel*)[cell viewWithTag:4];
        
        postTitle.text = [article title];
        postScore.text = [NSString stringWithFormat:@"%ld", (long)[article score]];
        postCommentCount.text = [NSString stringWithFormat:@"%ld comments",
                                 (long)[article commentCount]];
 
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        YHNArticle *object = _articles[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showPostDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        YHNArticle *object = _articles[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
