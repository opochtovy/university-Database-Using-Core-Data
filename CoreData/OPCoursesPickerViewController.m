//
//  OPCoursesPickerViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 19.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPCoursesPickerViewController is a modal popover controller (after you have clicked on the button "Add course" in UserProfile or TeacherProfile screen (OPUserProfileViewController or OPTeacherProfileViewController)) that contains a list of all courses, and chosen courses have ticks.

#import "OPCoursesPickerViewController.h"
#import "OPCourse.h"

@interface OPCoursesPickerViewController ()

// number of objects for that array is the same as for self.allCourses
@property (strong, nonatomic) NSMutableArray *checkBoxes;

@end

@implementation OPCoursesPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        // Your popoverview is not big enough to cover the right boundary of tableview. Make the frame of your tableview proper and you will find the check mark
        self.tableView.frame = CGRectMake(0.f, 0.f, 320.f, 320.f);
    }
    
    // Make 2 buttons for NavigationBar for iPhone : Cancel and Save
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton; // вместо backButton
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSave:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        
    }
    
    self.checkBoxes = [[NSMutableArray alloc] init];
    
    for (OPCourse *course in self.allCourses) {
        
        BOOL checkBox = NO;
        
        if ([self.coursesOfCurrentTeacher containsObject:course]) {
            
            checkBox = YES;
        }
        
        [self.checkBoxes addObject:[NSNumber numberWithBool:checkBox]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.allCourses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    OPCourse *course = [self.allCourses objectAtIndex:indexPath.row];
    cell.textLabel.text = course.name;
    
    NSNumber *number = [self.checkBoxes objectAtIndex:indexPath.row];
    BOOL hasCheckBox = [number boolValue];
    
    if (hasCheckBox) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *number = [self.checkBoxes objectAtIndex:indexPath.row];
    BOOL hasCheckBox = [number boolValue];
    
    hasCheckBox = !hasCheckBox;
    
    [self.checkBoxes replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:hasCheckBox]];
    
    [self.tableView reloadData];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        NSMutableArray *coursesOfCurrentTeacher = [[NSMutableArray alloc] init];
        
        for (OPCourse *course in self.allCourses) {
            
            NSInteger i = [self.allCourses indexOfObject:course];
            NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
            BOOL hasCheckBox = [numberWithBool boolValue];
            if (hasCheckBox) {
                
                [coursesOfCurrentTeacher addObject:course];
            }
        }
        
        self.coursesOfCurrentTeacher = [coursesOfCurrentTeacher copy];
        
        self.isCoursesArrayChanged = YES;
        
        [self.delegate reloadCoursesFromPicker:self];
        
    }
    
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)actionSave:(UIBarButtonItem *)sender {
    
    NSMutableArray *coursesOfCurrentTeacher = [[NSMutableArray alloc] init];
    
    for (OPCourse *course in self.allCourses) {
        
        NSInteger i = [self.allCourses indexOfObject:course];
        NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
        BOOL hasCheckBox = [numberWithBool boolValue];
        
        if (hasCheckBox) {
            
            [coursesOfCurrentTeacher addObject:course];
        }
    }
    
    self.coursesOfCurrentTeacher = [coursesOfCurrentTeacher copy];
    
    self.isCoursesArrayChanged = YES;
    
    [self.delegate reloadCoursesFromPicker:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
