//
//  OPCoursesViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 15.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPCoursesViewController shows screen of all courses in a dynamic table. When you press on one of them you go to course profile screen to see and edit its information.

// We have to override 3 methods from our parent class :

// 1. getter for property (NSFetchedResultsController *)fetchedResultsController

// 2. -(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// 3. -(void)insertNewObject:(id)sender;

#import "OPCoursesViewController.h"
#import "OPCourse.h"
#import "OPCourseProfileViewController.h"

@interface OPCoursesViewController ()

@end

@implementation OPCoursesViewController

// We need @synthesize because we have got that property from our parent class
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Courses";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetched results controller

// Here is overriden a getter for property fetchedResultsController from parent class
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [self requestForEntity:@"OPCourse"];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameDescriptor]];
    
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
    
    OPCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = course.name;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

#pragma mark - UITableViewDelegate

// When you press on the cell with course you go to the screen with profile information of selected course to see and edit it.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    OPCourseProfileViewController *vc = [[OPCourseProfileViewController alloc] init];
    vc.course = course;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions

// Here is overriden method from parent class insertNewObject: to insert new course
- (void)insertNewObject:(id)sender {
    
    OPCourseProfileViewController *vc = [[OPCourseProfileViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
