//
//  YHNScraper.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "TFHpple.h"

#import "YHNModels.h"
#import "YHNScraper.h"
#import "YHNStack.h"
#import "YHNArrayStack.h"

#define BASE_URL "https://news.ycombinator.com/"

@implementation YHNScraper

+ (YHNFrontpage *)loadFrontpage
{
    return [YHNScraper loadFrontpageWithData:
            [NSData dataWithContentsOfURL:[YHNScraper makeEndpoint:@"news"]]];
}

+ (YHNFrontpage *)loadFrontpageWithData:(NSData *)htmlData
{
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

+ (YHNCommentsThread *)loadThread:(YHNArticle *)article withData:(NSData *)htmlData
{
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];

    // Base XPath expression to reach the table containing article rows
    NSString *baseXPathQuery = @"//center/table/tr[3]/td/table[2]/tr/td/table/tr";
    NSArray *commentNodes = [parser searchWithXPathQuery:baseXPathQuery];

    NSMutableArray *comments = [NSMutableArray new];
    
    int i = 0;
    for (TFHppleElement *commentElement in commentNodes) {
        NSLog(@"%d", i);
        YHNComment *comment = [YHNComment new];
        
        // The first element is a <td> element containing a sole <img> element
        // We can determine the nesting of a comment from this
        comment.depth = [YHNScraper getNestingFromImgElement:
                         ((TFHppleElement *)commentElement.children[0]).children[0]];
        
        TFHppleElement *contentTd = commentElement.children[2];
        NSArray *contentNodes = contentTd.children;
        
        [YHNScraper fillComment:comment withHeader:contentNodes[0]];
        // child 1 is an empty <br> tag
        // child 2 is an empty text node
        [YHNScraper fillComment:comment withContent:contentNodes[3]];
        [YHNScraper fillComment:comment withReply:contentNodes[4]];
        i++;
        
        [comments addObject:comment];
    }
    
    NSArray *parentComments = [YHNScraper buildCommentTree:comments];

    return [[YHNCommentsThread alloc] initWithArticle:article comments:parentComments];
}

+ (NSInteger)getNestingFromImgElement:(TFHppleElement *)imgElement
{
    return [[imgElement objectForKey:@"width"] integerValue] / 40;
}

+ (void)fillComment:(YHNComment *)comment withHeader:(TFHppleElement *)divElement
{
    TFHppleElement *spanElement = divElement.children[0];
    NSArray *headerElements = spanElement.children;
    
    // <a> tag containing user info
    TFHppleElement *userAnchor = headerElements[0];
    NSString *user = [userAnchor text];
    NSURL *userUrl = [NSURL URLWithString:[userAnchor objectForKey:@"href"]];
    
    // we also have a text node
    // NSString *text = [spanElement text];
    
    // <a> tag containing permalink
    TFHppleElement *linkAnchor = headerElements[2];
    NSURL *permalink = [NSURL URLWithString:[linkAnchor objectForKey:@"href"]];
    
    comment.user = user;
    comment.userUrl = userUrl;
    comment.permalink = permalink;
}

+ (void)fillComment:(YHNComment *)comment withContent:(TFHppleElement *)spanElement
{
    TFHppleElement *fontElement = spanElement.children[0];
    
    // TODO: This does not properly work because the text node is not the only node in
    // the <font> element
    // Need to figure out how to flatten these nodes >_<
    NSString *text = [fontElement text];
    comment.contents = text;
}

+ (void)fillComment:(YHNComment *)comment withReply:(TFHppleElement *)pElement
{
    TFHppleElement *fontElement = pElement.children[0];
    TFHppleElement *uElement = fontElement.children[0];
    TFHppleElement *anchor = uElement.children[0];
    
    NSString *urlString = [anchor objectForKey:@"href"];
    comment.replyUrl = [NSURL URLWithString:urlString];
}

+ (NSArray *)buildCommentTree:(NSArray *)comments
{
    YHNStack *commentStack = [[YHNArrayStack alloc] init];
    NSMutableArray *parentComments = [[NSMutableArray alloc] init];

    for (YHNComment *comment in comments) {
        // In other words, if we have a very weird comment thread
        if (comment.depth > [commentStack count]) {
            [NSException raise:@"BadNestingException"
                        format:@"Depth %d is too far from current nesting %d",
                            comment.depth, [commentStack count]];
        }

        for (int i = [commentStack count]; i > comment.depth; i--) {
            [commentStack pop];
        }

        if (comment.depth == 0) {
            // If we're at depth 0, we have no Comment parent to add to
            // (instead, the parent will technically be a CommentThread
            [parentComments addObject:comment];
        } else {
            [[commentStack peek] addChild:comment];
        }
        [commentStack push:comment];
    }

    return parentComments;
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
