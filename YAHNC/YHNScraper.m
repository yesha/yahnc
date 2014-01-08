//
//  YHNScraper.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "AFNetworking.h"
#import "TFHpple.h"
#import "DDURLParser.h"

#import "YHNModels.h"
#import "YHNScraper.h"
#import "YHNStack.h"
#import "YHNArrayStack.h"

@implementation YHNScraper

NSString             *const BASE_URL = @"https://news.ycombinator.com/";
NSURL                *baseUrl;
AFHTTPSessionManager *sessionManager;

+ (void)initialize
{
    if (self == [YHNScraper class])
    {
        baseUrl        = [NSURL URLWithString:BASE_URL];
        sessionManager = [[AFHTTPSessionManager manager] initWithBaseURL:baseUrl];
        
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
}

#pragma mark - Methods for loading the frontpage

+ (void)loadFrontpageAsync:(NSUInteger)pageType
                   success:(void (^) (YHNFrontpage *frontpage))success
                   failure:(void (^) (NSError *error))failure
{
    NSString *getParameter = @"";
    switch (pageType) {
        case 0:
            getParameter = @"news";
            break;
        case 1:
            getParameter = @"newest";
            break;
        case 2:
            getParameter = @"ask";
            break;
        default:
            break;
    }
    
    [sessionManager GET:getParameter
             parameters:nil
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    success([YHNScraper loadFrontpageWithData:(NSData *)responseObject]);
                }
                failure:^(NSURLSessionDataTask *task, id responseObject) {
                    failure(task.error);
                }
     ];
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
    for (int i = 0; i < [articleNodes count] / 3; i++) {
        TFHppleElement *titleTr = articleNodes[3*i];
        TFHppleElement *subtextTr = articleNodes[3*i + 1];
        // articleNodes[3*i + 2] is a spacer
        
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
    NSURL *moreUrl = [baseUrl URLByAppendingPathComponent:moreAnchor.attributes[@"href"]];
    
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
    NSString *userUrl = userElement.attributes[@"href"];
    
    // child 3 has time information
    TFHppleElement *timeElement = children[3];
    NSString *time = [timeElement content];
    
    // child 4 has comments information
    TFHppleElement *commentsElement = children[4];
    NSInteger commentCount = [YHNScraper getQuantityFromString:[commentsElement text]];
    NSString *commentsUrl = commentsElement.attributes[@"href"];
    
    article.score = score;
    article.user = user;
    article.userId = [[DDURLParser parserWithURLString:userUrl] valueForVariable:@"id"];
    article.timeInfo =  [YHNScraper getTimeInfoFromString:time];
    article.commentCount = commentCount;
    article.commentsId = [[DDURLParser parserWithURLString:commentsUrl] valueForVariable:@"id"];
}

#pragma mark - Methods for loading comment threads

+ (void)loadThreadAsync:(YHNArticle *)article
                success:(void (^)(YHNCommentsThread *))success
                failure:(void (^)(NSError *))failure
{
    [sessionManager GET:@"item"
             parameters:@{@"id": article.commentsId}
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    success([YHNScraper loadThread:article withData:responseObject]);
                }
                failure:^(NSURLSessionDataTask *task, id responseObject) {
                    failure(task.error);
                }
     ];
}

+ (YHNCommentsThread *)loadThread:(YHNArticle *)article withData:(NSData *)htmlData
{
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];

    // Base XPath expression to reach the table containing article rows
    NSString *baseXPathQuery = @"//center/table/tr[3]/td/table[2]/tr/td/table/tr";
    NSArray *commentNodes = [parser searchWithXPathQuery:baseXPathQuery];

    NSMutableArray *comments = [NSMutableArray new];

    for (TFHppleElement *commentElement in commentNodes) {
        YHNComment *comment = [YHNComment new];
        
        // The first element is a <td> element containing a sole <img> element
        // We can determine the nesting of a comment from this
        comment.depth = [YHNScraper getNestingFromImgElement:
                         [[commentElement firstChild] firstChild]];

        TFHppleElement *contentTd = [[commentElement childrenWithClassName:@"default"]
                                     firstObject];

        TFHppleElement *commentContent = [[contentTd childrenWithClassName:@"comment"]
                                          firstObject];

        if ([YHNScraper commentIsDeleted:commentContent]) {
            comment.deleted = YES;
        } else {
            // Header (contains username, permalink, time)
            NSString *headerXPathQuery = @"//div/span[@class=\"comhead\"]";
            TFHppleElement *headerNode = [[contentTd searchWithXPathQuery:headerXPathQuery]
                                          firstObject];
            [YHNScraper fillComment:comment withHeader:headerNode];

            // Main comment content
            [YHNScraper fillComment:comment withContent:commentContent];

            // Reply link (<p><font><u><a href=...>reply</a></u></font></p>)
            NSString *replyXPathQuery = @"//p[last()]/font[@size=1]/u/a";
            NSArray *replyNode = [contentTd searchWithXPathQuery:replyXPathQuery];
            if ([replyNode count] > 0) {
                [YHNScraper fillComment:comment withReply:[replyNode firstObject]];
            } else {
                NSLog(@"DEBUG: comment %@ has no reply link (probably new)", comment.permalink);
            }
        }
        
        if (![comment.contents string]) {
            continue;
        }
        [comments addObject:comment];
    }
    
    NSArray *parentComments = [YHNScraper buildCommentTree:comments];
    return [[YHNCommentsThread alloc] initWithArticle:article comments:parentComments];
}

+ (NSInteger)getNestingFromImgElement:(TFHppleElement *)imgElement
{
    return [[imgElement objectForKey:@"width"] integerValue] / 40;
}

+ (BOOL)commentIsDeleted:(TFHppleElement *)commentNode
{
    return [[commentNode text] isEqualToString:@"[deleted]"];
}

+ (void)fillComment:(YHNComment *)comment withHeader:(TFHppleElement *)spanElement
{
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
    // I wonder how well this hack will work
    NSError *error = [comment setContentsWithHtml:[spanElement raw]];
    if (error != nil) {
        NSLog(@"%@", error);
    }
}

+ (void)fillComment:(YHNComment *)comment withReply:(TFHppleElement *)anchor
{
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
                        format:@"Depth %ld is too far from current nesting %lu",
                            (long)comment.depth, (unsigned long)[commentStack count]];
        }

        for (int i = (int)[commentStack count]; i > comment.depth; i--) {
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

+ (NSString *)getTimeInfoFromString:(NSString *)string
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    NSInteger  qty = 0;
    NSString *unit = @"";
    [scanner scanInteger:&qty];
    [scanner scanString:@"second" intoString:&unit];
    [scanner scanString:@"minute" intoString:&unit];
    [scanner scanString:@"hour" intoString:&unit];
    [scanner scanString:@"day" intoString:&unit];
    
    if ([unit isEqualToString:@"second"])
        return [NSString stringWithFormat:@"%d s", qty];
    else if ([unit isEqualToString:@"minute"])
        return [NSString stringWithFormat:@"%d m", qty];
    else if ([unit isEqualToString:@"hour"])
        return [NSString stringWithFormat:@"%d h", qty];
    else if ([unit isEqualToString:@"day"])
        return [NSString stringWithFormat:@"%d d", qty];
    else
        return @"";
}

@end
