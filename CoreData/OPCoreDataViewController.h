//
//  OPCoreDataViewController.h
//  CoreData
//
//  Created by Oleg Pochtovy on 12.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPCoreDataViewController is a parent class for all screens (tabs) in our app.

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface OPCoreDataViewController : UITableViewController <NSFetchedResultsControllerDelegate>

// @property managedObjectContext is used to get managedObjectContext from [OPDataManager sharedManager]
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

// that method will be overriden in all child classes
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// that method will be overriden in all child classes
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// that method will be overriden in all child classes
- (void)insertNewObject:(id)sender;

- (NSFetchRequest *)requestForEntity:(NSString *)entity;

@end
