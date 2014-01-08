//
//  YHNWebViewController.m
//  YAHNC
//
//  Created by Christian Barcenas on 12/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNWebViewController.h"

@interface YHNWebViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)forwardButtonPressed:(id)sender;
- (IBAction)refreshButtonPressed:(id)sender;

@end

@implementation YHNWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadWebPage];
}

- (void)loadWebPage
{
    self.title = self.articleTitle;
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:self.url]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.webView stopLoading];
}

- (void)updateButtons
{
    [self.backButton setEnabled:[self.webView canGoBack]];
    [self.forwardButton setEnabled:[self.webView canGoForward]];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // This error may occur if an another request is made before the previous request of WebView
    // is completed
    if (error.code == NSURLErrorCancelled) {
        NSLog(@"NSURLErrorCancelled discarded");
        return;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSString *errorString = [error localizedDescription];
    NSString *errorTitle = [NSString stringWithFormat:@"Error (%d)", error.code];
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:errorTitle
                                                        message:errorString
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [errorView show];
    [self updateButtons];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

#pragma mark - UIAlertViewDelegate methods

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button action handlers

- (IBAction)backButtonPressed:(id)sender {
    [self.webView goBack];
}

- (IBAction)forwardButtonPressed:(id)sender {
    [self.webView goForward];
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self.webView reload];
}

@end
