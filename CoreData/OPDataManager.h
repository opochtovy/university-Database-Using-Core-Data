//
//  OPDataManager.h
//  CoreData
//
//  Created by Oleg Pochtovy on 12.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// This class OPDataManager is singleton that contains all code for work with Core Data.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface OPDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (OPDataManager *)sharedManager;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

- (void)generateAndAddObjects;

@end
