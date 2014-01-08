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
#import "YHNThreadViewController.h"

#import "FontAwesome-iOS/NSString+FontAwesome.h"

@interface YHNMasterViewController ()
{
    NSArray *_articles;
    menuBarEnum _category;
    UISegmentedControl *_menuBar;
}
@end

@implementation YHNMasterViewController

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
    self.threadViewController = (YHNThreadViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self reloadDataWithCatgeory:(_category)];
    _category = HOT;

    // Set up pull-to-refresh
    [self.refreshControl addTarget:self
                            action:@selector(refreshInvoked:forState:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refreshInvoked:(UIRefreshControl *)control forState:(UIControlState)state
{
    control.attributedTitle = [[NSAttributedString alloc] initWithString:@"Fetching new articles"];
    [self reloadDataWithCatgeory:_category];
}

- (IBAction)menuButtonSelected:(id)sender
{
    switch (_menuBar.selectedSegmentIndex) {
        case 0:
            _category = HOT;
            break;
        case 1:
            _category = NEW;
            break;
        case 2:
            _category = ASK;
            break;
        default:
            break;
    }
    [self reloadDataWithCatgeory:(_category)];
    [[self tableView] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)reloadDataWithCatgeory:(menuBarEnum)category
{
    [YHNScraper loadFrontpageAsync:category
                           success:^(YHNFrontpage *frontpage) {
                               [self onFrontpageLoad:frontpage];
                           }
                           failure:^(NSError *error){
                               [self onFrontpageError:error];
                           }
     ];
}

- (void)onFrontpageLoad:(YHNFrontpage *)frontpage
{
    _articles = frontpage.articles;
    [self.tableView reloadData];

    NSString *now = [YHNUtils currentDateTimeAsString];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", now];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [self.refreshControl endRefreshing];
}

- (void)onFrontpageError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Network error"
                                message:[error localizedDescription]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Network error"];
    [self.refreshControl endRefreshing];
}

#pragma mark - Table View

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
    UIToolbar *blurBackground= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
    [blurBackground setBarTintColor:[UIColor whiteColor]];
    
//    UIView *transparentBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TableViewHeader.png"]];
//    transparentBackground.alpha = 0.8;
    [headerView addSubview:blurBackground];
    
    NSArray *buttons = [NSArray arrayWithObjects:@"HOT", @"NEW", @"ASK", nil];
    _menuBar = [[UISegmentedControl alloc] initWithItems:buttons];
    [_menuBar setFrame:CGRectMake(20, 12, 280, 33)];
    [_menuBar setSelectedSegmentIndex:_category];
    [_menuBar setEnabled:YES];
    
    UIFont *font = [UIFont systemFontOfSize:17.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [_menuBar setTitleTextAttributes:attributes
                            forState:UIControlStateNormal];
    _menuBar.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:_menuBar];
    
    // associate IBAction with segmented control in header
    [_menuBar addTarget:self action:@selector(menuButtonSelected:) forControlEvents:UIControlEventValueChanged];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:@"Post"
                                           forIndexPath:indexPath];
    
    YHNArticle *article = _articles[indexPath.row];
    
    UILabel *postTitle = (UILabel*)[cell viewWithTag:1];
    UILabel *postScore = (UILabel*)[cell viewWithTag:2];
    UILabel *postCommentCount = (UILabel*)[cell viewWithTag:3];
    UILabel *postCommentSymbol = (UILabel*)[cell viewWithTag:4];
    UILabel *postTime  = (UILabel*)[cell viewWithTag:5];
    UILabel *postTimeSymbol = (UILabel*)[cell viewWithTag:6];
    
    postTitle.text = [article title];
    postScore.text = [NSString stringWithFormat:@"%ld", (long)[article score]];
    
    long commentCount = [article commentCount];
    postCommentCount.text = [NSString stringWithFormat:@"%ld", commentCount];
    
    postCommentSymbol.font = [UIFont fontWithName:@"FontAwesome" size:11.5];
    postCommentSymbol.text = [NSString awesomeIcon:FaCommentO];
    postCommentSymbol.textAlignment = NSTextAlignmentRight;

    postTime.text = [article timeInfo];
    postTimeSymbol.font = [UIFont fontWithName:@"FontAwesome" size:11.5];
    postTimeSymbol.text = [NSString awesomeIcon:FaClockO];
    postTimeSymbol.textAlignment = NSTextAlignmentRight;
    
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
        self.threadViewController.article = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showPostDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        YHNArticle *article = _articles[indexPath.row];
        [[segue destinationViewController] setArticle:article];
    }
}

@end
