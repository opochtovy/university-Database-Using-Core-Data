//
//  OPCourseSubject.h
//  CoreData
//
//  Created by Oleg Pochtovy on 15.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OPObject.h"

@class OPCourse;

@interface OPCourseSubject : OPObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *courses;
@end

@interface OPCourseSubject (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(OPCourse *)value;
- (void)removeCoursesObject:(OPCourse *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

@end
