//
//  YHNScraper.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "TFHpple.h"

#import "YHNArticle.h"
#import "YHNScraper.h"

#define BASE_URL "https://news.ycombinator.com/"

@implementation YHNScraper

+ (YHNFrontpage *)loadFrontpage
{
    return [YHNScraper loadFrontpageWithUrl:[YHNScraper makeEndpoint:@"news"]];
}

+ (YHNFrontpage *)loadFrontpageWithUrl:(NSURL *)frontpageUrl
{
    // TODO: error handling
    NSData *htmlData = [NSData dataWithContentsOfURL:frontpageUrl];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    // Base XPath expression to reach the table containing article rows
    NSString *baseXPathQuery = @"//center/table/tr[3]/td/table/tr";
    NSArray *articleNodes = [parser searchWithXPathQuery:baseXPathQuery];
    
    NSMutableArray *articles = [NSMutableArray new];
    
    // HN articles come in groups of three <tr> elements.
    // The first <tr> element contains the rank, up/downvote, title, origin site, and URL
    // The second <tr> element contains the score, comment count, and comments URL
    // The third <tr> element is for spacing
    for (int i = 0; i < ([articleNodes count] / 3) * 3; i += 3) {
        TFHppleElement *titleTr = articleNodes[i];
        TFHppleElement *subtextTr = articleNodes[i + 1];
        // articleNodes[i + 2] is a spacer
        
        YHNArticle *article = [YHNArticle new];
        [YHNScraper fillArticle:article withTitleElement:titleTr];
        [YHNScraper fillArticle:article withSubtextElement:subtextTr];
        
        [articles addObject:article];
    }
    
    // Parse the last element for the More URL
    TFHppleElement *moreTr = [articleNodes lastObject];
    TFHppleElement *moreTd = [moreTr childrenWithClassName:@"title"][0];
    TFHppleElement *moreAnchor = [moreTd childrenWithTagName:@"a"][0];
    // Apparently returns "newsX" (where X is a number). This behavior seems to be unique on
    // mobile Safari.
    NSURL *moreUrl = [YHNScraper makeEndpoint:moreAnchor.attributes[@"href"]];
    
    YHNFrontpage *frontpage = [[YHNFrontpage alloc] initWithArticles:articles moreUrl:moreUrl];
    return frontpage;
}

+ (void)fillArticle:(YHNArticle *)article withTitleElement:(TFHppleElement *)titleTr
{
    // Relevant <td> elements in the first <tr> have class .title
    NSArray *titleChildren = [titleTr childrenWithClassName:@"title"];
    
    // First <td> is the rank
    NSInteger rank = [[titleChildren[0] text] integerValue];
    
    // Second <td> contains an <a> with title and URL and a <span> with origin site
    TFHppleElement *titleTd = titleChildren[1];
    TFHppleElement *titleAnchor = [titleTd childrenWithTagName:@"a"][0];
    NSURL *url = [NSURL URLWithString:titleAnchor.attributes[@"href"]];
    NSString *title = [titleAnchor text];
    
    // Parsing the origin site <span>
    NSString *originSite = nil;
    // Not all posts have an origin site (e.g. Ask HN)
    if ([titleTd.children count] > 1) {
        originSite = [[titleChildren[1] childrenWithTagName:@"span"][0] text];
        originSite = [originSite stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];
    }

    article.title = title;
    article.url = url;
    article.originSite = originSite;
    article.rank = rank;
}

+ (void)fillArticle:(YHNArticle *)article withSubtextElement:(TFHppleElement *)subtextTr
{
    // The very first <td> is just a spacer. The second <td> (what we want) has class .subtext
    TFHppleElement *subtextTd = [subtextTr childrenWithClassName:@"subtext"][0];
    
    // This results in 5 children (for normal posts at least)
    NSArray *children = subtextTd.children;
    if ([children count] < 5) {
        // We might have fewer than 5 children because it's a job post
        return;
    }
    
    // child 0 is the score <span>
    NSInteger score = [YHNScraper getQuantityFromString:[children[0] text]];
    
    // child 1 is not a node
    // child 2 has user information
    TFHppleElement *userElement = children[2];
    NSString *user = [userElement text];
    NSURL *userUrl = [YHNScraper makeEndpoint:userElement.attributes[@"href"]];
    
    // child 3 has time information (TODO we'll get this later)
    // child 4 has comments information
    TFHppleElement *commentsElement = children[4];
    NSInteger commentCount = [YHNScraper getQuantityFromString:[commentsElement text]];
    NSURL *commentsUrl = [YHNScraper makeEndpoint:commentsElement.attributes[@"href"]];
    
    article.score = score;
    article.user = user;
    article.userUrl = userUrl;
    article.commentCount = commentCount;
    article.commentsUrl = commentsUrl;
}

+ (NSURL *)makeEndpoint:(NSString *)endpoint
{
    return [NSURL URLWithString:[@BASE_URL stringByAppendingString:endpoint]];
}

// Given a string like "50 objects" or "34 bananas", extract the number and return it
+ (NSInteger)getQuantityFromString:(NSString *)string
{
    NSInteger substringEnd = [string rangeOfString:@" "].location;
    if (substringEnd == NSNotFound) {
        // WARN: potential source of errors, but it's a good way to handle "5 comments" vs "discuss"
        return 0;
    }
    
    return [[string substringToIndex:substringEnd] integerValue];
}

@end
