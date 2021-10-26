# Course Management System
A Course Management System for The University of Wisconsin Madison.

Our project can be used by students and instructors to manage their courses. Instructors can add course offerings to which students can register. There is also a third user for the admin/registrar to start a term, start and end the add drop phase, add new students and courses. In addition to these there are a lot of other functionalities we have implemented that we have discussed in the subsequent sections.


## Resources and languages used in the project

[<img alt="Dataset from Kaggle" title="Kaggle Dataset Link" width="70px" src="https://www.kaggle.com/static/images/site-logo.png" />][datasetURL] &nbsp; <img alt="PostgreSQL was used in the backend" title="PostgreSQL as Backend" width="27px" src="https://www.postgresql.org/media/img/about/press/elephant.png" /> &nbsp; <img alt="Flask application framework was used" title="Flask Application Framework" width="40px" src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcms-assets.tutsplus.com%2Fuploads%2Fusers%2F30%2Fposts%2F16037%2Fpreview_image%2Fflask.png&f=1&nofb=1" />

A demostration of our working system is present on google drive: [DemoVideo] 


## Installation Instructions

- Clone this repository on your local computer.
- Our project uses flask and psycopg2-binary so oe needs to download the same before use. The following command downloads the same.
```
bash setup_front_end.sh
```
- Below are the configurations for the Postgres Server:
```
dbname=group_13
user=group_13
port=5432
```
Note: You must change the host's IP address in the following files before proceeding any further
1. [app.py](https://github.com/JaiJaveria/Course_Management_System/blob/main/app.py) (Line No. - 12)
2. [students.py](https://github.com/JaiJaveria/Course_Management_System/blob/main/students.py) (Line No. - 5)
3. [Admin.py](https://github.com/JaiJaveria/Course_Management_System/blob/main/Admin.py) (Line No. - 6)
- Download the [data dump](https://drive.google.com/drive/folders/1HDx3uShbgdi1MJdjkv7QZJDr8yh0lLM7?usp=sharing) and upload it on the Postgres server.

- To start the flash server do
```
bash run.sh
```
## Data Source
The data upon which we made the system was majorly taken from Kaggle whose link is provided in the Resource section. This dataset did not have have term code information. This we manually scraped from The University's [Division of Business Services Website]

The following data cleaning was undertaken
- In the sections table of the dataset, null values were actually 'null' i.e. a string. We updated it by changing that to SQL NULL.
- We wanted to simulate the course registration process in our project. For this we came up with a notion of registration limit. For a course offered, students can directly add themselves until the limit is full. After that, a pending request to the instructor is sent and it is accepted or rejected by them. For this we calculated the registration limit of all the course offerings. This was done via the grade_distribution table. This contains the distribution of the number of grades for each course. We calculated the registration limit for a course offering and section via summing all the number of grades given for that. We added this to the section table.
- We added some new tables like pending_requests, rejected_requests, course_registrations, current_term, adddrop  to simulate the course registration/pending/drop process. The dataset did not have a table for students, we added one.

## User’s View
### Admin
- Start a particular term so that instructors can float courses and students can register in it.
- Start and end the add drop phase. Students can register in courses only in this phase.
- Check if the add drop phase for a current term is on or not.
- Introduce a new course which can be floated by any instructor in the list of courses offered by the university. This is NOT the same as floating a course for a term. That will be done by the instructor. (This is like a new addition to the “Courses of Study” if we talk about the IITD system)
- Add a new student to the system.

### Instructor
- Float a course for students to register. This would need the course id, section number, registration limit, section type like LEC(lecture), LAB, FLD(field), SEM (Seminar) subject code determining which subject(something like a department) is floating the course e.g. code for the Computer Science department is 266. We have assumed that an instructor would know the subject code and have not implemented a search on it. All subject code can be found in the subjects table of our database. Note: A single course offering can have multiple sections, each being taught by a different professor. Thus the section number becomes necessary. (Like COL100 being taught by multiple professors at IITD). Note: Some other subject codes are: 320 for ‘Electrical and Computer Engineering’, 224 for ‘Chemistry’, 528 for ‘Law’. subjects table has the whole list.
- 1 requires to get a course id for floating a course. Thus there is functionality to search it for a course. Input is just a substring for the name of the course and we return all the course ids of the corresponding courses.
- As described in cleanup in section 2, if the number of students registered is equal to the registration limit then a new student who wants to register for that course goes into the pending list. We have given the functionality for the instructor to fetch the pending list and accept/reject the students request. A student cannot add back the course if it is rejected once. (Note: This functionality is not present in the real eacademics system of IITD(to the best of our knowledge) and coming up with this in our project was something really exciting)
- After floating a course, there would be a room and schedule(slot) allocated for the class. We also show this to the instructor.
- Instructors can also fetch the enrollment list of students enrolled in a particular course offering.
- The instructor can get a grade distribution of a course offering i.e. the number of a’s given, number of b’s etc.
- The instructor can also set the grade distribution for a course offering.
- The instructor can see which room is allocated to a course offering.

### Students
- Search for a particular course offering in the current term and register for it.
- Get the daily schedule of classes and rooms allocated.
- Drop a particular registered course. A student cannot add back a dropped course.
- See the past stats of a particular course to get an idea of the level of difficulty of it. We show the percentages of grades given calculated upon the total number of people registered. A course can have a lot of different course offerings and sections. We take the average of all of these.

## System’s view
### Special Functionality
We have the following materialized views  
- Disjoint_schedule: To allocate rooms and schedules to a particular course we need to ensure that 2 courses do not end up being allocated to the same room at a particular time. Thus to do so we have extracted 6 schedules whose timing/days do not clash at all. At runtime while adding a course offering we select any one of the rooms, disjoint_schedule pair which is free.
- Schedule_rooms: we have extracted the rooms and schedules for all sections of all course offerings. This helps speed up our queries since to get a schedule and room for a section involves joining of rooms, sections and schedules.
- Grade_distribution_percentages: The grade distribution table just gives the number of students that got a particular grade. For past stats we give the result as percentages which are computed and stored in this view.
- Instructor_course: This contains information of which instructor took which section in which course offering of the course. It contains attributes instructor_id, instructor_name, course_name, course_uuid, course_offering_uuid, course_offering_term, section_number. This speeds up our queries since it requires joins of instructors, teachings, sections, course_offerings and courses.

---
[datasetURL]:  https://www.kaggle.com/Madgrades/uw-madison-courses
[DemoVideo]: https://drive.google.com/file/d/1mJKFb27aCpLbkgED3ENUNf29iWzZXxPC/view?usp=sharing
[Division of Business Services Website]: https://businessservices.wisc.edu/making-payments/charge-to-a-students-account/term-codes/
