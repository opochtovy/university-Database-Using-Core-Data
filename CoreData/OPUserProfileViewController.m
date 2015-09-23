//
//  OPUserProfileViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 14.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// On user profile screen you can add, edit and remove users (student or teacher). In the first section are the fields "firstName", "lastName", "email" and segmentedControl to choose the type of user (student or teacher). The second section is a list of courses (studied courses or teached courses). You can delete a course from courses list, but it is not removed from the database - it is removed just from the user's list. There is also a button to add courses (in the first cell of the second section). If you click on the course's cell, then you move on to course profile VC. If you click on the button "Add courses", you go to a modal popover controller that contains a list of all courses, and courses added to that list have a tick. Here you can remove the courses from the user or add to this user new courses.

// Custom type of data for segmentedControl
typedef enum {
    OPUserTypeStudent, // by default 0 сториборде)
    OPUserTypeTeacher
} OPUserType;

#import "OPUserProfileViewController.h"
#import "OPUser.h"
#import "OPStudent.h"
#import "OPTeacher.h"
#import "OPCourse.h"
#import "OPDataManager.h"
#import "OPCourseProfileViewController.h"
#import "OPCoursesPickerViewController.h"

// That class performs protocol UITextFieldDelegate
// That class performs protocol UIPopoverControllerDelegate
// That class performs custom protocol OPCoursesPickerDelegate
@interface OPUserProfileViewController () <UITextFieldDelegate, UIPopoverControllerDelegate, OPCoursesPickerDelegate>

@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextField *emailField;

@property (strong, nonatomic) NSArray *textFields;

@property (strong, nonatomic) NSArray *userKeys;

@property (strong, nonatomic) NSArray *userValues;

@property (strong, nonatomic) UISegmentedControl *userControl;

@property (assign, nonatomic) NSUInteger initialUserType;

@property (strong, nonatomic) NSArray *coursesOfCurrentUserArray;

@property (nonatomic, weak) UIButton *deleteButton;
@property (nonatomic, weak) UIButton *addButton;
@property (weak, nonatomic) UITableViewCell *addCoursesButtonCell;

@property (strong, nonatomic) NSArray *allCoursesArray;

@property (strong, nonatomic) UIPopoverController *popover;

@property (assign, nonatomic) BOOL isCoursesArrayChangedInCoursesPickerDelegate;

@end

@implementation OPUserProfileViewController

// getter for managedObjectContext
- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[OPDataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSFetchRequest *allCoursesRequest = [self requestForEntity:@"OPCourse"];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [allCoursesRequest setSortDescriptors:@[nameDescriptor]];
    
    NSError *requestError = nil;
    
    self.allCoursesArray = [self.managedObjectContext executeFetchRequest:allCoursesRequest error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    if (self.user) {
        
        self.userValues = [NSArray arrayWithObjects:[self.user.firstName copy], [self.user.lastName copy], [self.user.email copy], nil];
    } else {
        self.userValues = [NSArray arrayWithObjects:@"", @"", @"", nil];
    }
    
    self.firstNameField = [[UITextField alloc] init];
    self.lastNameField = [[UITextField alloc] init];
    self.emailField = [[UITextField alloc] init];
    
    self.textFields = [NSArray arrayWithObjects:self.firstNameField, self.lastNameField, self.emailField, nil];
    
    for (UITextField *textField in self.textFields) {
        textField.delegate = self;
        textField.frame = CGRectMake(103, 7, 210, 30);
        textField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }

    if ([self.user isKindOfClass:[OPStudent class]]) {
        
        self.navigationItem.title = @"Student Profile";
        
        self.initialUserType = OPUserTypeStudent;
        
    } else if ([self.user isKindOfClass:[OPTeacher class]]) {
        
        self.navigationItem.title = @"Teacher Profile";
        
        self.initialUserType = OPUserTypeTeacher;
        
    } else {
        
        self.navigationItem.title = @"User Profile";
        
        self.initialUserType = -1;
    }
    
    self.userKeys = [NSArray arrayWithObjects:@"firstName", @"lastName", @"email", nil];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSave:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.userControl = [[UISegmentedControl alloc] initWithItems:@[@"Student", @"Teacher"]];
    self.userControl.frame = CGRectMake(103, 6, 110, 29);
    
    if ([self.user isKindOfClass:[OPStudent class]]) {
        self.userControl.selectedSegmentIndex = OPUserTypeStudent;
    } else if ([self.user isKindOfClass:[OPTeacher class]]) {
        self.userControl.selectedSegmentIndex = OPUserTypeTeacher;
    }
    
    [self.userControl addTarget:self action:@selector(actionUserControl:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.allowsSelectionDuringEditing = NO;
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.deleteButton setTitle:@"Delete course" forState:UIControlStateNormal];
    
    [self.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
    
    [self.deleteButton addTarget:self action:@selector(actionDeleteCoursesOfUser:) forControlEvents:UIControlEventTouchUpInside];
    
    // that line is important -> and then go to method actionDeleteCoursesOfUser:
    self.tableView.editing = NO;
    
    self.deleteButton.frame = CGRectMake(7, 7, 140, 30);
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.addButton setTitle:@"Add course" forState:UIControlStateNormal];
    
    [self.addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.addButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
    
    [self.addButton addTarget:self action:@selector(actionAddCoursesOfUser:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addButton.frame = CGRectMake(173, 7, 140, 30);
    
    self.addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
//    self.coursesOfCurrentUserArray = [self fetchCoursesOfCurrentUserArray];
    
    if (!self.isCoursesArrayChangedInCoursesPickerDelegate) {
        self.coursesOfCurrentUserArray = [self fetchCoursesOfCurrentUserArray];
    } else {
        self.isCoursesArrayChangedInCoursesPickerDelegate = NO;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Private Methods

- (NSFetchRequest *)requestForEntity:(NSString *)entity {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entity
                                                   inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:description];
    
    return fetchRequest;
}

- (NSArray *)fetchCoursesOfCurrentUserArray {
    
    NSArray *resultArray = [NSArray array];
    
    if (self.user) {
        
        NSFetchRequest *fetchRequest = [self requestForEntity:@"OPCourse"];
        
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [fetchRequest setSortDescriptors:@[nameDescriptor]];
        
        NSPredicate *predicate;
        
        if ([self.user isKindOfClass:[OPStudent class]]) {
            
            predicate = [NSPredicate predicateWithFormat:@"students contains %@", self.user];
            
        } else if ([self.user isKindOfClass:[OPTeacher class]]) {
            
            predicate = [NSPredicate predicateWithFormat:@"teacher == %@", self.user];
        }
        
        [fetchRequest setPredicate:predicate];
        
        NSError *requestError = nil;
        
        resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
        if (requestError) {
            NSLog(@"%@", [requestError localizedDescription]);
        }
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
        
        CGRect rect = [(UIButton *)sender frame];
        
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"User information";
        
    } else {
        return @"Courses";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return [self.userKeys count] + 1;
        
    } else {
        
        return [self.coursesOfCurrentUserArray count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        
        static NSString *identifier = @"UserProfileCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
        }
        
        if (indexPath.row == [self.userKeys count]) {
            
            [cell addSubview:self.userControl];
            
            
        } else {
            
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
            
            if (self.user) {
                
                textField.text = [self.userValues objectAtIndex:indexPath.row];
                
            }
            
            NSArray *labelNames = @[@"First name", @"Last name", @"E-mail"];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.text = [labelNames objectAtIndex:indexPath.row];
            
        }
        
    } else {
        
        // First cell is a special cell (with buttons "Delete courses" and "Add courses")
        if (indexPath.row == 0) {
            
            static NSString *addStudentIdentifier = @"AddCoursesCell";
            
            cell = [tableView dequeueReusableCellWithIdentifier:addStudentIdentifier];
            
            if (!cell) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addStudentIdentifier];
            }
            
            [cell addSubview:self.deleteButton];
            
            [cell addSubview:self.addButton];
            
            self.addCoursesButtonCell = cell;
            
        } else {
            
            static NSString *identifier = @"CoursesOfUserCell";
            
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                
            }
        
            OPCourse *course = [self.coursesOfCurrentUserArray objectAtIndex:(indexPath.row-1)];
            
            cell.textLabel.text = course.name;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
    }
    
    return cell;
}

// We need to finish handling code when you click on confirm button of the course removal from a courses list 
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // First we delete a course from the courses list (self.coursesOfCurrentUserArray)
        NSMutableArray *courses = [self.coursesOfCurrentUserArray mutableCopy];
        [courses removeObjectAtIndex:(indexPath.row - 1)];
        self.coursesOfCurrentUserArray = [courses copy];
        
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

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return UITableViewCellEditingStyleNone;
        
    } else {
        
        // Now finish possibility to remove the course from the course list for the current user
        return indexPath.row == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
    }
    
}

// Change the title of cofirmation button when deleting course (from "Delete" to "Remove Courses")
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove Courses";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Clicking on the cell with course you go to the screen for editing the course information - course profile controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPCourse *course = [self.coursesOfCurrentUserArray objectAtIndex:indexPath.row - 1]; // (- 1) is due to the fact that we have added the first cell with two buttons that increased array of rows in the second section by 1
    
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    NSMutableArray *array = [self.userValues mutableCopy];
    
    [array replaceObjectAtIndex:[self.textFields indexOfObject:textField] withObject:textField.text];
    
    self.userValues = [array copy];
    
    return YES;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.popover = nil;
}

#pragma mark - OPCoursesPickerDelegate

// Implementation of the protocol OPCoursesPickerDelegate method
- (void)reloadCoursesFromPicker:(OPCoursesPickerViewController *)vc {
    
    self.coursesOfCurrentUserArray = vc.coursesOfCurrentTeacher;
    
    self.isCoursesArrayChangedInCoursesPickerDelegate = vc.isCoursesArrayChanged;
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)actionSave:(UIBarButtonItem *)sender {
    
    if (self.initialUserType == -1) { // first is the case when we pressed the button to add a new user
        
        if ( (self.userControl.selectedSegmentIndex == OPUserTypeStudent) || (self.userControl.selectedSegmentIndex == -1) ) { // Here we consider the situation when we create a new user, we did not choose the type in self.userControl - defaults do OPStudent
            
            OPStudent *student = [NSEntityDescription insertNewObjectForEntityForName:@"OPStudent" inManagedObjectContext:self.managedObjectContext];
            
            student.firstName = self.firstNameField.text;
            student.lastName = self.lastNameField.text;
            student.email = self.emailField.text;
            
            student.courses = [NSSet setWithArray:self.coursesOfCurrentUserArray];
            
        } else if (self.userControl.selectedSegmentIndex == OPUserTypeTeacher) {
            
            OPTeacher *teacher = [NSEntityDescription insertNewObjectForEntityForName:@"OPTeacher" inManagedObjectContext:self.managedObjectContext];
            
            teacher.firstName = self.firstNameField.text;
            teacher.lastName = self.lastNameField.text;
            teacher.email = self.emailField.text;
            
            teacher.courses = [NSSet setWithArray:self.coursesOfCurrentUserArray];
        }
        
    } else if ( (self.userControl.selectedSegmentIndex == OPUserTypeTeacher) && (self.initialUserType == OPUserTypeStudent) ) { // Here is a case when OPStudent was and we change self.userControl to OPTeacher
        
        OPTeacher *teacher = [NSEntityDescription insertNewObjectForEntityForName:@"OPTeacher" inManagedObjectContext:self.managedObjectContext];
        
        teacher.firstName = self.firstNameField.text;
        teacher.lastName = self.lastNameField.text;
        teacher.email = self.emailField.text;
        
        teacher.courses = [NSSet setWithArray:self.coursesOfCurrentUserArray];
        
        [self.managedObjectContext deleteObject:self.user];
        
    } else if ( (self.userControl.selectedSegmentIndex == OPUserTypeStudent) && (self.initialUserType == OPUserTypeTeacher) ) { // Here is a case when OPTeacher was and we change self.userControl to OPStudent
        
        OPStudent *student = [NSEntityDescription insertNewObjectForEntityForName:@"OPStudent" inManagedObjectContext:self.managedObjectContext];
        
        student.firstName = self.firstNameField.text;
        student.lastName = self.lastNameField.text;
        student.email = self.emailField.text;
        
        student.courses = [NSSet setWithArray:self.coursesOfCurrentUserArray];
        
        [self.managedObjectContext deleteObject:self.user];
        
    } else { // and here we simply change the values of textFields
        
        OPUser *user = self.user;
        
        user.firstName = self.firstNameField.text;
        user.lastName = self.lastNameField.text;
        user.email = self.emailField.text;
        
        if ([user isKindOfClass:[OPStudent class]]) {
            
            OPStudent *student = (OPStudent *)self.user;
            student.courses = [NSSet setWithArray:self.coursesOfCurrentUserArray];
            
        } else if ([self.user isKindOfClass:[OPTeacher class]]) {
            
            OPTeacher *teacher = (OPTeacher *)self.user;
            teacher.courses = [NSSet setWithArray:self.coursesOfCurrentUserArray];
            
        }
        
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self.delegate reloadTableView:self];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)actionDeleteCoursesOfUser:(UIButton *)sender {
    
    BOOL isEditing = self.tableView.editing;
    
    [self.tableView setEditing:!isEditing animated:YES];
    
    if (self.tableView.editing) {
        
        [self.deleteButton setTitle:@"Done" forState:UIControlStateNormal];
        
    } else {
        
        [self.deleteButton setTitle:@"Delete courses" forState:UIControlStateNormal];
    }
}

// If you click on the button "Add courses", you go to a modal popover controller that contains a list of all courses, and courses added to that list have ticks. Here you can remove the courses from the user or add to this user new courses.
- (void)actionAddCoursesOfUser:(UIButton *)sender {
    
    OPCoursesPickerViewController *coursesPickerVC = [[OPCoursesPickerViewController alloc] init];
    coursesPickerVC.title = @"Add courses";
    
    coursesPickerVC.allCourses = self.allCoursesArray;
    coursesPickerVC.coursesOfCurrentTeacher = self.coursesOfCurrentUserArray;
    
    coursesPickerVC.delegate = self;
    
    // Be sure to check the device
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self showController:coursesPickerVC inPopoverFromSender:sender];
        
    } else {
        
        [self showControllerAsModal:coursesPickerVC];
        
    }
    
}

- (void)actionUserControl:(UISegmentedControl *)control {
    
    self.coursesOfCurrentUserArray = nil;
    
    [self.tableView reloadData];
}

@end
