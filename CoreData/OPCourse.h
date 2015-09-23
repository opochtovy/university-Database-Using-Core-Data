//
//  OPCourse.h
//  CoreData
//
//  Created by Oleg Pochtovy on 15.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OPObject.h"

@class OPCourseSubject, OPStudent, OPTeacher;

@interface OPCourse : OPObject

@property (nonatomic, retain) NSString * branch;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) OPCourseSubject *subject;
@property (nonatomic, retain) NSSet *students;
@property (nonatomic, retain) OPTeacher *teacher;
@end

@interface OPCourse (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(OPStudent *)value;
- (void)removeStudentsObject:(OPStudent *)value;
- (void)addStudents:(NSSet *)values;
- (void)removeStudents:(NSSet *)values;

@end
