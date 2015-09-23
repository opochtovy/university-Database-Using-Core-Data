university-Database-Using-Core-Data

The API illustrates how to create university database using Core Data. App has 3 screens (tabs) showing users, courses and teachers.

Users screen shows all users (students and teachers) in a dynamic table. When you press on one of them you go to user's profile screen to see and edit its information.

Courses screen shows all courses in a dynamic table. When you press on one of them you go to course profile screen to see and edit its information.

Teachers screen shows all teachers grouped by "courseSubject" in a dynamic table. Each teacher lists the number of courses. When you press on one of them you go to teacher profile screen to see and edit its information.

On user profile screen you can add, edit and remove user (student or teacher). In the first section are the fields "firstName", "lastName", "email" and segmentedControl to choose the type of user (student or teacher). The second section is a list of courses (studied courses or teached courses). You can delete a course from courses list, but it is not removed from the database - it is removed just from the user's list. There is also a button to add courses (in the first cell of the second section). If you click on the course's cell, then you move on to course profile VC. If you click on the button "Add course", you go to a modal popover controller that contains a list of all courses, and courses added to that list have ticks. Here you can remove the courses from the user or add to this user new courses.

On course profile screen you can add, edit and remove course. In the first section are the fields "name", "subject" (name of subject), "branch" and "teacher" (firstName and lastName of teacher). The second section is a list of students who have subscribed to the course. You can delete a student from students list, but he is not removed from the database - he is removed just from the course. There is also a button to add students (in the first cell of the second section). If you click on the student's cell, then you move on to his profile VC. If you click on the button "Add student", you go to a modal popover controller that contains a list of all students, and students who choose this course have ticks. Here you can remove the students from the course or add on this course new students. As for the «Teacher» field: if you click on the cell with the teacher - you go to a modal popover controller that contains a list of all teachers, but here you can select only or nobody. If the teacher is selected, then the cell "Teacher" on the editing screen of the course must contain its firstName and lastName - if not, should be the text "Select a teacher". As for the «Subject» field: if you click on the cell with the subject - you go to a modal popover controller that contains a list of all subjects, but here you can select only one. If the subject is selected, then the cell «Subject» on the editing screen of the course must contain its name - if not, should be the text «Select a subject».

On teacher profile screen you can add, edit and remove teacher. In the first section are the fields "firstName", "lastName" and "email". The second section is a list of teached courses. You can delete a course from courses list, but it is not removed from the database - it is removed just from the teacher's list. There is also a button to add courses (in the first cell of the second section). If you click on the course's cell, then you move on to course profile VC. If you click on the button "Add course", you go to a modal popover controller that contains a list of all courses, and courses added to that list have ticks. Here you can remove the courses from the teacher or add to this teacher new courses.

During my app’s realization I touched the following topics:

- KVC & KVO;
- basics of Core Data;
- NSFetchedResultsController;
- UITabBarController & UINavigationController;
- creating custom UIBarButtonItems & UIButtons;
- creating custom tableView in code;
- creating custom singleton;
- creating custom protocols and using delegates for them;
- using popover VC for iPad;
- using modal VC instead of popover VC for iPhone.

Key features of the app: 

1. this app is universal (iPhone / iPad);
2. creating entities and relationShips in model file;
3. using basics of Core Data to create objects, save and delete them from persistent store;
4. using NSFetchedResultsController - controller between View and Core Data;
5. using different ways to fetch objects from persistent store.