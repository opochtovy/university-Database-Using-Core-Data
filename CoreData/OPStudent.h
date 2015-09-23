//
//  OPStudent.h
//  CoreData
//
//  Created by Oleg Pochtovy on 11.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OPUser.h"

@class OPCourse;

@interface OPStudent : OPUser

@property (nonatomic, retain) NSSet *courses;
@end

@interface OPStudent (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(OPCourse *)value;
- (void)removeCoursesObject:(OPCourse *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

@end
