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

#import "BRASelectNamesView.h"

@interface BRASelectNamesView ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@end

@implementation BRASelectNamesView

#pragma mark - Class methods

+ (NSUInteger)randomNumberWithFinalNumber:(NSUInteger)finalNumber {
    return arc4random() % finalNumber;
}

+ (NSArray *)surnames {
    static NSArray *surnames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        surnames = @[@"Smith", @"Jones", @"Taylor", @"Williams", @"Brown", @"Davies", @"Evans", @"Wilson", @"Thomas", @"Roberts", @"Johnson", @"Lewis", @"Walker", @"Robinson", @"Wood", @"Thompson", @"White"];
    });
    return surnames;
}

+ (NSString *)randomSurname {
    NSArray *surnames = [self surnames];
    NSUInteger random = [self randomNumberWithFinalNumber:surnames.count - 1];
    return surnames[random];
}

#pragma mark - Life Cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupButtons];
}

#pragma mark - private API

- (void)setupNames {
    NSUInteger correctButtonNameIndex = [[self class] randomNumberWithFinalNumber:self.buttons.count];
    [self.buttons[correctButtonNameIndex] setTitle:self.nameAndSurname forState:UIControlStateNormal];
    
    for (UIButton *button in self.buttons) {
        if (button.titleLabel.text == nil) {
            [button setTitle:[NSString stringWithFormat:@"%@ %@", [self visitorName], [[self class] randomSurname]] forState:UIControlStateNormal];
        }
    }
}

- (void)setupButtons {
    for (UIButton *buttons in self.buttons) {
        buttons.layer.cornerRadius = 2;
        buttons.layer.masksToBounds = YES;
    }
}

- (NSString *)visitorName {
    NSString *name = [[self.nameAndSurname componentsSeparatedByString:@" "] firstObject];
    return name;
}

#pragma mark - Setters

- (void)setNameAndSurname:(NSString *)nameAndSurname {
    if (nameAndSurname != nil) {
        _nameAndSurname = nameAndSurname;
        [self setupNames];
    }
}

#pragma mark - Actions

- (IBAction)firstNameSelected:(UIButton *)sender {
    [self.delegate nameDidSelected:sender.titleLabel.text];
}

- (IBAction)secondNameSelected:(UIButton *)sender {
    [self.delegate nameDidSelected:sender.titleLabel.text];
}

- (IBAction)thirdNameSelected:(UIButton *)sender {
    [self.delegate nameDidSelected:sender.titleLabel.text];
}

@end
