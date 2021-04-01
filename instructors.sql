create materialized view disjoint_schedule as
	select column1  as schedule_uuid from
	(values
			('875542a2-f786-34dd-933b-84a8af1aaaba'),
			('f41f1e4d-cb4f-3ded-b4b0-4a7c4da044e5'),
			('46da55a4-17f7-31a1-9492-fddb5af9cf13'),
			('8c7cd81e-4f81-357c-a40b-43f954484804'),
			('76c82895-6420-3a2c-bb27-5b19b2e07755'),
			('d81c681b-958c-3b19-ace7-9f24939251c2') ) as t;

-- 1-add course offering
create or replace function add_course_offering(
	CID text, 			--course id
	TC int, 			--term code
	SN int,				--section number
	LIM int,			--course reg limit
	ROOM_REQ boolean,	--room required or not
	ST text, 			--section type
	INSTRUCTOR bigint,
	subj_code text		--subject code (dept) that is floating the course.
	)
returns void as $$
DECLARE
	COID text :='new' || (cast (TC as text)) || CID ;	--course offering id
	SECTION_ID text :='new'|| (cast ( SN as text)) || COID;
begin

	insert into course_offerings values (COID, CID, TC,/*course name*/(select courses.name from courses where courses.uuid=CID));

	with t as --find a room and schedule for this course
	(select rooms.uuid as room_uuid, schedule_uuid from rooms, disjoint_schedule except (select room_uuid,schedule_uuid from sections, course_offerings where course_offerings.term_code=1214 and sections.course_offering_uuid=course_offerings.uuid) limit 1)
	insert into sections select SECTION_ID, COID, ST, SN, t.room_uuid /*room id*/, /*schedule uuid*/t.schedule_uuid, LIM from t;
	if(not ROOM_REQ)
	then
		update sections set room_uuid=NULL where sections.uuid=SECTION_ID;
	end if;

	insert into teachings values (INSTRUCTOR,SECTION_ID);
	insert into subject_memberships values (subj_code,COID);


end $$ LANGUAGE plpgsql;

-- start transaction;
-- select  add_course_offering('e9a360bc-be2d-35d1-9684-a464bbbd0c15',1214,1,150,true,'LEC',761703,'266');
-- rollback;
/*-----------------------------------------------------------------------------*/

-- 2-handling pending requests
/*
input
course offering uuid
student id
accept or reject via variable ACCEPTED
*/
create or replace function get_pending_requests(
	CO text,
	SECN int)
	returns table
	(
		student_id bigint
	) as $$
begin

	return query select pending_requests.student_id from pending_requests where pending_requests.course_offering=CO AND pending_requests.section_number=SECN;
end $$ LANGUAGE plpgsql;

-- insert into students values (12345,'Aniket Modi'); --
-- insert into students values (12346,'Aarunish Sinha'); --
-- insert into students values (12347,'Jai Javeria'); --
-- insert into pending_requests values ('new1214e9a360bc-be2d-35d1-9684-a464bbbd0c15',1,12345); --
-- insert into pending_requests values ('new1214e9a360bc-be2d-35d1-9684-a464bbbd0c15',1,12346); --
-- select * from get_pending_requests('new1214e9a360bc-be2d-35d1-9684-a464bbbd0c15',1); --

create or replace function process_pending_request(
	CO text,
	ACCEPTED boolean,
	SECN int,
	SID bigint)
returns void as $$
begin
	IF (ACCEPTED)
	then
		-- #add the student to the course.
		insert into course_registrations values (CO,SECN,SID);
		-- end
	else
		-- #put the student request with reject status
		insert into rejected_requests values (CO, SID);
	end if;
	-- #after this remove student pending request
	delete from pending_requests where pending_requests.course_offering=CO and pending_requests.student_id=SID and pending_requests.section_number=SECN;
end $$ LANGUAGE plpgsql;

-- select process_pending_request('new1214e9a360bc-be2d-35d1-9684-a464bbbd0c15',true,1,12345); --
/*-----------------------------------------------------------------------------*/

-- #3-instructor schedule
-- #assuming the term code would be given to us and schedule for only one term code would be required
/*
input
instructor id
term code
*/
create or replace function get_instructor_schedule(
	INSTRUCTOR bigint,
	TC int
	)
returns table (
	course_offered_name text,
	start_time int,
	end_time int,
	mon boolean,
	tues boolean,
	wed boolean,
	thurs boolean,
	fri boolean,
	sat boolean,
	sun boolean )
	as $$
begin
	return query
	(
		select tIS.course_offered_name,schedules.start_time,schedules.end_time,schedules.mon,schedules.tues,schedules.wed,schedules.thurs,schedules.fri,schedules.sat,schedules.sun from schedules,
		(
			-- #select the schedule ids corresponding to the instructor in that term
			select  tS.course_offered_name, tS.schedule_uuid from
			(--select the sections of the particular instructor
				select teachings.section_uuid from teachings where teachings.instructor_id=INSTRUCTOR
			) as tI,
			(--select the section entries of all the course offering in a given term
				select sections.uuid, tCO.course_offered_name, sections.schedule_uuid from sections,
				(
					-- #select the course offerings of a particular term.
					select course_offerings.uuid, course_offerings.name as course_offered_name from course_offerings where course_offerings.term_code=TC
				) as tCO where sections.course_offering_uuid=tCO.uuid
			) as tS where tI.section_uuid=tS.uuid
		) as tIS where tIS.schedule_uuid=schedules.uuid
	);
end $$ LANGUAGE plpgsql;

-- select * from get_instructor_schedule(761703,1214); --
/*-----------------------------------------------------------------------------*/

-- 4 student list of course offering
create or replace function get_student_list(
	CO text,
	SECN int)
returns table(
	student_id bigint)
	as $$
begin
	return query
	(
		select course_registrations.student_id from course_registrations where course_registrations.course_offering=CO and course_registrations.section_number=SECN
	);
end $$ LANGUAGE plpgsql;

-- select * from get_student_list('new1214e9a360bc-be2d-35d1-9684-a464bbbd0c15',1); --
/*-----------------------------------------------------------------------------*/

--5 grade distribution
create or replace function set_grade_distribution(
	course_offering_uuid text,
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
	other_count int
	)
returns void as $$
begin
-- update table
	delete from grade_distributions where grade_distributions.course_offering_uuid=course_offering_uuid and grade_distributions.section_number=section_number;
	insert into grade_distributions values(
	course_offering_uuid,
	section_number,
	a_count,
	ab_count,
	b_count,
	bc_count,
	c_count,
	d_count,
	f_count,
	s_count,
	u_count,
	cr_count,
	n_count,
	p_count,
	i_count,
	nw_count,
	nr_count,
	other_count
	);
end $$ LANGUAGE plpgsql;


create or replace function get_grade_distribution(
	course_offering_id text,
	section_num int)
returns table(
	course_offering_uuid text,
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
	other_count int
	)	as $$
begin
	return query
	(
		select * from grade_distributions where grade_distributions.course_offering_uuid=course_offering_id and grade_distributions.section_number=section_num
	);
end $$ LANGUAGE plpgsql;

create or replace function get_num_students_reg(
	course_offering_uuid text)
returns int as $$
begin
	-- select reg_limit from course_offerings where course_offerings.course_offering_uuid=course_offering_uuid;
	select count(*) from
	(
		select student_id from course_registrations where course_registrations.course_offering_uuid=course_offering_uuid) as t ;
end $$ LANGUAGE plpgsql;
/*-----------------------------------------------------------------------------*/

--6 get a room
create or replace function get_room_instr(
	course_offering_uuid text,
	section_number int)
returns table(
	facility_code text,
	room_code text) as $$
begin
	select facility_code, room_code from rooms,
	(
		select room_uuid from sections where sections.course_offering_uuid=course_offering_uuid and sections.num=section_number
	) as t1
	where rooms.room_uuid=t1.room_uuid;
end $$ LANGUAGE plpgsql;
/*-----------------------------------------------------------------------------*/
