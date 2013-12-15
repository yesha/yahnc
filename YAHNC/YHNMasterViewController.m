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

@interface YHNMasterViewController ()
{
    NSArray *_articles;
    menuBarEnum _category;
    UISegmentedControl *_menuBar;
}
@end

@implementation YHNMasterViewController

- (IBAction)refreshButton:(id)sender
{
    [self reloadDataWithCatgeory:(_category)];
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
}

- (void)reloadDataWithCatgeory:(menuBarEnum)category
{
    [YHNScraper loadFrontpageAsync: ^(YHNFrontpage *frontpage) {
        _articles = frontpage.articles;
        [self.tableView reloadData];
    }
    withPageType:(category)
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
    self.threadViewController = (YHNThreadViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self reloadDataWithCatgeory:(_category)];
    _category = HOT;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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
        // TODO timestamp
        // TOTO link
        
        postTitle.text = [article title];
        postScore.text = [NSString stringWithFormat:@"%ld", (long)[article score]];
        
        long commentCount = [article commentCount];
        if (commentCount == 1) {
            postCommentCount.text = [NSString stringWithFormat:@"1 comment"];
        } else {
            postCommentCount.text = [NSString stringWithFormat:@"%ld comments", commentCount];
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
