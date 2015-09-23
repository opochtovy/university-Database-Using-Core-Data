//
//  OPCoursesPickerViewController.h
//  CoreData
//
//  Created by Oleg Pochtovy on 19.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// OPCoursesPickerViewController is a modal popover controller (after you have clicked on the button "Add course" in UserProfile or TeacherProfile screen (OPUserProfileViewController or OPTeacherProfileViewController)) that contains a list of all courses, and chosen courses have ticks.

#import <UIKit/UIKit.h>

@protocol OPCoursesPickerDelegate;

@interface OPCoursesPickerViewController : UITableViewController

@property (strong, nonatomic) NSArray *allCourses;
@property (strong, nonatomic) NSArray *coursesOfCurrentTeacher;

@property (weak, nonatomic) id <OPCoursesPickerDelegate> delegate;

@property (assign, nonatomic) BOOL isCoursesArrayChanged;

@end

@protocol OPCoursesPickerDelegate

@required

- (void)reloadCoursesFromPicker:(OPCoursesPickerViewController *)vc;

@end

// -> OPTeacherProfileViewController.m
