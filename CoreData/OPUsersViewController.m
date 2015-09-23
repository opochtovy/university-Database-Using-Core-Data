//
//  OPUsersViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 13.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPUsersViewController shows screen of all users (students and teachers) in a dynamic table. When you press on one of them you go to user's profile screen to see and edit its information.

// We have to override 3 methods from our parent class :

// 1. getter for property (NSFetchedResultsController *)fetchedResultsController

// 2. -(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// 3. -(void)insertNewObject:(id)sender;

#import "OPUsersViewController.h"
#import "OPUser.h"
#import "OPStudent.h"
#import "OPTeacher.h"
#import "OPUserProfileViewController.h"

@interface OPUsersViewController ()

@end

@implementation OPUsersViewController

// We need @synthesize because we have got that property from our parent class
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"USERS";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSFetchedResultsController

// fetchResultsController is created first time when calling method numberOfSectionsInTableView: in a parent class OPCoreDataViewController

// Here is overriden a getter for property fetchedResultsController from parent class
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [self requestForEntity:@"OPUser"];
    
    NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    
    if (![self.fetchedResultsController performFetch:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
    
}

#pragma mark - UITableViewDataSource

// Here is overriden method from parent class configureCell:atIndexPath:
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    OPUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [user.firstName stringByAppendingFormat:@" %@", user.lastName];
    
    if ([user isKindOfClass:[OPStudent class]]) {
        
        cell.detailTextLabel.text = @"student";
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
    } else if ([user isKindOfClass:[OPTeacher class]]) {
        
        cell.detailTextLabel.text = @"teacher";
        cell.detailTextLabel.textColor = [UIColor redColor];
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

#pragma mark - UITableViewDelegate

// When you press on the cell with user you go to the screen with profile information of that user (exactly student or teacher)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    OPUserProfileViewController *vc = [[OPUserProfileViewController alloc] init];
    vc.user = user;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions

// Here is overriden method from parent class insertNewObject: to insert new user
- (void)insertNewObject:(id)sender {
    
    OPUserProfileViewController *vc = [[OPUserProfileViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
