//
//  OPTeacherPickerViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 17.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPTeacherPickerViewController is a modal popover controller (after you have clicked on the textField "Teacher" in CourseProfile screen (OPCourseProfileViewController)) that contains a list of all teachers, and a teacher chosen for this course has a tick.

// The parent class for that class is UIViewController but we need dynamic table so we need to create @property tableView and write in code all tableView installation.

#import "OPTeacherPickerViewController.h"
#import "OPTeacher.h"

@interface OPTeacherPickerViewController ()

@end

@implementation OPTeacherPickerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        self.teacherListTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        
    } else {
        
        // Your popoverview is not big enough to cover the right boundary of tableview. Make the frame of your tableview proper and you will find the check mark
        self.teacherListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 320.f) style:UITableViewStylePlain];
    }
    
    self.teacherListTableView.dataSource = self;
    self.teacherListTableView.delegate = self;
    
    [self.view addSubview:self.teacherListTableView];
    
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
    
    return [self.allTeachers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    OPTeacher *teacher = [self.allTeachers objectAtIndex:indexPath.row];
    cell.textLabel.text = [teacher.firstName stringByAppendingFormat:@" %@", teacher.lastName];
    
    if ([teacher isEqual:self.currentTeacher]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPTeacher *selectedTeacher = [self.allTeachers objectAtIndex:indexPath.row];
    
    if ([selectedTeacher isEqual:self.currentTeacher]) {
        
        self.currentTeacher = nil;
        
        NSLog(@"currentTeacher = nil !!!!!");
    } else {
        
        self.currentTeacher = selectedTeacher;
    }
    
    [self.teacherListTableView reloadData];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        self.isTeacherChanged = YES;
        
        [self.delegate reloadTeacher:self];
        
    }
    
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)actionSave:(UIBarButtonItem *)sender {
    
    self.isTeacherChanged = YES;
    
    [self.delegate reloadTeacher:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
