//
//  OPTeacherProfileViewController.h
//  CoreData
//
//  Created by Oleg Pochtovy on 18.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// That class has OPCoreDataViewController as its parent class - to observe the mechanism of creating teacher profile VC using NSFetchedResultsController but not usual fetch requests.

// On teacher profile screen you can add, edit and remove teachers. In the first section are the fields "firstName", "lastName" and "email". The second section is a list of teached courses. You can delete a course from courses list, but it is not removed from the database - it is removed just from the teacher's list. There is also a button to add courses (in the first cell of the second section). If you click on the course's cell, then you move on to course profile VC. If you click on the button "Add course", you go to a modal popover controller that contains a list of all courses, and courses added to that list have ticks. Here you can remove the courses from the teacher or add to this teacher new courses.

#import "OPCoreDataViewController.h"

@class OPTeacher;

@interface OPTeacherProfileViewController : OPCoreDataViewController

@property (strong, nonatomic) OPTeacher *teacher;

@end
