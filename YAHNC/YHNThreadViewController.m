//
//  YHNThreadViewController.m
//  YAHNC
//
//  Created by Daniel Ge on 12/12/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNThreadViewController.h"
#import "YHNScraper.h"
#import "YHNModels.h"

@interface YHNThreadViewController ()

@property (nonatomic, strong) YHNCommentsThread *thread;

@end

@implementation YHNThreadViewController
// TODO: Do we really want to use a TableView for this? It might actually not be the best choice,
// considering the fact that we will need to nest our tables

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)reloadData
{
    [YHNScraper loadThreadAsync:self.article success:^(YHNCommentsThread *thread) {
        self.thread = thread;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Well, fuck... %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return [[self.thread parentComments] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *articleCellId = @"Article";
    static NSString *commentCellId = @"Comment";

    UITableViewCell *cell;

    if ([indexPath section] == 0) {     // Article
        cell = [tableView dequeueReusableCellWithIdentifier:articleCellId
                                               forIndexPath:indexPath];

        YHNArticle *article = self.article;

        UILabel *postTitle = (UILabel*)[cell viewWithTag:1];
        UILabel *postScore = (UILabel*)[cell viewWithTag:2];
        // TODO timestamp
        UILabel *postCommentCount = (UILabel*)[cell viewWithTag:4];

        postTitle.text = [article title];
        postScore.text = [NSString stringWithFormat:@"%ld", (long)[article score]];
        postCommentCount.text = [NSString stringWithFormat:@"%ld comments",
                                 (long)[article commentCount]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:commentCellId
                                               forIndexPath:indexPath];
    }
    
    return cell;
}

@end
