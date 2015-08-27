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

#import "BRASettingsManager.h"
#import "BRARepository+Settings.h"
#import "BRAEmployeesDownloader.h"

@implementation BRASettingsManager

#pragma mark - Constants

+ (NSString *)defaultEmployeeFileURLString {
    return @"https://www.dropbox.com/s/ty2lplrvpkebevz/SampleEmployeeFile.json?dl=1";
}

+ (NSString *)defaultPinCode {
    return @"0000";
}

+ (NSString *)defaultPort {
    return @"465";
}

+ (NSString *)defaultSMTPServer {
    return @"smtp.gmail.com";
}

#pragma mark - Properties

- (void)setEmail:(NSString *)email {
    if (![_email isEqualToString:email]) {
        _email = [email copy];
        [[BRARepository sharedInstance] saveEmail:_email];
    }
}

- (void)setPinCode:(NSString *)pinCode {
    if (![_pinCode isEqualToString:pinCode]) {
        _pinCode = [pinCode copy];
        [[BRARepository sharedInstance] savePinCode:_pinCode];
    }
}

- (void)setDevEmail:(NSString *)devEmail {
    if (![_devEmail isEqualToString:devEmail]) {
        _devEmail = [devEmail copy];
        [[BRARepository sharedInstance] saveDevEmail:_devEmail];
    }
}

- (void)setPrinterName:(NSString *)printerName {
    if (![_printerName isEqualToString:printerName]) {
        _printerName = [printerName copy];
        [[BRARepository sharedInstance] savePrinterName:printerName];
    }
}

- (void)setAccountToSendEmail:(NSString *)account {
    if (![_accountToSendEmail isEqualToString:account]) {
        _accountToSendEmail = [account copy];
        [[BRARepository sharedInstance] saveAccountToSendEmail:account];
    }
}

- (void)setPortSMTP:(NSString *)port {
    if (![_portSMTP isEqualToString:port]) {
        _portSMTP = [port copy];
        [[BRARepository sharedInstance] savePortSMTP:port];
    }
}

- (void)setAccountPassword:(NSString *)password {
    if (![_accountPassword isEqualToString:password]) {
        _accountPassword = [password copy];
        [[BRARepository sharedInstance] savePasswordAccount:password];
    }
}

- (void)setSMTPServer:(NSString *)SMTPServer {
    if (![_SMTPServer isEqualToString:SMTPServer]) {
        _SMTPServer = [SMTPServer copy];
        [[BRARepository sharedInstance] saveSMTPServer:SMTPServer];
    }
}

- (void)setEmployeeFileURLString:(NSString *)employeeFileURLString {
    if (![_employeeFileURLString isEqualToString:employeeFileURLString]) {
        _employeeFileURLString = [employeeFileURLString copy];
        [[BRARepository sharedInstance] saveEmployeeURLString:_employeeFileURLString];
        [self fetchNewEmployees];
    }
}

- (void)fetchNewEmployees {
    [BRAEmployeesDownloader updateEmployees];
}

#pragma mark - LifeCycle

+ (instancetype)sharedInstance {
    static BRASettingsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BRASettingsManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _pinCode = [[BRARepository sharedInstance] pinCode];
        _email = [[BRARepository sharedInstance] email];
        _devEmail = [[BRARepository sharedInstance] devEmail];
        _currentAppVersion = [self appNameAndVersionNumberDisplayString];
        _printerName = [[BRARepository sharedInstance] printerName];
        _accountToSendEmail = [[BRARepository sharedInstance] accountToSendEmail];
        _accountPassword = [[BRARepository sharedInstance] accountPassword];
        _portSMTP = [[BRARepository sharedInstance] portSMTP];
        _SMTPServer = [[BRARepository sharedInstance] SMTPServer];
        _employeeFileURLString = [[self class] defaultEmployeeFileURLString];

        [self setUpWithDefaultValues];
    }

    return self;
}

#pragma mark - Helpers

- (void)setUpWithDefaultValues {
    if (_pinCode == nil) {
        _pinCode = [[self class] defaultPinCode];
    }
    
    if (_portSMTP == nil) {
        _portSMTP = [[self class] defaultPort];
    }
    
    if (_SMTPServer == nil) {
        _SMTPServer = [[self class] defaultSMTPServer];
    }
}

- (NSString *)appNameAndVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:NSLocalizedString(@"%@, Version %@", nil), appDisplayName, version];
}

@end
