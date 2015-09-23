//
//  OPStudentsPickerViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 16.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPStudentsPickerViewController is a modal popover controller (after you have clicked on the button "Add student" in CourseProfile screen (OPCourseProfileViewController)) that contains a list of all students, and students who choose this course have ticks.

// The parent class for that class is UIViewController but we need dynamic table so we need to create @property tableView and write in code all tableView installation.

#import "OPStudentsPickerViewController.h"
#import "OPStudent.h"

@interface OPStudentsPickerViewController ()

// number of objects for that array is the same as for self.allStudents
@property (strong, nonatomic) NSMutableArray *checkBoxes;

@end

@implementation OPStudentsPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add students";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        self.allStudentsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        
    } else {
        
        // Your popoverview is not big enough to cover the right boundary of tableview. Make the frame of your tableview proper and you will find the check mark
        self.allStudentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 320.f) style:UITableViewStylePlain];
    }
    
    self.allStudentsTableView.dataSource = self;
    self.allStudentsTableView.delegate = self;
    
    [self.view addSubview:self.allStudentsTableView];
    
    self.checkBoxes = [[NSMutableArray alloc] init];
    
    for (OPStudent *student in self.allStudents) {
        
        BOOL checkBox = NO;
        
        if ([self.studentsOfCurrentCourse containsObject:student]) {
            checkBox = YES;
        }
        
        [self.checkBoxes addObject:[NSNumber numberWithBool:checkBox]];
    }
    
    // Make 2 buttons for NavigationBar for iPhone : Cancel and Save
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSave:)];
        
        self.navigationItem.rightBarButtonItem = saveButton;
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.allStudents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    OPStudent *student = [self.allStudents objectAtIndex:indexPath.row];
    cell.textLabel.text = [student.firstName stringByAppendingFormat:@" %@", student.lastName];
    
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
    
    [self.allStudentsTableView reloadData];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        NSMutableArray *studentsOfCurrentCourse = [[NSMutableArray alloc] init];
        
        for (OPStudent *student in self.allStudents) {
            
            NSInteger i = [self.allStudents indexOfObject:student];
            NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
            BOOL hasCheckBox = [numberWithBool boolValue];
            if (hasCheckBox) {
                
                [studentsOfCurrentCourse addObject:student];
            }
        }
        
        self.studentsOfCurrentCourse = [studentsOfCurrentCourse copy];
        
        self.isStudentsArrayChanged = YES;
        
        [self.delegate reloadStudents:self];
        
    }
    
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)actionSave:(UIBarButtonItem *)sender {
    
    NSMutableArray *studentsOfCurrentCourse = [[NSMutableArray alloc] init];
    
    for (OPStudent *student in self.allStudents) {
        
        NSInteger i = [self.allStudents indexOfObject:student];
        NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
        BOOL hasCheckBox = [numberWithBool boolValue];
        if (hasCheckBox) {
            
            [studentsOfCurrentCourse addObject:student];
        }
    }
    
    self.studentsOfCurrentCourse = [studentsOfCurrentCourse copy];
    
    self.isStudentsArrayChanged = YES;
    
    [self.delegate reloadStudents:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
