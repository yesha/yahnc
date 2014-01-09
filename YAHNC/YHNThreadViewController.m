//
//  YHNThreadViewController.m
//  YAHNC
//
//  Created by Daniel Ge on 12/12/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNThreadViewController.h"
#import "YHNWebViewController.h"
#import "YHNScraper.h"
#import "YHNModels.h"

#import "YHNFlatComment.h"

#import "FontAwesome-iOS/NSString+FontAwesome.h"

@interface YHNThreadViewController () {
    NSUInteger parentCommentIndex;
    NSURL *targetUrl;
    NSString *targetTitle;
}

@property (nonatomic, strong) YHNCommentsThread *thread;
@property (nonatomic, strong) NSArray *flatComments;

@end

@implementation YHNThreadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];

    // Set up pull-to-refresh
    [self.refreshControl addTarget:self
                            action:@selector(refreshInvoked:forState:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refreshInvoked:(UIRefreshControl *)control forState:(UIControlState)state
{
    control.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating thread"];
    [self reloadData];
}

- (void)reloadData
{
    [YHNScraper loadThreadAsync:self.article
                        success:^(YHNCommentsThread *thread) {
                            [self onThreadLoad:thread];
                        } failure:^(NSError *error) {
                            [self onThreadFailure:error];
                        }
     ];
}

- (void)onThreadLoad:(YHNCommentsThread *)thread
{
    self.thread = thread;
    self.flatComments = [YHNFlatComment flattenCommentThread:thread];
    [self.tableView reloadData];

    NSString *now = [YHNUtils currentDateTimeAsString];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", now];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [self.refreshControl endRefreshing];
}

- (void)onThreadFailure:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Network error"
                                message:[error localizedDescription]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Network error"];
    [self.refreshControl endRefreshing];

    NSLog(@"%@", error);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openInWebView:(NSURL *)URL title:(NSString *)title
{
    targetUrl = URL;
    targetTitle = title;
    [self performSegueWithIdentifier:@"ShowArticleContent" sender:self];
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL
         inRange:(NSRange)characterRange
{
    // TODO: special handling for news.ycombinator.com links
    [self openInWebView:URL title:nil];
    return NO;
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    headerView.backgroundColor = [UIColor whiteColor];

    YHNArticle *article = self.article;
    
    UILabel *postTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, 13, 200, 39)];
    UILabel *postScore = [[UILabel alloc] initWithFrame:CGRectMake(12, 19, 41, 28)];
    UILabel *postCommentCount = [[UILabel alloc] initWithFrame:CGRectMake(258, 13, 34, 21)];
    UILabel *postCommentSymbol = [[UILabel alloc] initWithFrame:CGRectMake(293, 12, 15, 21)];
    UILabel *postTime = [[UILabel alloc] initWithFrame:CGRectMake(265, 30,
                                                                  27, 21)];
    UILabel *postTimeSymbol = [[UILabel alloc] initWithFrame:CGRectMake(293, 30, 15, 21)];
    
    postTitle.text = [article title];
    postTitle.numberOfLines = 3;
    postTitle.minimumScaleFactor = 0.75;
    postTitle.adjustsFontSizeToFitWidth = YES;
    postTitle.font = [UIFont systemFontOfSize: 13.0];
    
    postScore.text = [NSString stringWithFormat:@"%ld", (long)[article score]];
    postScore.font = [UIFont systemFontOfSize: 20];
    postScore.textAlignment = NSTextAlignmentCenter;
    postScore.textColor = [UIColor colorWithRed:0.0 green:0.50196081400000003 blue:1 alpha:1];
    
    long commentCount = [article commentCount];
    postCommentCount.text = [NSString stringWithFormat:@"%ld", commentCount];
    
    postCommentCount.font = [UIFont systemFontOfSize: 10.5];
    postCommentCount.textAlignment = NSTextAlignmentRight;
    
    postCommentSymbol.font = [UIFont fontWithName:@"FontAwesome" size:11.5];
    postCommentSymbol.text = [NSString awesomeIcon:FaCommentO];
    postCommentSymbol.textAlignment = NSTextAlignmentRight;
    
    postTime.text = [article timeInfo];
    postTime.font = [UIFont systemFontOfSize: 10.5];
    postTime.textAlignment = NSTextAlignmentRight;
    
    postTimeSymbol.font = [UIFont fontWithName:@"FontAwesome" size:11.5];
    postTimeSymbol.text = [NSString awesomeIcon:FaClockO];
    postTimeSymbol.textAlignment = NSTextAlignmentRight;
    
    [headerView addSubview:postTitle];
    [headerView addSubview:postScore];
    [headerView addSubview:postCommentCount];
    [headerView addSubview:postCommentSymbol];
    [headerView addSubview:postTime];
    [headerView addSubview:postTimeSymbol];
    [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeaderTap:)]];
    
    UILabel *separator = [[UILabel alloc] initWithFrame:CGRectMake(5, 58, 310, 1)];
    separator.backgroundColor = [UIColor colorWithRed:0.0 green:0.50196081400000003 blue:1 alpha:1];
    [headerView addSubview:separator];

    return headerView;
}

- (void)handleHeaderTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self openInWebView:self.article.url title:self.article.title];
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
    return [self.flatComments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize labelSize = [self labelSizeForRowAtIndexPath: indexPath];
    YHNFlatComment *flatComment = [self.flatComments objectAtIndex:indexPath.row];
    YHNComment *comment = flatComment.comment;

    // Whoo one line for comment nesting!
    CGFloat xCoord = 16.0 * flatComment.nesting;
    
    CGRect cellFrame = CGRectMake(0.0, 0.0, 320.0, labelSize.height + 20.0);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:cellFrame];
    
    CGRect commentFrame = CGRectMake(25.0+xCoord, 20.0, labelSize.width, cellFrame.size.height);
    UITextView *commentContent = [[UITextView alloc]initWithFrame: commentFrame];
    commentContent.editable = NO;
    commentContent.scrollEnabled = NO;
    commentContent.selectable = YES;
    commentContent.delegate = self;
    commentContent.attributedText = comment.contents;
    
    CGRect authorFrame = CGRectMake(25.0+xCoord, -9.0, labelSize.width, 50);
    UILabel *commentAuthor = [[UILabel alloc] initWithFrame:authorFrame];
    commentAuthor.font = [UIFont boldSystemFontOfSize:10];
    commentAuthor.text = comment.user;
    if (!commentAuthor.text) commentAuthor.text = @"causer";
    commentAuthor.textAlignment = NSTextAlignmentLeft;
    
    [cell addSubview:commentContent];
    [cell addSubview:commentAuthor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize labelSize = [self labelSizeForRowAtIndexPath: indexPath];
    return labelSize.height + 30.0;
}

- (CGSize)labelSizeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = 280.0;
    
    UILabel *dummyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    dummyLabel.numberOfLines = 0;
    dummyLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    YHNFlatComment *flatComment = [self.flatComments objectAtIndex:indexPath.row];
    YHNComment *comment = flatComment.comment;
    dummyLabel.attributedText = comment.contents;
    CGFloat xCoord = 16.0 * flatComment.nesting;
    
    CGSize labelSize = [dummyLabel sizeThatFits:CGSizeMake(cellWidth-xCoord, CGFLOAT_MAX)];
    labelSize.height = labelSize.height + 15.0;
    
    return labelSize;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowArticleContent"]) {
        if (targetUrl == nil) {
            NSLog(@"WARN: nil URL");
        }
        YHNWebViewController *webViewController = [segue destinationViewController];
        webViewController.articleTitle = targetTitle;
        webViewController.url = targetUrl;

        targetTitle = nil;
        targetUrl = nil;
    }
}

@end
