create table courses(
	uuid text not null,
	name text,
	num int,
	constraint courses_key primary key (uuid)
	);
create table term_code(
	code int not null,
	year int not null,
	term text not null,
	constraint term_code_key primary key (code)
	);
create table course_offerings(
	uuid text not null,
	course_uuid text not null,
	term_code int not null,
	name text ,

	constraint course_offerings_key primary key (uuid),
	constraint course_uuid_ref foreign key (course_uuid) references courses(uuid),
	constraint term_code_ref foreign key (term_code) references term_code(code)
	);
create table instructors(
	id bigint not null,
	name text,
	constraint instructors_key primary key (id)
	);
create table rooms(
	uuid text not null,
	facility_code text,
	room_code text,
	constraint rooms_key primary key (uuid)
	);
create table schedules(
	uuid text not null,
	start_time int not null,
	end_time int not null,
	mon boolean not null,
	tues boolean not null,
	wed boolean not null,
	thurs boolean not null,
	fri boolean not null,
	sat boolean not null,
	sun boolean not null,
	constraint schedules_key primary key (uuid)
	);
create table sections(
	uuid text not null,
	course_offering_uuid text not null,
	section_type text,
	num int,
	room_uuid text,
	schedule_uuid text,
	reg_limit int,
	constraint sections_key primary key (uuid),
	constraint course_offering_uuid_ref foreign key (course_offering_uuid) references course_offerings(uuid),
	constraint schedule_uuid_ref foreign key (schedule_uuid) references schedules(uuid)
	);
create table grade_distributions(
	course_offering_uuid text not null,
	section_number int,
	a_count int,
	ab_count int,
	b_count int,
	bc_count int,
	c_count int,
	d_count int,
	f_count int,
	s_count int,
	u_count int,
	cr_count int,
	n_count int,
	p_count int,
	i_count int,
	nw_count int,
	nr_count int,
	other_count int,
	constraint grade_distributions_key primary key (course_offering_uuid,section_number),
	constraint course_offering_uuid_ref foreign key (course_offering_uuid) references course_offerings(uuid)
	);
create table subjects(
	code text not null,
	name text not null,
	abbreviation text not null,
	constraint subjects_key primary key (code)
	);
create table subject_memberships(
	subject_code text not null,
	course_offering_uuid text not null,
	constraint subject_memberships_key primary key (subject_code,course_offering_uuid),
	constraint subject_code_ref foreign key (subject_code) references subjects(code),
	constraint course_offering_uuid_ref foreign key (course_offering_uuid) references course_offerings(uuid)
	);
create table teachings(
	instructor_id bigint not null,
	section_uuid text not null,
	constraint teachings_key primary key (instructor_id,section_uuid),
	constraint instructor_id_ref foreign key (instructor_id) references instructors(id),
	constraint section_uuid_ref foreign key (section_uuid) references sections(uuid)
	);
create table students(
	id bigint primary key,
	name text
);
create table pending_requests(
	course_offering text not null,
	section_number int,
	student_id bigint not null,
	constraint pending_requests_key primary key (course_offering,student_id),
	constraint course_offering_ref foreign key (course_offering) references course_offerings(uuid),
	constraint student_id_ref foreign key (student_id) references students(id)
	);
create table rejected_requests(
	course_offering text not null,
	student_id bigint not null,
	constraint rejected_requests_key primary key (course_offering,student_id),
	constraint course_offering_ref foreign key (course_offering) references course_offerings(uuid),
	constraint student_id_ref foreign key (student_id) references students(id)
	);
create table course_registrations(
	course_offering text not null,
	section_number int,
	student_id bigint not null,
	constraint course_registrations_key primary key (course_offering,student_id),
	constraint course_offering_ref foreign key (course_offering) references course_offerings(uuid),
	constraint student_id_ref foreign key (student_id) references students(id)
	);
create table addDrop(
	term_code int not null,
	constraint addDrop_key primary key (term_code),
	constraint term_code_ref foreign key (term_code) references term_code(code)
	);
\copy courses from 'database/courses.csv' delimiter ',' csv header;
\copy term_code from 'database/term_code.csv' delimiter ',' csv header;
\copy course_offerings from 'database/course_offerings.csv' delimiter ',' csv header;
\copy grade_distributions from 'database/grade_distributions.csv' delimiter ',' csv header;
\copy instructors from 'database/instructors.csv' delimiter ',' csv header;
\copy rooms from 'database/rooms.csv' delimiter ',' csv header;
\copy schedules from 'database/schedules.csv' delimiter ',' csv header;
\copy sections from 'database/sections_with_limit.csv' delimiter ',' csv header;
\copy subjects from 'database/subjects.csv' delimiter ',' csv header;
\copy subject_memberships from 'database/subject_memberships.csv' delimiter ',' csv header;
\copy teachings from 'database/teachings.csv' delimiter ',' csv header;
