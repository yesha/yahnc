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

@interface YHNThreadViewController () {
    NSUInteger parentCommentIndex;
}

@property (nonatomic, strong) YHNCommentsThread *thread;

@end

@implementation YHNThreadViewController
// TODO: Do we really want to use a TableView for this? It might actually not be the best choice,
// considering the fact that we will need to nest our tables

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    headerView.backgroundColor = [UIColor whiteColor];

    YHNArticle *article = self.article;
    
    UILabel *postTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, 7, 163, 51)];
    UILabel *postScore = [[UILabel alloc] initWithFrame:CGRectMake(12, 16, 41, 28)];
    UILabel *postCommentCount = [[UILabel alloc] initWithFrame:CGRectMake(232, 16, 76, 21)];
    UILabel *postTime = [[UILabel alloc] initWithFrame:CGRectMake(281, 30, 27, 21)];
    
    postTitle.text = [article title];
    postTitle.numberOfLines = 3;
    postTitle.minimumScaleFactor = 0.75;
    postTitle.font = [UIFont systemFontOfSize: 13.0];
    
    postScore.text = [NSString stringWithFormat:@"%ld", (long)[article score]];
    postScore.font = [UIFont systemFontOfSize: 20];
    postScore.textAlignment = NSTextAlignmentCenter;
    postScore.textColor = [UIColor colorWithRed:0.0 green:0.50196081400000003 blue:1 alpha:1];
    
    long commentCount = [article commentCount];
    if (commentCount == 1) {
        postCommentCount.text = [NSString stringWithFormat:@"1 comment"];
    } else {
        postCommentCount.text = [NSString stringWithFormat:@"%ld comments", commentCount];
    }
    postCommentCount.font = [UIFont systemFontOfSize: 10.5];
    postCommentCount.textAlignment = NSTextAlignmentRight;
    
    postTime.text = [article timeInfo];
    postTime.font = [UIFont systemFontOfSize: 10.5];
    postTime.textAlignment = NSTextAlignmentRight;
    
    [headerView addSubview:postTitle];
    [headerView addSubview:postScore];
    [headerView addSubview:postCommentCount];
    [headerView addSubview:postTime];
    
    [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handleHeaderTap:)]];
    
    return headerView;
}

- (void)handleHeaderTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self performSegueWithIdentifier:@"ShowArticleContent" sender:self];
    }
}


-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"number of parent comments: %lu", (unsigned long)[[self.thread parentComments] count]);
    return self.thread.parentComments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize labelSize = [self labelSizeForRowAtIndexPath: indexPath];
    
    CGRect cellFrame = CGRectMake(0.0, 0.0, 320.0, labelSize.height + 20.0);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:cellFrame];
    
    CGRect commentFrame = CGRectMake(25.0, 10.0, labelSize.width, labelSize.height);
    UILabel *commentContent = [[UILabel alloc]initWithFrame: commentFrame];
    commentContent.numberOfLines = 0;
    
    YHNComment *comment = [self.thread.parentComments objectAtIndex:indexPath.row];
    commentContent.attributedText = comment.contents;
    [cell addSubview:commentContent];
    cell.userInteractionEnabled = NO;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize labelSize = [self labelSizeForRowAtIndexPath: indexPath];
    return labelSize.height + 20.0;
}

- (CGSize)labelSizeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = 280.0;
    
    UILabel *commentContent = [[UILabel alloc] initWithFrame:CGRectZero];
    commentContent.numberOfLines = 0;
    commentContent.lineBreakMode = NSLineBreakByCharWrapping;
    
    YHNComment *comment = [self.thread.parentComments objectAtIndex:indexPath.row];
    commentContent.attributedText = comment.contents;
    
    CGSize labelSize = [commentContent sizeThatFits:CGSizeMake(cellWidth, CGFLOAT_MAX)];
//    NSLog(@"size: %fl", labelSize.height);
    labelSize.height = labelSize.height + 15.0;
    
    return labelSize;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowArticleContent"]) {
        [[segue destinationViewController] setArticle:self.article];
    }
}

@end
