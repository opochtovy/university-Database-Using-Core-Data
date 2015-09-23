//
//  OPSubjectPickerViewController.m
//  CoreData
//
//  Created by Oleg Pochtovy on 17.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPSubjectPickerViewController is a modal popover controller (after you have clicked on the textField "Subject" in CourseProfile screen (OPCourseProfileViewController)) that contains a list of all subjects, and a subject chosen for this course has a tick.

#import "OPSubjectPickerViewController.h"
#import "OPCourseSubject.h"

@interface OPSubjectPickerViewController ()

@end

@implementation OPSubjectPickerViewController

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.allSubjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    OPCourseSubject *subject = [self.allSubjects objectAtIndex:indexPath.row];
    cell.textLabel.text = subject.name;
    
    if ([subject isEqual:self.currentSubject]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OPCourseSubject *selectedSubject = [self.allSubjects objectAtIndex:indexPath.row];
    
    if ( (![selectedSubject isEqual:self.currentSubject]) || (!self.currentSubject) ) {
        
        self.currentSubject = selectedSubject;
    }
    
    [self.tableView reloadData];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        self.isSubjectChanged = YES;
        
        [self.delegate reloadSubject:self];
        
    }
    
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)actionSave:(UIBarButtonItem *)sender {
    
    self.isSubjectChanged = YES;
    
    [self.delegate reloadSubject:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
