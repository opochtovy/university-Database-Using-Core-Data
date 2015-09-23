//
//  OPTeacherPickerViewController.h
//  CoreData
//
//  Created by Oleg Pochtovy on 17.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPTeacherPickerViewController is a modal popover controller (after you have clicked on the textField "Teacher" in CourseProfile screen (OPCourseProfileViewController)) that contains a list of all teachers, and a teacher chosen for this course has a tick.

// The parent class for that class is UIViewController but we need dynamic table so we need to create @property tableView and write in code all tableView installation.

#import <UIKit/UIKit.h>

@class OPTeacher;

@protocol OPTeacherPickerDelegate;

// That class performs protocols UITableViewDataSource and UITableViewDelegate
@interface OPTeacherPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *teacherListTableView;

@property (strong, nonatomic) NSArray *allTeachers;
@property (strong, nonatomic) OPTeacher *currentTeacher;

@property (weak, nonatomic) id <OPTeacherPickerDelegate> delegate;

@property (assign, nonatomic) BOOL isTeacherChanged;

@end

@protocol OPTeacherPickerDelegate

@required

- (void)reloadTeacher:(OPTeacherPickerViewController *)vc;

@end

// -> OPCourseProfileViewController.m
