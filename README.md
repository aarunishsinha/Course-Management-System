# Course_Management_System
A Course Management System for The University of Wisconsin Madison. Done as a project in the COL362: Introduction to DBMS course at IIT Delhi
The data that we would be working on is taken from: https://www.kaggle.com/Madgrades/uw-madison-courses

## I/O of Queries:
### Instructor Queries
1. add_course_offering
```
INPUT:
CID text                  --- course_id
TC int                    --- term_code
SN int                    --- section_num
LIM int                   --- course_reg_limit
ROOM_REQ boolean          --- room required or not
ST text                   --- section type
INSTRUCTOR bigint         --- instructor_id
subj_code text            --- subject code(dept that is floating the course)
```
2. get_pending_requests
```
INPUT:
CO text                   --- course_offering_uuid
SECN int                  --- section number

OUTPUT:
student_id bigint         --- student id
```
3. process_pending_request
```
INPUT:
CO text                   --- course_offering_uuid
ACCEPTED boolean          --- if accepted on frontend (button/radio)
SECN int                  --- section number
SID bigint                --- student_id
```
4. get_instructor_schedule
```
INPUT:
INSTRUCTOR bigint         --- instructor_id
TC int                    --- term_code

OUTPUT:
course_offered_name text  --- course_offering_name
start_time int            --- start time in minutes of day
end_time int              --- end time in minutes of day
mon boolean               --- true is schedule is on monday
tues boolean              --- true is schedule is on tuesday
wed boolean               --- and so on....
thurs boolean             ---
fri boolean               ---
sat boolean               ---
sun boolean               ---   
```
