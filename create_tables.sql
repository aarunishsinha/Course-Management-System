#1-4
#2
create table courses(
	uuid text not null,
	name text,
	num int, 
	constraint courses_key primary key (uuid)
	);
#1
create table course_offerings(
	uuid text not null,
	course_uuid text not null,
	term_code int not null,
	name text ,
	constraint course_offerings_key primary key (uuid),
	constraint course_uuid_ref foreign key (course_uuid) references courses(uuid),
	constraint term_code_ref foreign key (term_code) references term_code(term_code)
	);
#3
create table grade_distribution(
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
	constraint grade_distribution_key primary key (course_offering_uuid, section_number),
	constraint course_offering_uuid_ref foreign key (course_offering_uuid) references course_offerings(uuid)	
	#need to update
	constraint section_number_ref foreign key (section_number) references sections(num)	#7d
	);
#4
create table instructors(
	id bigint not null,
	name text,
	constraint instructors_key primary key (id)
	);
#5-8
#5
create table rooms(
	uuid text not null,
	facility_code text,
	room_code text,
	constraint rooms_key primary key (uuid)
	);
#6
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
#7
create table sections(
	uuid text not null,
	course_offering_uuid text not null,
	section_type text,
	num int,
	room_uuid text,
	schedule_uuid text,
	constraint sections_key primary key (uuid),
	constraint course_offering_uuid_ref foreign key (course_offering_uuid) references course_offerings(uuid),
	constraint room_uuid_ref foreign key (room_uuid) references rooms(uuid),
	constraint schedule_uuid_ref foreign key (schedule_uuid) references schedules(uuid)
	);
#9-11
#9
create table subjects(
	code text not null,
	name text not null,
	abbreviation text not null,
	constraint subjects_key primary key (code)
	);
#8
create table subject_memberships(
	subject_code text not null,
	course_offering_uuid text not null,
	constraint subject_code_ref foreign key (subject_code) references subjects(code),
	constraint course_offering_uuid_ref foreign key (course_offering_uuid) references course_offerings(uuid)
	);
#10
create table teachings(
	instructor_id bigint not null,
	section_uuid text not null,
	constraint instructor_id_ref foreign key (instructor_id) references instructors(id),
	constraint section_uuid_ref foreign key (section_uuid) references sections(uuid)
	);
#11
create table term_code(
	code int not null,
	year int not null,
	term text not null,
	constraint term_code_key primary key (code)
	);