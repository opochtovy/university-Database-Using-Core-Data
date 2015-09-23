//
//  OPTeachersViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 19.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// The third screen "Teachers" will display a list of all teachers grouped by "courseSubject". Each teacher lists the number of courses. When you press on one of them you go to teacher profile screen to see and edit its information.

// We have to override 3 methods from our parent class :

// 1. getter for property (NSFetchedResultsController *)fetchedResultsController

// 2. -(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// 3. -(void)insertNewObject:(id)sender;

#import "OPTeachersViewController.h"
#import "OPCourseSubject.h"
#import "OPTeacher.h"
#import "OPCourse.h"
#import "OPTeacherProfileViewController.h"

@interface OPTeachersViewController ()

@property (strong, nonatomic) NSArray *nonzeroTeachersGroupedBySubjectArray;

@property (strong, nonatomic) NSArray *teachersWithoutCoursesArray;

@end

@implementation OPTeachersViewController

// We need @synthesize because we have got that property from our parent class
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Teachers";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    self.nonzeroTeachersGroupedBySubjectArray = [self fetchNonzeroTeachersGroupedBySubjectArray];
    
    self.teachersWithoutCoursesArray = [self fetchTeachersWithoutCoursesArray];
    
    [self.tableView reloadData];
}

#pragma mark - Private Methods

- (NSArray *)fetchNonzeroTeachersGroupedBySubjectArray {
    
    NSMutableArray *teachersGroupedBySubject = [NSMutableArray array];
    
    NSArray *allSubjects = self.fetchedResultsController.fetchedObjects;
    
    for (OPCourseSubject *subject in allSubjects) {
        
        NSFetchRequest *teachersForSubjectRequest = [self requestForEntity:@"OPTeacher"];
        
        NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        [teachersForSubjectRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SUBQUERY(courses, $course, $course.subject == %@).@count > %d", subject, 0];
        [teachersForSubjectRequest setPredicate:predicate1];
        
        NSError *requestError = nil;
        
        NSArray *teachersForSubjectArray = [self.managedObjectContext executeFetchRequest:teachersForSubjectRequest error:&requestError];
        
        [teachersGroupedBySubject addObject:teachersForSubjectArray];
    }
    
    return [teachersGroupedBySubject copy];
}

- (NSArray *)fetchTeachersWithoutCoursesArray {
    
    NSFetchRequest *fetchRequest = [self requestForEntity:@"OPTeacher"];
    
    NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courses.@count == %d", 0];
    [fetchRequest setPredicate:predicate];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    return resultArray;
    
}

#pragma mark - NSFetchedResultsController

// Here is overriden a getter for property fetchedResultsController from parent class
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [self requestForEntity:@"OPCourseSubject"];
    
     NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
     [fetchRequest setSortDescriptors:@[nameDescriptor]];
     
     NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"name" cacheName:nil];
    
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

// If a teacher has no courses he is displayed in additional section "Teachers Without Courses"
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
//    return [[self.fetchedResultsController sections] count];
    
    return [[self.fetchedResultsController sections] count] + 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
/*
    NSArray *nonzeroTeachersOfSubjectArray = [self.nonzeroTeachersGroupedBySubjectArray objectAtIndex:section];
    
    return [nonzeroTeachersOfSubjectArray count];
*/
    if (section == [self.fetchedResultsController.fetchedObjects count]) {
        
        return [self.teachersWithoutCoursesArray count];
        
    } else {
        
        NSArray *nonzeroTeachersOfSubjectArray = [self.nonzeroTeachersGroupedBySubjectArray objectAtIndex:section];
        
        return [nonzeroTeachersOfSubjectArray count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == [self.fetchedResultsController.fetchedObjects count]) {
        
        return @"TEACHERS WITHOUT COURSES";
        
    } else {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        return [sectionInfo name];
    }
    
}

// Here is overriden method from parent class configureCell:atIndexPath:
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    OPTeacher *teacher;
    
    if (indexPath.section == [self.fetchedResultsController.fetchedObjects count]) {
        
        teacher = [self.teachersWithoutCoursesArray objectAtIndex:indexPath.row];
        
    } else {
        
        NSArray *nonzeroTeachersOfSubjectArray = [self.nonzeroTeachersGroupedBySubjectArray objectAtIndex:indexPath.section];
        
        teacher = [nonzeroTeachersOfSubjectArray objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [teacher.courses count]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

// We need to finish handling code when you click on confirm button of the teacher's removal from a list sorted by courseSubject
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // First we delete a teacher from the database
        OPTeacher *teacher;
        
        if (indexPath.section == [self.fetchedResultsController.fetchedObjects count]) {
            
            teacher = [self.teachersWithoutCoursesArray objectAtIndex:indexPath.row];
            
        } else {
            
            NSArray *nonzeroTeachersOfSubjectArray = [self.nonzeroTeachersGroupedBySubjectArray objectAtIndex:indexPath.section];
            
            teacher = [nonzeroTeachersOfSubjectArray objectAtIndex:indexPath.row];
        }
        
        [self.managedObjectContext deleteObject:teacher];
        
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        // Second we need to refresh our arrays
        self.nonzeroTeachersGroupedBySubjectArray = [self fetchNonzeroTeachersGroupedBySubjectArray];
        self.teachersWithoutCoursesArray = [self fetchTeachersWithoutCoursesArray];
        
        // And the last - we need to show animated deletion of the row from the table
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView endUpdates];
        
    }
}

#pragma mark - UITableViewDelegate

// When you press on the cell with teacher you go to the screen with profile information of selected teacher to see and edit it.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPTeacher *teacher;
    
    if (indexPath.section == [self.fetchedResultsController.fetchedObjects count]) {
        
        teacher = [self.teachersWithoutCoursesArray objectAtIndex:indexPath.row];
        
    } else {
        
        NSArray *nonzeroTeachersOfSubjectArray = [self.nonzeroTeachersGroupedBySubjectArray objectAtIndex:indexPath.section];
        
        teacher = [nonzeroTeachersOfSubjectArray objectAtIndex:indexPath.row];
    }
    
    OPTeacherProfileViewController *vc = [[OPTeacherProfileViewController alloc] init];
    vc.teacher = teacher;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions

// Here is overriden method from parent class insertNewObject: to insert new teacher
- (void)insertNewObject:(id)sender {
    
    OPTeacherProfileViewController *vc = [[OPTeacherProfileViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
