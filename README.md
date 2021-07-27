# Course_Management_System
A Course Management System for The University of Wisconsin Madison. Done as a project in the COL362: Introduction to DBMS course at IIT Delhi
The data that we would be working on is taken from: https://www.kaggle.com/Madgrades/uw-madison-courses

[Demo Video](https://drive.google.com/file/d/1mJKFb27aCpLbkgED3ENUNf29iWzZXxPC/view?usp=sharing)

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
	course_offering_uuid text,--- the unique id number
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
5. get_student_list
```
INPUT:
CO text                   --- course_offering_uuid
SECN int                  --- section_number

OUTPUT:
student_id bigint         --- student_id
```
6. set_grade_distribution
```
INPUT:
COID text                 --- course_offering_uuid
SECN int                  --- section number
a_count int               
ab_count int
b_count int
bc_count int
c_count int
d_count int
f_count int
s_count int
u_count int
cr_count int
n_count int
p_count int
i_count int
nw_count int
nr_count int
other_count int
```
7. get_grade_distribution
```
INPUT:
course_offering_id text    --- course_offering_uuid
section_num int            --- section number

OUTPUT:
COID text                  --- course_offering_uuid
SECN int                   --- section number
a_count int               
ab_count int
b_count int
bc_count int
c_count int
d_count int
f_count int
s_count int
u_count int
cr_count int
n_count int
p_count int
i_count int
nw_count int
nr_count int
other_count int
```
8. get_num_students_reg
```
INPUT:
course_offering_uuid text

OUTPUT:
num_student bigint           --- number of students in the course
```
9. get_room_instr
```
INPUT:
COID text                    --- course_offering_uuid
SECN int                     --- section number

OUTPUT:
facility_code text           --- facility code
room_code text
```
10. search_course_instructor
```
INPUT:
	CNAME: text -- the search substring given too be found

OUTPUT:
	course_uuid text,
	course_name text
```

### Student Queries

1. search_course
```
INPUT
	CNAME text, 			--course id
	TC int 					--term_code

OUTPUT
	course_offering_uuid text,
	section_number int,
	course_name text,
	course_limit int,
	instructors text,
	department_data text,
	facility_code_id text,
	room_code_id text,
	start_time_val int ,
	end_time_val int ,
	m boolean , 			--class on monday or not
	t boolean , 			--class on tuesday or not. Similarly for others
	w boolean ,
	th boolean ,
	f boolean ,
	sa boolean ,
	su boolean  
```
2. past_course_stats
```
INPUT
	CNAME text 			--string input corresponding to user query

OUTPUT
	course_name text,
	a_percent numeric(10,2),
	ab_percent numeric(10,2),
	b_percent numeric(10,2),
	bc_percent numeric(10,2),
	c_percent numeric(10,2),
	d_percent numeric(10,2),
	f_percent numeric(10,2),
	s_percent numeric(10,2),
	u_percent numeric(10,2),
	cr_percent numeric(10,2),
	n_percent numeric(10,2),
	p_percent numeric(10,2),
	i_percent numeric(10,2),
	nw_percent numeric(10,2),
	nr_percent numeric(10,2),
	other_percent numeric(10,2)
```

3. add_course
```
--adding a course. DOES NOT CHECK IF REQUEST IS REJECTED OR NOT. LEFT FOR THE FRONTEND TO DO
--returns 1 when registered, 0 when gone to pending, -1 when already registered (in any 1 section ), 2 when the course clashes with schedule of another course the student is in

INPUT
	student_id bigint,
	SECN int,
	COID text

OUTPUT
	int status 
```

4. drop_course
```
INPUT: 
	SID bigint, --student id
	COID text	--course offering id

OUTPUT
	VOID
```

5. get_daily_schedule
```
INPUT
	SID bigint --student id
OUTPUT
	course_name text,
	section_number int,
	facility_code text,
	room_code text,
	start_time int ,
	end_time int ,
	m boolean , 		--class on monday or not
	t boolean ,			--class on tuesday or not. Similarly for others
	w boolean ,
	th boolean ,
	f boolean ,
	sa boolean ,
	su boolean
```

### Admin Queries

1. start_addDrop
```
INPUT
	tc int --term code
OUTPUT
	VOID
```
2. end_addDrop
```
INPUT
	tc int --term code
OUTPUT
	VOID
```
3. is_addDrop_on
```
INPUT
	tc int --term code
OUTPUT
	boolean
```
4. addNewCourse
```
INPUT
	code text, --a small code from which the uuid is generated
	name text
OUTPUT
	void
```
5. addNewStudent
```
INPUT
	id bigint,
	name text
OUTPUT
	void
```
6. start_term
```
INPUT
	tc int --term code
OUTPUT
	VOID
```


