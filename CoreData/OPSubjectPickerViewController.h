//
//  OPSubjectPickerViewController.h
//  CoreData
//
//  Created by Oleg Pochtovy on 17.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPSubjectPickerViewController is a modal popover controller (after you have clicked on the textField "Subject" in CourseProfile screen (OPCourseProfileViewController)) that contains a list of all subjects, and a subject chosen for this course has a tick.

#import <UIKit/UIKit.h>

@class OPCourseSubject;

@protocol OPSubjectPickerDelegate;

@interface OPSubjectPickerViewController : UITableViewController

@property (strong, nonatomic) NSArray *allSubjects;
@property (strong, nonatomic) OPCourseSubject *currentSubject;

@property (weak, nonatomic) id <OPSubjectPickerDelegate> delegate;

@property (assign, nonatomic) BOOL isSubjectChanged;

@end

@protocol OPSubjectPickerDelegate

@required

- (void)reloadSubject:(OPSubjectPickerViewController *)vc;

@end

// -> OPCourseProfileViewController.m
