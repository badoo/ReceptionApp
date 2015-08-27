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

#import "BRAPeriodicEventsService.h"
#import "BRAEventHandlerProtocol.h"

@interface BRAPeriodicEventsService ()
@property (strong, nonatomic) NSMutableDictionary *handlers;
@property (strong, nonatomic) NSMutableDictionary *timers;
@end

@implementation BRAPeriodicEventsService

#pragma mark - Life Cycle

- (void)dealloc {
    for (NSString *timerKey in _timers) {
        NSTimer *timer = _timers[timerKey];
        [timer invalidate];
    }
}

+ (instancetype)sharedInstance {
    static BRAPeriodicEventsService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BRAPeriodicEventsService alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _handlers = [NSMutableDictionary new];
        _timers = [NSMutableDictionary new];
    }

    return self;
}

#pragma mark - Public API

- (void)registerEventHandler:(id <BRAEventHandlerProtocol>)updateHandler {
    NSParameterAssert([updateHandler conformsToProtocol:@protocol(BRAEventHandlerProtocol)]);
    if (![updateHandler conformsToProtocol:@protocol(BRAEventHandlerProtocol)]) {
        return;
    }

    NSString *handlerKey = [updateHandler key];
    if (self.handlers[handlerKey]) {
        [self removeUpdateHandlerForKey:handlerKey];
    }

    self.handlers[handlerKey] = updateHandler;
    [self scheduleOrRemoveHandler:updateHandler];
}

- (void)removeUpdateHandlerForKey:(NSString *)handlerKey {
    [self removeTimerForKey:handlerKey];
    [self.handlers removeObjectForKey:handlerKey];
}

#pragma mark - Helpers

- (void)scheduleOrRemoveHandler:(id <BRAEventHandlerProtocol>)updateHandler {
    NSString *handlerKey = [updateHandler key];
    if ([updateHandler shouldScheduleNextEvent]) {
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[updateHandler nextEventDate]
                                                  interval:1.0f
                                                    target:self
                                                  selector:@selector(timerTicked:)
                                                  userInfo:nil
                                                   repeats:NO];
        self.timers[handlerKey] = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    } else {
        [self removeUpdateHandlerForKey:handlerKey];
    }
}

- (void)removeTimerForKey:(NSString *)key {
    NSTimer *timer = self.timers[key];
    [timer invalidate];
    [self.timers removeObjectForKey:key];
}

- (NSString *)keyForTimer:(NSTimer *)timer {
    NSArray *keys = [self.timers allKeysForObject:timer];
    return [keys count] ? keys[0] : nil;
}

- (void)timerTicked:(NSTimer *)timer {
    NSString *handlerKey = [self keyForTimer:timer];
    [self removeTimerForKey:handlerKey];
    id <BRAEventHandlerProtocol> handler = self.handlers[handlerKey];
    [handler handleEventAtDate:timer.fireDate];
    [self scheduleOrRemoveHandler:handler];
}

@end