//
//  YHNComment.m
//  YAHNC
//
//  Created by Daniel Ge on 11/17/13.
//  Copyright (c) 2013 YAHNC. All rights reserved.
//

#import "YHNComment.h"

@implementation YHNComment

// Convenience method for adding a child comment
- (void)addChild:(YHNComment *)comment
{
    [self.children addObject:comment];
    comment.parent = self;
}

- (NSMutableArray *)children
{
    if (_children == nil) {
        _children = [[NSMutableArray alloc] init];
    }
    return _children;
}

// Convenience method for setting the content with an NSString representing HTML content
// Note that this won't work in iOS <7
- (NSError *)setContentsWithHtml:(NSString *)html
{
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *attributedOptions = \
    @{
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]
      };
    NSError *error;

    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithData:htmlData
                                          options:attributedOptions
                                          documentAttributes:nil
                                          error:&error];

    self.contents = attributedText;

    return error;
}

@end
