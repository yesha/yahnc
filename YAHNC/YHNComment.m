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
      NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding],
      };
    NSError *error;

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]
                                                 initWithData:htmlData
                                                 options:attributedOptions
                                                 documentAttributes:nil
                                                 error:&error];

    [self changeToSystemFonts:attributedText];

    self.contents = attributedText;

    return error;
}

- (void)changeToSystemFonts:(NSMutableAttributedString *)string
{
    // Scan through the NSAttributedString and change all occurrences of Times New Roman
    // to the default system font that looks so much nicer
    NSRange range = NSMakeRange(0, [string length]);
    CGFloat fontSize = [UIFont systemFontSize];

    UIFont *systemFont = [UIFont systemFontOfSize:fontSize];
    UIFont *italicSystemFont = [UIFont italicSystemFontOfSize:fontSize];

    // Block for font attribute enumeration
    // adapted from http://stackoverflow.com/questions/19921972/
    id eachFont = ^(id value, NSRange range, BOOL *stop) {
        UIFont *currentFont = value;
        UIFont *replacementFont = nil;

        if ([currentFont.familyName isEqualToString:@"Times New Roman"]) {
            if ([currentFont.fontName rangeOfString:@"italic"
                                            options:NSCaseInsensitiveSearch].location != NSNotFound) {
                replacementFont = italicSystemFont;
            } else {
                replacementFont = systemFont;
            }
            [string addAttribute:NSFontAttributeName value:replacementFont range:range];
        }
    };

    [string enumerateAttribute:NSFontAttributeName
                       inRange:range
                       options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                    usingBlock:eachFont];
}

- (YHNComment *)childCommentAtIndexPath:(NSIndexPath *)indexPath
{
    YHNComment *comment = self;

    for (NSUInteger i = 0; i < [indexPath length]; i++) {
        NSUInteger index = [indexPath indexAtPosition:i];
        NSArray *children = comment.children;
        if (index >= [children count]) {
            return nil;
        }
        comment = children[index];
    }

    return comment;
}

@end
