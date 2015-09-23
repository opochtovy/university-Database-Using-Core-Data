//
//  OPUserProfileViewController.h
//  CoreData
//
//  Created by Oleg Pochtovy on 14.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// On user profile screen you can add, edit and remove users (student or teacher). In the first section are the fields "firstName", "lastName", "email" and segmentedControl to choose the type of user (student or teacher). The second section is a list of courses (studied courses or teached courses). You can delete a course from courses list, but it is not removed from the database - it is removed just from the user's list. There is also a button to add courses (in the first cell of the second section). If you click on the course's cell, then you move on to course profile VC. If you click on the button "Add course", you go to a modal popover controller that contains a list of all courses, and courses added to that list have a tick. Here you can remove the courses from the user or add to this user new courses.

#import <UIKit/UIKit.h>

// 1.9.4
@class OPUser;

@protocol OPStudentProfileDelegate;

@interface OPUserProfileViewController : UITableViewController

@property (strong, nonatomic) OPUser *user;

// @property managedObjectContext is used to get managedObjectContext from [OPDataManager sharedManager]
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) id <OPStudentProfileDelegate> delegate;

@end

// My custom protocol OPStudentProfileDelegate
@protocol OPStudentProfileDelegate //<NSObject>

@required
- (void)reloadTableView:(OPUserProfileViewController *)vc;

@end

// -> OPCourseProfileViewController.m
