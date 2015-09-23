//
//  OPDataManager.m
//  CoreData
//
//  Created by Oleg Pochtovy on 12.09.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPDataManager.h"
#import "OPObject.h"
#import "OPUser.h"
#import "OPStudent.h"
#import "OPTeacher.h"
#import "OPCourse.h"
#import "OPCourseSubject.h"

static NSString* firstNames[] = {
    @"Tran", @"Lenore", @"Bud", @"Fredda", @"Katrice",
    @"Clyde", @"Hildegard", @"Vernell", @"Nellie", @"Rupert",
    @"Billie", @"Tamica", @"Crystle", @"Kandi", @"Caridad",
    @"Vanetta", @"Taylor", @"Pinkie", @"Ben", @"Rosanna",
    @"Eufemia", @"Britteny", @"Ramon", @"Jacque", @"Telma",
    @"Colton", @"Monte", @"Pam", @"Tracy", @"Tresa",
    @"Willard", @"Mireille", @"Roma", @"Elise", @"Trang",
    @"Ty", @"Pierre", @"Floyd", @"Savanna", @"Arvilla",
    @"Whitney", @"Denver", @"Norbert", @"Meghan", @"Tandra",
    @"Jenise", @"Brent", @"Elenor", @"Sha", @"Jessie"
};

static NSString* lastNames[] = {
    
    @"Farrah", @"Laviolette", @"Heal", @"Sechrest", @"Roots",
    @"Homan", @"Starns", @"Oldham", @"Yocum", @"Mancia",
    @"Prill", @"Lush", @"Piedra", @"Castenada", @"Warnock",
    @"Vanderlinden", @"Simms", @"Gilroy", @"Brann", @"Bodden",
    @"Lenz", @"Gildersleeve", @"Wimbish", @"Bello", @"Beachy",
    @"Jurado", @"William", @"Beaupre", @"Dyal", @"Doiron",
    @"Plourde", @"Bator", @"Krause", @"Odriscoll", @"Corby",
    @"Waltman", @"Michaud", @"Kobayashi", @"Sherrick", @"Woolfolk",
    @"Holladay", @"Hornback", @"Moler", @"Bowles", @"Libbey",
    @"Spano", @"Folson", @"Arguelles", @"Burke", @"Rook"
};

static NSString* emails[] = {
    
    @"gmail.com", @"yahoo.com", @"usa.net"
};

static int namesCount = 50;
static int emailsCount = 3;

@interface OPDataManager ()

// We need that array to collect lastNames of students to comply with condition not to generate teacher's lastName from that array
@property (nonatomic, strong) NSMutableSet *studentLastNames;

@end

@implementation OPDataManager

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton

// Initialization of singleton
+ (OPDataManager *)sharedManager {
    
    static OPDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[OPDataManager alloc] init];
        
    });
    
    return manager;
}

#pragma mark - Private Methods

- (void)generateAndAddObjects {
    
    self.studentLastNames = [[NSMutableSet alloc] init];
    
    // That code first delete all old objects (entities) and then generates new objects (entities) for our database. That is necessery when we change our device (different versions of iPhone and iPad)

    NSError *error = nil;
 
    [self deleteAllObjects];
 
    for (int i = 0; i < 100; i++) {
     
        // First we generate students and teachers (100 users)
 
        NSUInteger who = arc4random_uniform(1000);
     
        if (who < 900) {
            OPStudent *student = [self addRandomStudent];
        } else {
            OPTeacher *teacher = [self addRandomTeacher];
        }
    }
 
    // Next we generate 5 courses and 3 courseSubjects
    
    NSArray *students = [self objectsForEntity:@"OPStudent"];
    
    NSArray *teachers = [self objectsForEntity:@"OPTeacher"];

    OPCourseSubject *subject1 = [NSEntityDescription insertNewObjectForEntityForName:@"OPCourseSubject" inManagedObjectContext:self.managedObjectContext];
    subject1.name = @"Programming";
     
    OPCourseSubject *subject2 = [NSEntityDescription insertNewObjectForEntityForName:@"OPCourseSubject" inManagedObjectContext:self.managedObjectContext];
    subject2.name = @"Biology";
     
    OPCourseSubject *subject3 = [NSEntityDescription insertNewObjectForEntityForName:@"OPCourseSubject" inManagedObjectContext:self.managedObjectContext];
    subject3.name = @"Chemistry";
     
    OPCourse *course1 = [self addCourseWithName:@"iOS" subject:subject1 branch:@"Computer science" teacherFromArray:teachers studentsFromArray:students];
     
    OPCourse *course2 = [self addCourseWithName:@"PHP" subject:subject1 branch:@"Computer science" teacherFromArray:teachers studentsFromArray:students];
     
    OPCourse *course3 = [self addCourseWithName:@"Anatomy" subject:subject2 branch:@"Natural Sciences" teacherFromArray:teachers studentsFromArray:students];
     
    OPCourse *course4 = [self addCourseWithName:@"Plants" subject:subject2 branch:@"Natural Sciences" teacherFromArray:teachers studentsFromArray:students];
     
    OPCourse *course5 = [self addCourseWithName:@"Organic Chemistry" subject:subject3 branch:@"Natural Sciences" teacherFromArray:teachers studentsFromArray:students];
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }

    // end of "That code..."
}

- (OPStudent *)addRandomStudent {
    
    OPStudent *student = [NSEntityDescription insertNewObjectForEntityForName:@"OPStudent" inManagedObjectContext:self.managedObjectContext];
    
    student.firstName = firstNames[arc4random_uniform(namesCount)];
    student.lastName = lastNames[arc4random_uniform(namesCount)];
    
    student.email = [NSString stringWithFormat:@"%c%@@%@", [[student.firstName lowercaseString] characterAtIndex:0], [student.lastName lowercaseString], emails[arc4random_uniform(emailsCount)]];
    
    [self.studentLastNames addObject:student.lastName];
    
    return student;
    
}

- (OPTeacher *)addRandomTeacher {
    
    OPTeacher *teacher = [NSEntityDescription insertNewObjectForEntityForName:@"OPTeacher" inManagedObjectContext:self.managedObjectContext];
    
    teacher.firstName = firstNames[arc4random_uniform(namesCount)];
    
    teacher.lastName = lastNames[arc4random_uniform(namesCount)];
    
    if ( ([self.studentLastNames count]) && ([self.studentLastNames containsObject:teacher.lastName]) ) {
        
        while (![self.studentLastNames containsObject:teacher.lastName]) {
            teacher.lastName = lastNames[arc4random_uniform(namesCount)];
        }
    }
    
    teacher.email = [NSString stringWithFormat:@"%c%@@%@", [[teacher.firstName lowercaseString] characterAtIndex:0], [teacher.lastName lowercaseString], emails[arc4random_uniform(emailsCount)]];
    
    return teacher;
    
}

- (OPCourse *)addCourseWithName:(NSString *)name subject:(OPCourseSubject *)subject branch:(NSString *)branch teacherFromArray:(NSArray *)teachers studentsFromArray:(NSArray *)students {
    
    OPCourse *course = [NSEntityDescription insertNewObjectForEntityForName:@"OPCourse" inManagedObjectContext:self.managedObjectContext];
    
    course.name = name;
    course.subject = subject;
    course.branch = branch;
    
    NSInteger number = arc4random_uniform((int)[teachers count]);
    OPTeacher *teacher = [teachers objectAtIndex:number];
    
    course.teacher = teacher;
    
    number = arc4random_uniform((int)[students count]);
    
    while ([course.students count] < number) {
        
        OPStudent *student = [students objectAtIndex:arc4random_uniform((int)number)];
        
        // That code checks if we have already just generated student in course.students
        if ([course.students containsObject:student]) {
            // Then we do nothing.
        } else {
            // Then we add that student to course.students
            [course addStudentsObject:student];
        }
    }
    
    return course;
}

- (NSArray *)allObjects {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"OPObject" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
    
}
- (NSArray *)objectsForEntity:(NSString *)entityName {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    if ([entityName isEqualToString:@"OPCourse"]) {
        
        [request setRelationshipKeyPathsForPrefetching:@[@"subject", @"teacher", @"students"]];
        
        NSSortDescriptor *subjectDescriptor = [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:YES];
        
        [request setSortDescriptors:@[subjectDescriptor]];
        
    } else if ([entityName isEqualToString:@"OPStudent"]) {
        
        [request setRelationshipKeyPathsForPrefetching:@[@"courses"]];
        
        NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        [request setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
        
    } else if ([entityName isEqualToString:@"OPTeacher"]) {
        
        [request setRelationshipKeyPathsForPrefetching:@[@"courses"]];
        
        NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        [request setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
        
    } else if ([entityName isEqualToString:@"OPCourseSubject"]) {
        
        [request setRelationshipKeyPathsForPrefetching:@[@"courses"]];
        
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [request setSortDescriptors:@[nameDescriptor]];
        
    }
    
    NSError *requestError = nil;
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
}

- (void)deleteAllObjects {
    
    NSArray *allObjects = [self allObjects];
    
    for (id object in allObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.olegpochtovy.CoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreData.sqlite"];
    
    NSError *error = nil;
    //    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        // Here I added two lines to avoid abort of app.
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        
        /*
         
         // Report any error we got.
         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
         dict[NSLocalizedFailureReasonErrorKey] = failureReason;
         dict[NSUnderlyingErrorKey] = error;
         error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
         // Replace this with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
         */
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
