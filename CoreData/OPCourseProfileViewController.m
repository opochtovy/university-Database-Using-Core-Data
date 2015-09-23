//
//  OPCourseProfileViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 15.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// On course profile screen you can add, edit and remove course. In the first section are the fields "name", "subject" (name of Subject), "branch" and "teacher" (firstName and lastName of Teacher). The second section is a list of students who have subscribed to the course. You can delete a student from students list, but he is not removed from the database - he is removed just from the course. There is also a button to add students (in the first cell of the second section). If you click on the student's cell, then you move on to his profile VC. If you click on the button "Add student", you go to a modal popover controller that contains a list of all students, and students who choose this course have a tick. Here you can remove the students from the course or add on this course new students. As for the "Teacher" field: if you click on the cell with the teacher - you go to a modal popover controller that contains a list of all teachers, but here you can select only or nobody. If the teacher is selected, then the cell "Teacher" on the editing screen of the course must contain its firstName and lastName - if not, should be the text "Select a teacher".

#import "OPCourseProfileViewController.h"
#import "OPCourse.h"
#import "OPCourseSubject.h"
#import "OPStudent.h"
#import "OPTeacher.h"
#import "OPDataManager.h"
#import "OPUserProfileViewController.h"
#import "OPStudentsPickerViewController.h"
#import "OPTeacherPickerViewController.h"
#import "OPSubjectPickerViewController.h"

typedef enum {
    OPTextFieldName = 0,
    OPTextFieldSubject,
    OPTextFieldBranch,
    OPTextFieldTeacher
} OPTextField;

// That class performs protocol UITextFieldDelegate
// That class performs custom protocol OPStudentProfileDelegate
// That class performs protocol UIPopoverControllerDelegate
// That class performs custom protocol OPStudentsPickerDelegate
// That class performs custom protocol OPTeacherPickerDelegate
// That class performs custom protocol OPSubjectPickerDelegate
@interface OPCourseProfileViewController () <UITextFieldDelegate, OPStudentProfileDelegate, UIPopoverControllerDelegate, OPStudentsPickerDelegate, OPTeacherPickerDelegate, OPSubjectPickerDelegate>

@property (strong, nonatomic) NSArray *courseKeys;

@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *branchField;
@property (strong, nonatomic) UITextField *subjectField;
@property (strong, nonatomic) UITextField *teacherField;

@property (strong, nonatomic) NSArray *textFields;

@property (strong, nonatomic) OPCourse *currentCourse;
@property (strong, nonatomic) NSString *currentCourseName;
@property (strong, nonatomic) NSString *currentCourseBranch;

@property (strong, nonatomic) NSArray *studentsOfCurrentCourseArray;

@property (nonatomic, weak) UIButton *deleteButton;

@property (nonatomic, weak) UIButton *addButton;

@property (strong, nonatomic) UIPopoverController *popover;

@property (weak, nonatomic) UITableViewCell *addStudentsButtonCell;

@property (strong, nonatomic) NSArray *allStudentsArray;

@property (weak, nonatomic) UITableViewCell *teacherCell;

@property (strong, nonatomic) NSArray *allTeachers;

@property (strong, nonatomic) OPTeacher *teacherOfCurrentCourse;

@property (weak, nonatomic) UITableViewCell *subjectCell;

@property (strong, nonatomic) NSArray *allSubjects;

@property (strong, nonatomic) OPCourseSubject *subjectOfCurrentCourse;

@property (assign, nonatomic) BOOL isStudentsArrayChangedInStudentsPickerDelegate;
@property (assign, nonatomic) BOOL isTeacherChangedInTeacherPickerDelegate;
@property (assign, nonatomic) BOOL isSubjectChangedInSubjectPickerDelegate;

@end

@implementation OPCourseProfileViewController

// getter for managedObjectContext
- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[OPDataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentCourseName = [self.course.name copy];
    self.currentCourseBranch = [self.course.branch copy];
    
    self.studentsOfCurrentCourseArray = [NSArray array];
    
    NSError *requestError = nil;
    
    NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    
    // Create a list of all students (for display by pressing the button "Add Students")

    NSFetchRequest *allStudentsRequest = [self requestForEntity:@"OPStudent"];
    
    [allStudentsRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    
    self.allStudentsArray = [self.managedObjectContext executeFetchRequest:allStudentsRequest error:&requestError];
 
    // Create a list of all teachers (for display by pressing the textField teacherField)

    NSFetchRequest *allTeachersRequest = [self requestForEntity:@"OPTeacher"];
    
    [allTeachersRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    
    self.allTeachers = [self.managedObjectContext executeFetchRequest:allTeachersRequest error:&requestError];
    
    // Create a list of all subjects (for display by pressing the textField subjectField)
    
    NSFetchRequest *allSubjectsRequest = [self requestForEntity:@"OPCourseSubject"];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [allSubjectsRequest setSortDescriptors:@[nameDescriptor]];
    
    self.allSubjects = [self.managedObjectContext executeFetchRequest:allSubjectsRequest error:&requestError];
    
    self.navigationItem.title = @"Course Profile";
    
    self.courseKeys = [NSArray arrayWithObjects:@"name", @"subject", @"branch", @"teacher", nil];
    
    // Make 2 buttons for NavigationBar
    
    // Button to return without saving the changes
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton; // вместо backButton
    
    // Button to save all made changes
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSave:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.nameField = [[UITextField alloc] init];
    self.subjectField = [[UITextField alloc] init];
    self.branchField = [[UITextField alloc] init];
    self.teacherField = [[UITextField alloc] init];
    
    self.textFields = [NSArray arrayWithObjects:self.nameField, self.subjectField, self.branchField, self.teacherField, nil];
    
    for (UITextField *textField in self.textFields) {
        textField.delegate = self;
        textField.frame = CGRectMake(133, 7, 180, 30);
        textField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        textField.tag = [self.textFields indexOfObject:textField];
    }
    
    // Cell responses by pressing on it only in non-editing mode
    self.tableView.allowsSelectionDuringEditing = NO;
    
    // that line is important -> and then go to method actionDeleteStudentFromCourse:
    self.tableView.editing = NO;
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.deleteButton setTitle:@"Delete student" forState:UIControlStateNormal];
    
    [self.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
    
    [self.deleteButton addTarget:self action:@selector(actionDeleteStudentFromCourse:) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteButton.frame = CGRectMake(7, 7, 140, 30);
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.addButton setTitle:@"Add student" forState:UIControlStateNormal];
    
    [self.addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.addButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.2]];
    
    [self.addButton addTarget:self action:@selector(actionAddStudentToCourse:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addButton.frame = CGRectMake(173, 7, 140, 30);
    
    self.addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    if ( (self.isStudentsArrayChangedInStudentsPickerDelegate) || (self.isTeacherChangedInTeacherPickerDelegate) || (self.isSubjectChangedInSubjectPickerDelegate) ) {
        
        self.isStudentsArrayChangedInStudentsPickerDelegate = NO;
        self.isTeacherChangedInTeacherPickerDelegate = NO;
        self.isSubjectChangedInSubjectPickerDelegate = NO;
        
    } else {
        
        self.studentsOfCurrentCourseArray = [self fetchStudentsOfCurrentCourseArray];
        self.teacherOfCurrentCourse = [[self fetchTeacherOfCurrentCourseArray] firstObject];
        self.subjectOfCurrentCourse = [[self fetchSubjectOfCurrentCourseArray] firstObject];
        
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

- (NSArray *)fetchStudentsOfCurrentCourseArray {
    
    NSArray *resultArray = [NSArray array];
    
    if (self.course) {
        
        NSFetchRequest *fetchRequest = [self requestForEntity:@"OPStudent"];
        
        NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        [fetchRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courses contains %@", self.course];
        [fetchRequest setPredicate:predicate];
        
        NSError *requestError = nil;
        
        resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
        if (requestError) {
            NSLog(@"%@", [requestError localizedDescription]);
        }
    }
    
    return resultArray;
}

- (NSArray *)fetchTeacherOfCurrentCourseArray {
    
    NSArray *resultArray = [NSArray array];
    
    if (self.course) {
        
        NSFetchRequest *fetchRequest = [self requestForEntity:@"OPTeacher"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courses contains %@", self.course];
        [fetchRequest setPredicate:predicate];
        
        NSError *requestError = nil;
        
        resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
        if (requestError) {
            NSLog(@"%@", [requestError localizedDescription]);
        }
    }
    
    return resultArray;
}

- (NSArray *)fetchSubjectOfCurrentCourseArray {
    
    NSArray *resultArray = [NSArray array];
    
    if (self.course) {
        
        NSFetchRequest *fetchRequest = [self requestForEntity:@"OPCourseSubject"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courses contains %@", self.course];
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
        
        CGRect rect = [(UIButton *)sender frame]; //
        
        CGRect rectInSelfView;
        
        rectInSelfView = [self.view convertRect:rect fromView:self.addStudentsButtonCell];
        
        [popover presentPopoverFromRect:rectInSelfView
                                 inView:self.tableView
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
        
    } else if ([sender isKindOfClass:[UITextField class]]) {

        CGRect rectInSelfView;
        
        popover.popoverContentSize = CGSizeMake(320, 320);
        
        if ([sender isEqual:self.subjectField]) {
            
            rectInSelfView = [self.view convertRect:[self.subjectField frame] fromView:self.subjectCell];
            
        } else if ([sender isEqual:self.teacherField]) {
            
            rectInSelfView = [self.view convertRect:[self.teacherField frame] fromView:self.teacherCell];
            
        }
        
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
        return @"Course information";
    } else {
        return @"Students in course";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return [self.courseKeys count];
    } else {
        
        // First cell is a special cell (with buttons "Delete students" and "Add students")
        return [self.studentsOfCurrentCourseArray count] + 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        
        static NSString *identifier = @"CourseProfileCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
        }
        
        UITextField *textField = [self.textFields objectAtIndex:indexPath.row];
        
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        
        if ([textField isEqual:self.branchField]) {
            
            textField.returnKeyType = UIReturnKeyDone;
            
        } else {
            
            textField.returnKeyType = UIReturnKeyNext;
            
        }
        
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        textField.spellCheckingType = UITextSpellCheckingTypeNo;
        
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        
        if ([textField isEqual:self.branchField]) {
            textField.keyboardAppearance = UIKeyboardAppearanceDark;
        }
        
        [cell addSubview:textField];
        
        if (textField.tag == OPTextFieldName) {
            
            textField.text = self.currentCourseName;
            
        } else if (textField.tag == OPTextFieldBranch) {
            
            textField.text = self.currentCourseBranch;
            
        } else if (textField.tag == OPTextFieldSubject) {
            
            if (self.subjectOfCurrentCourse) {
                
                textField.text = self.subjectOfCurrentCourse.name;
            } else {
                
                textField.text = nil;
                textField.placeholder = @"Pick a subject";
            }
            
        } else if (textField.tag == OPTextFieldTeacher) {
            
            if (self.teacherOfCurrentCourse) {
                
                textField.text = [self.teacherOfCurrentCourse.firstName stringByAppendingFormat:@" %@", self.teacherOfCurrentCourse.lastName];
            } else {
                
                textField.text = nil;
                textField.placeholder = @"Pick a teacher";
            }
            
        }
        
        NSArray *labelNames = @[@"Name", @"Subject", @"Branch", @"Teacher"];
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
            
            self.addStudentsButtonCell = cell;
            
        } else {
            
            static NSString *identifier = @"StudentsOFCourseCell";
            
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                
            }
            
            // (- 1) is due to the fact that we have added the first cell with two buttons that increased array of rows in the second section by 1
            OPStudent *student = [self.studentsOfCurrentCourseArray objectAtIndex:(indexPath.row - 1)];
            
            cell.textLabel.text = [student.firstName stringByAppendingFormat:@" %@", student.lastName];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    
    return cell;
}

// We need to finish handling code when you click on confirm button of the student removal from a students list
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // First we delete a student from the students list (self.studentsOfCurrentCourseArray) 
        NSMutableArray *students = [self.studentsOfCurrentCourseArray mutableCopy];
        [students removeObjectAtIndex:(indexPath.row - 1)];
        self.studentsOfCurrentCourseArray = [students copy];
        
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
        
        // Now finish possibility to remove the student from the students list for the current course
        return indexPath.row == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
    }
    
}

// Change the title of cofirmation button when deleting student (from "Delete" to "Remove Student")
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove Student";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Clicking on the cell with student you go to the screen for editing the student information - student profile controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPStudent *student = [self.studentsOfCurrentCourseArray objectAtIndex:indexPath.row - 1]; // (- 1) is due to the fact that we have added the first cell with two buttons that increased array of rows in the second section by 1
    
    OPUserProfileViewController *vc = [[OPUserProfileViewController alloc] init];
    vc.user = student;
    
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.nameField]) {
        [self.branchField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.subjectField]) {
        
        OPSubjectPickerViewController *subjectPickerVC = [[OPSubjectPickerViewController alloc] init];
        subjectPickerVC.title = @"Pick subject";
        
        subjectPickerVC.allSubjects = self.allSubjects;
        subjectPickerVC.currentSubject = self.subjectOfCurrentCourse;
        
        subjectPickerVC.delegate = self;
        
        // Be sure to check the device
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            [self showController:subjectPickerVC inPopoverFromSender:textField];
            
        } else {
            
            [self showControllerAsModal:subjectPickerVC];
            
        }
        
        return NO;
        
    } else if ([textField isEqual:self.teacherField]) {
        
         OPTeacherPickerViewController *teacherPickerVC = [[OPTeacherPickerViewController alloc] init];
         teacherPickerVC.title = @"Pick teacher";
        
         teacherPickerVC.allTeachers = self.allTeachers;
         teacherPickerVC.currentTeacher = self.teacherOfCurrentCourse;
        
         teacherPickerVC.delegate = self;
         
         // Be sure to check the device
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
         
         [self showController:teacherPickerVC inPopoverFromSender:textField];
         
         } else {
         
         [self showControllerAsModal:teacherPickerVC];
         
         }

        return NO;
        
    } else {
        
        return YES;
    }
}

// Here we save intermediate changed values of self.course attributes (without fields that leed to popovers) before saving to the database
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField.tag == OPTextFieldName) {
        
        self.currentCourseName = textField.text;
        
    } else if (textField.tag == OPTextFieldBranch) {
        
        self.currentCourseBranch = textField.text;
            
    }
    
    return YES;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.popover = nil;
}

#pragma mark - OPStudentProfileDelegate

// Implementation of the protocol OPStudentProfileDelegate
- (void)reloadTableView:(OPUserProfileViewController *)vc {
    
    NSFetchRequest *studentsRequest = [self requestForEntity:@"OPStudent"];
    
    NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [studentsRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    
    NSPredicate *studentsPredicate = [NSPredicate predicateWithFormat:@"courses contains %@", self.course];
    [studentsRequest setPredicate:studentsPredicate];
    
    NSError *studentRequestError = nil;
    
    self.studentsOfCurrentCourseArray = [self.managedObjectContext executeFetchRequest:studentsRequest error:&studentRequestError];
    
    [self.tableView reloadData];
    
}

#pragma mark - OPStudentsPickerDelegate

// Implementation of the protocol OPStudentsPickerDelegate
- (void)reloadStudents:(OPStudentsPickerViewController *)vc {
    
    self.studentsOfCurrentCourseArray = vc.studentsOfCurrentCourse;
    
    self.isStudentsArrayChangedInStudentsPickerDelegate = vc.isStudentsArrayChanged;
    
    [self.tableView reloadData];
    
}

#pragma mark - OPTeacherPickerDelegate

// Implementation of the protocol OPTeacherPickerDelegate
- (void)reloadTeacher:(OPTeacherPickerViewController *)vc {
    
    self.teacherOfCurrentCourse = vc.currentTeacher;
    
    self.isTeacherChangedInTeacherPickerDelegate = vc.isTeacherChanged;
    
    [self.tableView reloadData];
}

#pragma mark - OPSubjectPickerDelegate

// Implementation of the protocol OPSubjectPickerDelegate
- (void)reloadSubject:(OPSubjectPickerViewController *)vc {
    
    self.subjectOfCurrentCourse = vc.currentSubject;
    
    self.isSubjectChangedInSubjectPickerDelegate = vc.isSubjectChanged;
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)actionSave:(UIBarButtonItem *)sender {
    
    OPCourse *course;
    
    if (self.course) {
        
        course = self.course;
        
    } else {
        
        course = [NSEntityDescription insertNewObjectForEntityForName:@"OPCourse" inManagedObjectContext:self.managedObjectContext];
        
    }
    
    course.name = self.nameField.text;
    course.branch = self.branchField.text;
    
    if (self.subjectOfCurrentCourse) {
        course.subject = self.subjectOfCurrentCourse;
    } else {
        course.subject = [self.allSubjects firstObject];
    }
    
    course.teacher = self.teacherOfCurrentCourse;
    
    course.students = [NSSet setWithArray:self.studentsOfCurrentCourseArray];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)actionDeleteStudentFromCourse:(UIButton *)sender {
    
    BOOL isEditing = self.tableView.editing;
    
    [self.tableView setEditing:!isEditing animated:YES];
    
    if (self.tableView.editing) {
        
        [self.deleteButton setTitle:@"Done" forState:UIControlStateNormal];
        
    } else {
        
        [self.deleteButton setTitle:@"Delete student" forState:UIControlStateNormal];
    }
}

// If you click on the button "Add students", you go to a modal popover controller that contains a list of all students, and students added to that list have ticks. Here you can remove the students from the course or add to this course new students.
- (void)actionAddStudentToCourse:(UIButton *)sender {
    
    OPStudentsPickerViewController *studentsPickerVC = [[OPStudentsPickerViewController alloc] init];
    studentsPickerVC.title = @"Add students";
    
    studentsPickerVC.allStudents = self.allStudentsArray;
    studentsPickerVC.studentsOfCurrentCourse = self.studentsOfCurrentCourseArray;
    
    studentsPickerVC.delegate = self;
    
    // Be sure to check the device
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self showController:studentsPickerVC inPopoverFromSender:sender];
        
    } else {
        
        [self showControllerAsModal:studentsPickerVC];
        
    }
    
}

@end
