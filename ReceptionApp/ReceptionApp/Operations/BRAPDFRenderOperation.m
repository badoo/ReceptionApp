/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "BRAPDFRenderOperation.h"
#import "BRAVisitor.h"

#define kPaperSizeA4 CGSizeMake(595.2,841.8)

@interface BRAPDFRenderOperation () <UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) BRAVisitor *visitor;
@end

@implementation BRAPDFRenderOperation {
    BOOL _isExecuting;
    BOOL _isFinished;
}

#pragma mark - Life Cycle

+ (instancetype)operationWithVisitor:(BRAVisitor *)visitor {
    BRAPDFRenderOperation *webViewRenderer = [BRAPDFRenderOperation new];
    webViewRenderer.visitor = visitor;
    webViewRenderer.webView = [[UIWebView alloc] init];
    webViewRenderer.webView.delegate = webViewRenderer;
    return webViewRenderer;
}

#pragma mark - NSOperation

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isReady {
    return YES;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    [self renderPDF];
}

- (void)finish {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - PDF Creation

- (void)renderPDF {
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"Agreement"
                                                         ofType:@"html"];
    NSString *agreementHTML = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding
                                                           error:&error];
    agreementHTML = [self prepareStylingForPrintingInHTMLString:agreementHTML];
    agreementHTML = [self replaceVisitorDataInHTMLString:agreementHTML];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:agreementHTML baseURL:baseURL];
}

- (NSData *)createPDFWithPrintRenderer:(UIPrintPageRenderer *)printPageRenderer  {
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, printPageRenderer.paperRect, nil);
    [printPageRenderer prepareForDrawingPages: NSMakeRange(0, (NSUInteger) printPageRenderer.numberOfPages)];
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    for (NSInteger i = 0 ; i < printPageRenderer.numberOfPages; i++) {
        UIGraphicsBeginPDFPage();
        [printPageRenderer drawPageAtIndex:i inRect:bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}

#pragma mark - Helpers

- (NSString *)prepareStylingForPrintingInHTMLString:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"font-size: 14pt;" withString:@"font-size: 9pt;"];
    return html;
}

- (NSString *)replaceVisitorDataInHTMLString:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<span id=\"name\">.................................</span>" withString:self.visitor.nameAndSurname];
    html = [html stringByReplacingOccurrencesOfString:@"<span id=\"company\">.................................</span>" withString:self.visitor.company];
    html = [html stringByReplacingOccurrencesOfString:@"<span id=\"date\">.................................</span>" withString:[self stringFromDate:self.visitor.date]];
    NSString *imageString = [self imageStringFromImage:self.visitor.signature];
    html = [html stringByReplacingOccurrencesOfString:@"<span id=\"signature\">.................................</span>" withString:imageString];
    return html;
}

- (NSString *)imageStringFromImage:(UIImage *)image {
    NSMutableString *string = [@"<img src=\"data:image/png;base64," mutableCopy];
    NSData *data = UIImagePNGRepresentation(image);
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    [string appendString:base64String];
    [string appendString:@"\" style=\"max-width:300px;\">"];
    return string;
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMMM yyyy, HH:mm"];
    return  [[dateFormat stringFromDate:date] uppercaseString];
}

#pragma mark - WebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.isLoading) {
        return;
    }
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
    CGFloat sidePadding = 5.0f;
    CGRect printableRect = CGRectMake(
            sidePadding,
            sidePadding,
            kPaperSizeA4.width-sidePadding-sidePadding,
            kPaperSizeA4.height-sidePadding-sidePadding
    );
    CGRect paperRect = CGRectMake(0, 0, kPaperSizeA4.width, kPaperSizeA4.height);
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    NSData *pdfData = [self createPDFWithPrintRenderer:render];
    self.visitor.signedAgreementPDFData = pdfData;
    [self finish];
}

@end