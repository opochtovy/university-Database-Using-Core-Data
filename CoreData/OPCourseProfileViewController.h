//
//  OPCourseProfileViewController.h
//  CoreData
//
//  Created by Oleg Pochtovy on 15.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// On course profile screen you can add, edit and remove course. In the first section are the fields "name", "subject" (name of Subject), "branch" and "teacher" (firstName and lastName of Teacher). The second section is a list of students who have subscribed to the course. You can delete a student from students list, but he is not removed from the database - he is removed just from the course. There is also a button to add students (in the first cell of the second section). If you click on the student's cell, then you move on to his profile VC. If you click on the button "Add student", you go to a modal popover controller that contains a list of all students, and students who choose this course have a tick. Here you can remove the students from the course or add on this course new students. As for the "Teacher" field: if you click on the cell with the teacher - you go to a modal popover controller that contains a list of all teachers, but here you can select only or nobody. If the teacher is selected, then the cell "Teacher" on the editing screen of the course must contain its firstName and lastName - if not, should be the text "Select a teacher".

#import <UIKit/UIKit.h>

@class OPCourse;

@interface OPCourseProfileViewController : UITableViewController

// @property managedObjectContext is used to get managedObjectContext from [OPDataManager sharedManager]
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) OPCourse *course;

@end
