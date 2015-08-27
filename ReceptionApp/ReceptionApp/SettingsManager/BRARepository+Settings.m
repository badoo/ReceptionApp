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

#import "BRARepository+Settings.h"

@implementation BRARepository (Settings)

#pragma mark - Constants

+ (NSString *)settingCollectionName {
    return @"BRASettingsCollection";
}

+ (NSString *)pinCodeKey {
    return @"PinCode";
}

+ (NSString *)emailKey {
    return @"Email";
}

+ (NSString *)devEmailKey {
    return @"DevEmail";
}

+ (NSString *)employeeURLStringKey {
    return @"EmployeeURLString";
}

+ (NSString *)printerNameKey {
    return @"Printer";
}

+ (NSString *)accountKey {
    return @"Account";
}

+ (NSString *)passwordKey {
    return @"Password";
}

+ (NSString *)portKey {
    return @"Port";
}

+ (NSString *)SMTPServerKey {
    return @"SMTPServer";
}

#pragma mark - Public API

- (NSString *)pinCode {
    return [self objectForKey:[[self class] pinCodeKey] inCollection:[[self class] settingCollectionName]];
}

- (NSString *)email {
    return [self objectForKey:[[self class] emailKey] inCollection:[[self class] settingCollectionName]];
}

- (NSString *)devEmail {
    return [self objectForKey:[[self class] devEmailKey] inCollection:[[self class] settingCollectionName]];
}

- (NSString *)employeeURLString {
    return [self objectForKey:[[self class] employeeURLStringKey] inCollection:[[self class] settingCollectionName]];
}

- (NSString *)printerName {
    return [self objectForKey:[[self class] printerNameKey] inCollection:[[self class] settingCollectionName]];
}

- (NSString *)accountToSendEmail {
    return [self objectForKey:[[self class] accountKey] inCollection:[[self class] settingCollectionName]];
}

- (NSString *)accountPassword {
    return [self objectForKey:[[self class] passwordKey] inCollection:[[self class] settingCollectionName]];
}

- (NSString *)portSMTP {
    return [self objectForKey:[[self class] portKey] inCollection:[[self class] settingCollectionName]];
}

- (NSString *)SMTPServer {
    return [self objectForKey:[[self class] SMTPServerKey] inCollection:[[self class] settingCollectionName]];
}

- (void)savePinCode:(NSString *)newPinCode {
    [self saveObject:newPinCode withKey:[[self class] pinCodeKey] toCollection:[[self class] settingCollectionName]];
}

- (void)saveEmail:(NSString *)newEmail {
    [self saveObject:newEmail withKey:[[self class] emailKey] toCollection:[[self class] settingCollectionName]];
}

- (void)saveDevEmail:(NSString *)newEmail {
    [self saveObject:newEmail withKey:[[self class] devEmailKey] toCollection:[[self class] settingCollectionName]];
}

- (void)saveEmployeeURLString:(NSString *)newURLString {
    [self saveObject:newURLString withKey:[[self class] employeeURLStringKey] toCollection:[[self class] settingCollectionName]];
}

- (void)savePrinterName:(NSString *)newName {
    [self saveObject:newName withKey:[[self class] printerNameKey] toCollection:[[self class] settingCollectionName]];
}

- (void)saveAccountToSendEmail:(NSString *)newAccount {
    [self saveObject:newAccount withKey:[[self class] accountKey] toCollection:[[self class] settingCollectionName]];
}

- (void)savePasswordAccount:(NSString *)newPassword {
    [self saveObject:newPassword withKey:[[self class] passwordKey] toCollection:[[self class] settingCollectionName]];
}

- (void)savePortSMTP:(NSString *)newPort {
    [self saveObject:newPort withKey:[[self class] portKey] toCollection:[[self class] settingCollectionName]];
}

- (void)saveSMTPServer:(NSString *)newSMTPServer {
    [self saveObject:newSMTPServer withKey:[[self class] SMTPServerKey] toCollection:[[self class] settingCollectionName]];
}

@end