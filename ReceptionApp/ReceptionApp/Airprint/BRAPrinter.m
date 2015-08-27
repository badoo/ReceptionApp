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

#import "BRAPrinter.h"
#import "BRAPrintPageRenderer.h"
#import "BRAPrintPaper.h"

@interface BRAPrinter () <UIPrintInteractionControllerDelegate>
@property (strong, nonatomic) UIPrintInteractionController *printInteractionController;
@end

@implementation BRAPrinter

#pragma mark - staticIdentifiers

+ (instancetype)printer {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return (BRAPrinter *) [BRAPrinter printerWithURL:[ud URLForKey:[self printerUserDefaultsIdentifier]]];
}

+ (void)savePrinterURL:(NSURL *)url {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setURL:url forKey:[self printerUserDefaultsIdentifier]];
    [ud synchronize];
}

+ (NSString *)printerUserDefaultsIdentifier {
    return @"printerBonjourIdentifier";
}

- (void)dealloc {
    _printInteractionController.delegate = nil;
}

- (void)printBadgeImage:(UIImage *)badgeImage {
    if ([BRAPrinter printer].URL) {
        UIPrintInteractionController *interactionController = [UIPrintInteractionController sharedPrintController];
        interactionController.delegate = self;

        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputPhoto;
        printInfo.jobName = NSLocalizedString(@"Contact reception for your badge", nil);
        interactionController.printInfo = printInfo;

        UIPrintFormatter *formatter = [[UIPrintFormatter alloc] init];
        formatter.contentInsets = UIEdgeInsetsZero;
        formatter.perPageContentInsets = UIEdgeInsetsZero;
        interactionController.printFormatter = formatter;

        BRAPrintPageRenderer *renderer = [BRAPrintPageRenderer new];
        renderer.image = badgeImage;
        interactionController.printPageRenderer = renderer;

        [interactionController printToPrinter:[BRAPrinter printer] completionHandler:nil];
    }
}

#pragma mark - UIPrintInteractionControllerDelegate

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList {
    return [BRAPrintPaper new];
}

- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController {
    self.printInteractionController.delegate = nil;
    self.printInteractionController = nil;
}

@end