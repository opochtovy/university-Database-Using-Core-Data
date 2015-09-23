//
//  OPTeacherProfileViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 18.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// That class has OPCoreDataViewController as its parent class - to observe the mechanism of creating teacher profile VC using NSFetchedResultsController but not usual fetch requests

// On teacher profile screen you can add, edit and remove teachers. In the first section are the fields "firstName", "lastName" and "email". The second section is a list of teached courses. You can delete a course from courses list, but it is not removed from the database - it is removed just from the teacher's list. There is also a button to add courses (in the first cell of the second section). If you click on the course's cell, then you move on to course profile VC. If you click on the button "Add course", you go to a modal popover controller that contains a list of all courses, and courses added to that list have ticks. Here you can remove the courses from the teacher or add to this teacher new courses.

// We have to override 3 methods from our parent class :

// 1. getter for property (NSFetchedResultsController *)fetchedResultsController

// 2. -(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// 3. -(void)insertNewObject:(id)sender;

#import "OPTeacherProfileViewController.h"
#import "OPTeacher.h"
#import "OPCourse.h"
#import "OPTeachersViewController.h"
#import "OPCoursesPickerViewController.h"
#import "OPCourseProfileViewController.h"

// That class performs protocol UITextFieldDelegate
// That class performs protocol UIPopoverControllerDelegate
// That class performs custom protocol OPCoursesPickerDelegate
@interface OPTeacherProfileViewController () <UITextFieldDelegate, UIPopoverControllerDelegate, OPCoursesPickerDelegate>

@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextField *emailField;

@property (strong, nonatomic) NSArray *textFields;

@property (strong, nonatomic) NSArray *teacherKeys;

@property (strong, nonatomic) NSArray *teacherValues;

@property (strong, nonatomic) NSArray *coursesOfCurrentTeacherArray;

@property (nonatomic, weak) UIButton *deleteButton;
@property (nonatomic, weak) UIButton *addButton;
@property (weak, nonatomic) UITableViewCell *addCoursesButtonCell;

@property (strong, nonatomic) NSArray *allCoursesArray;

@property (strong, nonatomic) UIPopoverController *popover;

@property (assign, nonatomic) BOOL isCoursesArrayChangedInCoursesPickerDelegate;

@end

@implementation OPTeacherProfileViewController

// We need @synthesize because we have got that property from our parent class
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // self.teacherValues is an array to store intermediate changed values of self.teacher attributes before saving to the database
    
    if (self.teacher) {
        
        self.teacherValues = [NSArray arrayWithObjects:[self.teacher.firstName copy], [self.teacher.lastName copy], [self.teacher.email copy], nil];
    } else {
        self.teacherValues = [NSArray arrayWithObjects:@"", @"", @"", nil];
    }
    
    // Create a list of all courses (for display by pressing the button "Add courses")
    
    self.allCoursesArray = [self fetchAllCoursesArray];
    
    self.navigationItem.title = @"Teacher Profile";
    
    self.firstNameField = [[UITextField alloc] init];
    self.lastNameField = [[UITextField alloc] init];
    self.emailField = [[UITextField alloc] init];
    
    self.textFields = [NSArray arrayWithObjects:self.firstNameField, self.lastNameField, self.emailField, nil];
    
    for (UITextField *textField in self.textFields) {
        textField.delegate = self;
        textField.frame = CGRectMake(103, 7, 210, 30);
        textField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    
    self.teacherKeys = [NSArray arrayWithObjects:@"firstName", @"lastName", @"email", nil];
    
    // Make 2 buttons for NavigationBar
    
    // Button to return without saving the changes
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Button to save all made changes
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSave:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Cell responses by pressing on it only in non-editing mode
    self.tableView.allowsSelectionDuringEditing = NO;
    
    // Make 2 buttons for first cell of the second section to delete courses and add courses to the courses list of the current teacher
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.deleteButton setTitle:@"Delete course" forState:UIControlStateNormal];
    
    [self.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
    
    [self.deleteButton addTarget:self action:@selector(actionDeleteCoursesOfTeacher:) forControlEvents:UIControlEventTouchUpInside];
    
    // that line is important -> and then go to method actionDeleteCourseFromTeacher:
    self.tableView.editing = NO;
    
    self.deleteButton.frame = CGRectMake(7, 7, 140, 30);
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.addButton setTitle:@"Add course" forState:UIControlStateNormal];
    
    [self.addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.addButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
    
    [self.addButton addTarget:self action:@selector(actionAddCoursesOfTeacher:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addButton.frame = CGRectMake(173, 7, 140, 30);
    
    self.addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (!self.isCoursesArrayChangedInCoursesPickerDelegate) {
        
        self.coursesOfCurrentTeacherArray = [self fetchCoursesOfCurrentTeacherArray];
        
    } else {
        
        self.isCoursesArrayChangedInCoursesPickerDelegate = NO;
    }
    
    [self.tableView reloadData];
}
 
#pragma mark - Private Methods

- (NSArray *)fetchCoursesOfCurrentTeacherArray {
    
    OPTeacher *currentTeacher = [self.fetchedResultsController.fetchedObjects firstObject];
    
    NSArray *resultArray = [NSArray array];
    
    if (currentTeacher) {
        
        NSFetchRequest *fetchRequest = [self requestForEntity:@"OPCourse"];
        
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [fetchRequest setSortDescriptors:@[nameDescriptor]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacher == %@", currentTeacher];
        [fetchRequest setPredicate:predicate];
        
        NSError *requestError = nil;
        
        resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
        if (requestError) {
            NSLog(@"%@", [requestError localizedDescription]);
        }
    }
    
    return resultArray;
}

- (NSArray *)fetchAllCoursesArray {
    
    NSFetchRequest *fetchRequest = [self requestForEntity:@"OPCourse"];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameDescriptor]];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
}

- (void)showController:(UIViewController *)vc inPopoverFromSender:(id)sender {
    
    if (!sender) {
        return;
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    
    popover.delegate = self;
    
    self.popover = popover;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        
        popover.popoverContentSize = CGSizeMake(320, 320);
        
        CGRect rect = [(UIButton *)sender frame]; //
        
        CGRect rectInSelfView;
        
        rectInSelfView = [self.view convertRect:rect fromView:self.addCoursesButtonCell];
        
        [popover presentPopoverFromRect:rectInSelfView
                                 inView:self.tableView
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
    }
    
}

- (void)showControllerAsModal:(UIViewController *)vc {
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

#pragma mark - NSFetchedResultsController

// Here is overriden a getter for property fetchedResultsController from parent class
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [self requestForEntity:@"OPTeacher"];
    
    NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", self.teacher];
    [fetchRequest setPredicate:predicate];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        
        return @"Teacher information";
        
    } else {
        
        return @"Teached courses";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return [self.teacherKeys count];
    
    } else {
        
        // First cell is a special cell (with buttons "Delete courses" and "Add courses")
        return [self.coursesOfCurrentTeacherArray count] + 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        
        static NSString *identifier = @"TeacherProfileCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            
        }
        
        UITextField *textField = [self.textFields objectAtIndex:indexPath.row];
        
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        if ([textField isEqual:self.emailField]) {
            
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.returnKeyType = UIReturnKeyDone;
            
        } else {
            
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.returnKeyType = UIReturnKeyNext;
            
        }
        
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        textField.spellCheckingType = UITextSpellCheckingTypeNo;
        
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        if ([textField isEqual:self.lastNameField]) {
            textField.keyboardAppearance = UIKeyboardAppearanceDark;
        }
        
        [cell addSubview:textField];
        
        if (self.teacher) {
            
            textField.text = [self.teacherValues objectAtIndex:indexPath.row];
            
        }
        
        NSArray *labelNames = @[@"First name", @"Last name", @"E-mail"];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.text = [labelNames objectAtIndex:indexPath.row];
        
    } else {
        
        // First cell is a special cell (with buttons "Delete courses" and "Add courses")
        if (indexPath.row == 0) {
            
            static NSString *addStudentIdentifier = @"AddStudentCell";
            
            cell = [tableView dequeueReusableCellWithIdentifier:addStudentIdentifier];
            
            if (!cell) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addStudentIdentifier];
            }
            
            [cell addSubview:self.deleteButton];
            
            [cell addSubview:self.addButton];
            
            self.addCoursesButtonCell = cell;
            
        } else {
            
            static NSString *identifier = @"CoursesOfTeacherCell";
            
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                
            }
            
        }
        
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

// Here is overriden method from parent class configureCell:atIndexPath:
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ( (indexPath.section == 1) && (indexPath.row != 0) ) {
        
        // (- 1) is due to the fact that we have added the first cell with two buttons that increased array of rows in the second section by 1
        OPCourse *course = [self.coursesOfCurrentTeacherArray objectAtIndex:(indexPath.row-1)];
        
        cell.textLabel.text = course.name;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
}

// We need to finish handling code when you click on confirm button of the course removal from a list
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // First we delete a course from the courses list (self.coursesOfCurrentTeacherArray)
        NSMutableArray *courses = [self.coursesOfCurrentTeacherArray mutableCopy];
        [courses removeObjectAtIndex:(indexPath.row - 1)];
        self.coursesOfCurrentTeacherArray = [courses copy];
        
        // And the last - we need to show animated deletion of the row from the table
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView endUpdates];
        
    }
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section) {
        
        return YES;
        
    } else {
        
        return NO;
        
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return UITableViewCellEditingStyleNone;
        
    } else {
        
        // Now finish possibility to remove the course from the courses list for the current teacher
        return indexPath.row == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
    }
    
}

// Change the title of cofirmation button when deleting course (from "Delete" to "Remove course")
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove course";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Clicking on the cell with course you go to the screen for editing the chosen course information - course profile controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPCourse *course = [self.coursesOfCurrentTeacherArray objectAtIndex:indexPath.row - 1]; // (- 1) is due to the fact that we have added the first cell with two buttons that increased array of rows in the second section by 1
    
    OPCourseProfileViewController *vc = [[OPCourseProfileViewController alloc] init];
    vc.course = course;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.firstNameField]) {
        [self.lastNameField becomeFirstResponder];
    } else if ([textField isEqual:self.lastNameField]) {
        [self.emailField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

// Here we save intermediate changed values of self.teacher attributes before saving to the database
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    NSMutableArray *array = [self.teacherValues mutableCopy];
    
    [array replaceObjectAtIndex:[self.textFields indexOfObject:textField] withObject:textField.text];
    
    self.teacherValues = [array copy];
    
    return YES;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.popover = nil;
}

#pragma mark - OPCoursesPickerDelegate

// Implementation of the protocol OPCoursesPickerDelegate
- (void)reloadCoursesFromPicker:(OPCoursesPickerViewController *)vc {
    
    self.coursesOfCurrentTeacherArray = vc.coursesOfCurrentTeacher;
    
    self.isCoursesArrayChangedInCoursesPickerDelegate = vc.isCoursesArrayChanged;
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)actionSave:(UIBarButtonItem *)sender {
    
    OPTeacher *teacher;
    
    if (self.teacher) {
        
        teacher = self.teacher;
        
    } else {
        
        teacher = [NSEntityDescription insertNewObjectForEntityForName:@"OPTeacher" inManagedObjectContext:self.managedObjectContext];
        
    }
    
    teacher.firstName = self.firstNameField.text;
    teacher.lastName = self.lastNameField.text;
    teacher.email = self.emailField.text;
    
    teacher.courses = [NSSet setWithArray:self.coursesOfCurrentTeacherArray];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)actionDeleteCoursesOfTeacher:(UIButton *)sender {
    
    BOOL isEditing = self.tableView.editing;
    
    [self.tableView setEditing:!isEditing animated:YES];
    
    if (self.tableView.editing) {
        
        [self.deleteButton setTitle:@"Done" forState:UIControlStateNormal];
        
    } else {
        
        [self.deleteButton setTitle:@"Delete course" forState:UIControlStateNormal];
    }
    
}

// If you click on the button "Add courses", you go to a modal popover controller that contains a list of all courses, and courses added to that list have ticks. Here you can remove the courses from the teacher or add to this teacher new courses.
- (void)actionAddCoursesOfTeacher:(UIButton *)sender {
    
    OPCoursesPickerViewController *coursesPickerVC = [[OPCoursesPickerViewController alloc] init];
    coursesPickerVC.title = @"Add courses";
    
    coursesPickerVC.allCourses = self.allCoursesArray;
    coursesPickerVC.coursesOfCurrentTeacher = self.coursesOfCurrentTeacherArray;
    
    coursesPickerVC.delegate = self;
    
    // Be sure to check the device
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self showController:coursesPickerVC inPopoverFromSender:sender];
        
    } else {
        
        [self showControllerAsModal:coursesPickerVC];
        
    }

}

@end
