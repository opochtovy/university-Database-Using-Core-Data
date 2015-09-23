//
//  OPStudentsPickerViewController.h
//  CoreData
//
//  Created by Oleg Pochtovy on 16.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPStudentsPickerViewController is a modal popover controller (after you have clicked on the button "Add student" in CourseProfile screen (OPCourseProfileViewController)) that contains a list of all students, and students who choose this course have ticks.

// The parent class for that class is UIViewController but we need dynamic table so we need to create @property tableView and write in code all tableView installation.

#import <UIKit/UIKit.h>

@protocol OPStudentsPickerDelegate;

// That class performs protocols UITableViewDataSource and UITableViewDelegate
@interface OPStudentsPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *allStudentsTableView;

@property (strong, nonatomic) NSArray *allStudents;
@property (strong, nonatomic) NSArray *studentsOfCurrentCourse;

@property (weak, nonatomic) id <OPStudentsPickerDelegate> delegate;

@property (assign, nonatomic) BOOL isStudentsArrayChanged;

@end

@protocol OPStudentsPickerDelegate

@required

- (void)reloadStudents:(OPStudentsPickerViewController *)vc;

@end

// -> OPCourseProfileViewController.m
