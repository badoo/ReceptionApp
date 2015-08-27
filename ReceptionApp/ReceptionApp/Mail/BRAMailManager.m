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

#import "BRAMailManager.h"
#import <MailCore/MailCore.h>
#import "BRASettingsManager.h"
#import "BRAVisitor.h"

@implementation BRAMailManager

#pragma mark - Class Methods

+ (NSString *)smtpServer  {
    return [[BRASettingsManager sharedInstance] SMTPServer];
}

+ (int)port {
    return [[[BRASettingsManager sharedInstance] portSMTP] intValue];
}

+ (NSString *)fromEmail {
    return [[BRASettingsManager sharedInstance] accountToSendEmail];
}

+ (NSString *)password {
    return [[BRASettingsManager sharedInstance] accountPassword];
}

+ (NSArray *)toEmails {
    NSString *emails = [[BRASettingsManager sharedInstance] email];
    return [emails componentsSeparatedByString:@","];
}

+ (NSString *)subjectWithVisitor:(BRAVisitor *)visitor {
    return [NSString stringWithFormat:NSLocalizedString(@"Visitor: %@", nil), [visitor nameAndSurname]];
}

+ (NSString *)agreementAttachmentName {
    return @"Agreement.pdf";
}

+ (NSString *)badgeAttachmentNameForVisitor:(BRAVisitor *)visitor {
    return [NSString stringWithFormat:@"Badge-%@.png",[visitor name]];
}

+ (BOOL)canSendEmail {
    if (![self password]) {
        return NO;
    }
    if (![self fromEmail]) {
        return NO;
    }
    if (![self toEmails].count > 0) {
        return NO;
    }
    return YES;
}

#pragma mark - Send email action

+ (void)sendEmailWithVisitor:(BRAVisitor *)visitor badgeImage:(UIImage *)badgeImage {
    if ([self canSendEmail]) {
        MCOAttachment *signatureAttachment = [MCOAttachment attachmentWithData:visitor.signedAgreementPDFData filename:[self agreementAttachmentName]];
        MCOAttachment *badgeAttachment = [MCOAttachment attachmentWithData:UIImagePNGRepresentation(badgeImage) filename:[self badgeAttachmentNameForVisitor:visitor]];
        NSString *body = [self createBodyWithVisitors:@[visitor] additionalMessage:NSLocalizedString(@"<br>Agreement and badge are in attachment<br>", nil)];

        [self sendEmailWithSubject:[self subjectWithVisitor:visitor]
                              body:body
                       attachments:@[signatureAttachment, badgeAttachment]];
    } else {
        NSLog(@"Can not send email - check settings");
    }
}

+ (void)sendSignInReportWithVisitors:(NSArray *)signinVisitors {
    if ([self canSendEmail]) {
        NSString *body = [self createBodyWithVisitors:signinVisitors additionalMessage:nil];
        [self sendEmailWithSubject:NSLocalizedString(@"Signed-in visitors report", nil)
                              body:body
                       attachments:nil];
    }
}

+ (void)sendSignedOutEmailWithVisitor:(BRAVisitor *)visitor {
    if ([self canSendEmail]) {
        NSString *body = [self createBodyWithVisitors:@[visitor] additionalMessage:nil];
        [self sendEmailWithSubject:[NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"Signed-out visitor", nil), visitor.nameAndSurname]
                              body:body
                       attachments:nil];
    }
}

+ (void)sendEmailWithSubject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)attachments {
    MCOSMTPSession *smtpSession = [self createSMTPSession];
    MCOMessageBuilder *builder = [MCOMessageBuilder new];
    MCOAddress *fromAddress = [MCOAddress addressWithDisplayName:subject
                                                         mailbox:[self fromEmail]];
    NSMutableArray *toEmails = [NSMutableArray new];
    for (NSString *email in [self toEmails]) {
        MCOAddress *toAddress = [MCOAddress addressWithDisplayName:nil
                                                           mailbox:email];
        [toEmails addObject:toAddress];
    }
    [[builder header] setFrom:fromAddress];
    [[builder header] setTo:toEmails];
    [[builder header] setSubject:subject];
    [builder setHTMLBody:body];
    if (attachments) {
        for (MCOAttachment *attachment in attachments) {
            [builder addAttachment:attachment];
        }
    }

    NSData *rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
           [self showAlertWithTitle:NSLocalizedString(@"Sending error", nil)
                            message:error.localizedDescription];
        } else {
            NSLog(@"Successfully sent email!");
        }
    }];
    
}

+ (MCOSMTPSession *)createSMTPSession {
    MCOSMTPSession *smtpSession = [MCOSMTPSession new];
    smtpSession.hostname = [[self class] smtpServer];
    smtpSession.port = [[self class] port];
    smtpSession.username = [[self class] fromEmail];
    smtpSession.password = [[self class] password];
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    return smtpSession;
}

+ (NSString *)createBodyWithVisitors:(NSArray *)visitors additionalMessage:(NSString *)additionalMessage {
    NSMutableString *messageBody = [NSMutableString stringWithString:@"<html>"];
    for (BRAVisitor *visitor in visitors) {
        [messageBody appendFormat:@"%@<br>", [self messageFromVisitor:visitor]];
    }
    if (additionalMessage) {
        [messageBody appendFormat:@"%@", additionalMessage];
    }
    [messageBody appendString:@"</html>"];
    return [messageBody copy];
}

+ (NSObject *)messageFromVisitor:(BRAVisitor *)visitor {
    NSString *visitorName = [visitor nameAndSurname];
    NSString *dateString = [self dateToStringFromDate:visitor.date];
    NSString *hereToSeeName = [[visitor employee] nameAndSurname];
    NSString *body = [NSString stringWithFormat:NSLocalizedString(@"Visitor: %@,<br>Date: %@,<br>Email: %@,<br>Company: %@,<br>Here to see: %@.<br>", nil),
                                                visitorName,
                                                dateString,
                                                visitor.email,
                                                visitor.company,
                                                hereToSeeName];
    return body;
}

+ (NSString *)dateToStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm, EEEE dd MMMM yyyy"];
    return  [dateFormat stringFromDate:date];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"I understand", nil)
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

@end