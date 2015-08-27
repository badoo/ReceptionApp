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

#import "BRARepository.h"
#import <objc/runtime.h>
#import "YapDatabase.h"

@interface BRARepository ()
@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *connection;
@end

@implementation BRARepository

#pragma mark - Constants

+ (NSString *)collectionForDatabaseSettingsKey {
    return @"settingsDatabase";
}

#pragma mark - Class Methods

+ (NSString *)databasePathWithDatabaseName:(NSString *)databaseName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? paths[0] : NSTemporaryDirectory();
    
    NSString *dbName = [NSString stringWithFormat:@"/%@.sqlite", databaseName];
    
    return [baseDir stringByAppendingString:dbName];
}

#pragma mark - init
+ (instancetype)sharedInstance {
    static BRARepository *visitorRepository = nil;
    static dispatch_once_t token = 0;
    
    dispatch_once(&token,^{
        visitorRepository = [[self alloc] initWithDatabaseName:@"ReceptionApp"];
    });
    
    return visitorRepository;
}

- (instancetype)initWithDatabaseName:(NSString *)databaseName {
    if (self = [super init]) {
        NSString *path = [[self class] databasePathWithDatabaseName:databaseName];
        self.database = [[YapDatabase alloc] initWithPath:path];
        self.connection = [self.database newConnection];
        [self clearOldVersionsIfNeeded];
    }
    return self;
}

#pragma mark - Database API public

- (void)saveObject:(id<BRARepositoryProtocol>)objectToSave {
    NSAssert([objectToSave conformsToProtocol:@protocol(BRARepositoryProtocol)], @"Needs <BRARepositoryProtocol> object");
    if (![objectToSave conformsToProtocol:@protocol(BRARepositoryProtocol)]) {
        return;
    }
    [self saveObject:objectToSave withKey:[objectToSave key] toCollection:NSStringFromClass([objectToSave class])];
}

- (void)deleteObject:(id<BRARepositoryProtocol>)objectToDelete {
    NSAssert([objectToDelete conformsToProtocol:@protocol(BRARepositoryProtocol)], @"Needs <BRARepositoryProtocol> object");
    if (![objectToDelete conformsToProtocol:@protocol(BRARepositoryProtocol)]) {
        return;
    }
    [self deleteObjectForKey:[objectToDelete key] inCollection:NSStringFromClass([objectToDelete class])];
}

- (void)saveObject:(id)objectToSave withKey:(NSString *)key toCollection:(NSString *)collectionName {
    [self.connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        [transaction setObject:objectToSave
                        forKey:key
                  inCollection:collectionName];
    }];
}

- (id)objectForKey:(NSString *)key inCollection:(NSString *)collectionName {
    __block id object = nil;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
        object = [transaction objectForKey:key inCollection:collectionName];
    }];
    return object;
}

- (void)deleteObjectForKey:(NSString *)key inCollection:(NSString *)collectionName {
    [self.connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        [transaction removeObjectForKey:key
                           inCollection:collectionName];
    }];
}

- (NSArray *)allObjectsOfClass:(Class<BRARepositoryProtocol>)aClass {
    NSMutableArray *objects = [NSMutableArray new];
    if (aClass != Nil) {
        [self.connection readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
            [transaction enumerateRowsInCollection:NSStringFromClass(aClass)
                                        usingBlock:^(NSString * __nonnull key,
                                                     id __nonnull object,
                                                     id __nullable metadata,
                                                     BOOL * __nonnull stop) {
                                            [objects addObject:object];
                                        }];
        }];
    }
    return objects;
}

- (void)removeAllObjectsOfClass:(Class <BRARepositoryProtocol>)aClass {
    NSString *collectionName = NSStringFromClass(aClass);
    [self.connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        [transaction removeAllObjectsInCollection:collectionName];
    }];
}

#pragma mark - Database API private

- (void)clearOldVersionsIfNeeded {
    NSArray *classes = [self classesConformingToProtocol:@protocol(BRARepositoryProtocol)];
    for (Class<BRARepositoryProtocol> aClass in classes) {
        [self clearOldVersionsOfClass:aClass];
    }
}

- (void)clearOldVersionsOfClass:(Class<BRARepositoryProtocol>)aClass {
    [self.connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        id<BRARepositoryProtocol> conformingClass = (id<BRARepositoryProtocol>) aClass;
        NSString *databaseVersion = [transaction objectForKey:NSStringFromClass(aClass)
                                                 inCollection:[[self class] collectionForDatabaseSettingsKey]];
        if (databaseVersion == nil) {
            [transaction setObject:[conformingClass version]
                            forKey:NSStringFromClass(aClass)
                      inCollection:[[self class] collectionForDatabaseSettingsKey]];
        } else if (![databaseVersion isEqualToString:[conformingClass version]]) {
            [transaction removeAllObjectsInCollection:NSStringFromClass([conformingClass class])];
            [transaction setObject:[conformingClass version]
                            forKey:NSStringFromClass(aClass)
                      inCollection:[[self class] collectionForDatabaseSettingsKey]];
        }
    }];
}

- (NSArray *)classesConformingToProtocol:(Protocol *)protocol {
    NSMutableArray *conformingClasses = [NSMutableArray new];
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0 ) {
        classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int index = 0; index < numClasses; index++) {
            Class nextClass = classes[index];
            if (class_conformsToProtocol(nextClass, protocol)) {
                [conformingClasses addObject:nextClass];
            }
        }
        free(classes);
    }
    return conformingClasses;
}

- (void)removeExpiredObjectsOfClass:(Class<BRARepositoryProtocol>)class {
    if (class != Nil) {
        NSMutableArray *objectsToDelete = [NSMutableArray new];
        [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
            [transaction enumerateRowsInCollection:NSStringFromClass(class)
                                        usingBlock:^(NSString * __nonnull key,
                                                     id __nonnull object,
                                                     id __nullable metadata,
                                                     BOOL * __nonnull stop) {
                                            id<BRARepositoryProtocol> conformingObject = (id<BRARepositoryProtocol>)object;
                                            if ([conformingObject isExpired]) {
                                                [objectsToDelete addObject:conformingObject];
                                            }
                                        }];
        }];
        [self deleteObjects:objectsToDelete];
    }
}

- (void)deleteObjects:(NSArray *)objectsToDelete {
    for (id object in objectsToDelete) {
        [self deleteObject:object];
    }
}

#pragma mark - NSTimer check date

- (void)clearExpiredObjects {
    NSArray *classes = [self classesConformingToProtocol:@protocol(BRARepositoryProtocol)];
    for (Class class in classes) {
        [self removeExpiredObjectsOfClass:class];
    }
}


@end