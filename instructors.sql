-- 1-add course offering
create or replace function add_course_offering(
	CID text, 			--course id
	TC int, 			--term code
	SN int,				--section number
	LIM int,			--course reg limit
	ROOM_REQ boolean,	--room required or not
	ST text, 			--section type
	INSTRUCTOR bigint
	) 
returns void as $$
DECLARE 
	COID text :='new' || (cast (TC as text)) || CID ;	--course offering id
	SECTION_ID text :='new'|| (cast ( SN as text)) || COID;
begin

	insert into course_offerings values (COID, CID, TC,/*course name*/(select courses.name from courses where courses.uuid=CID), LIM, ROOM_REQ);
	insert into sections values (SECTION_ID, COID, ST, SN, /*room id*/NULL, /*schedule uuid*/NULL);
	insert into teachings values (INSTRUCTOR,SECTION_ID);

end $$ LANGUAGE plpgsql;

start transaction;
select  add_course_offering('e9a360bc-be2d-35d1-9684-a464bbbd0c15',1214,1,150,true,null,761703);
rollback;
/*-----------------------------------------------------------------------------*/

-- 2-handling pending requests
/*
input
course offering uuid
student id
accept or reject via variable ACCEPTED
*/
create or replace function get_pending_requests(
	CO text) 
	returns table
	(
		course_offering text, 
		student_id bigint
	) as $$
begin

	return query select * from pending_requests where course_offering=CO;
end $$ LANGUAGE plpgsql;

create or replace function process_pending_request(
	CO text,
	ACCEPTED boolean,
	SID text)
returns void as $$	
begin
	IF (ACCEPTED)
	then
		-- #add the student to the course.
		insert into course_registrations values (CO,SID);
		-- end
	else
		-- #put the student request with reject status
		insert into rejected_requests values (CO, SID);
	end if;
	-- #after this remove student pending request
	delete from pending_requests where course_offering=CO and student_id=SID;
end $$ LANGUAGE plpgsql;
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
	TERM_CODE int
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
		select course_offered_name,start_time,end_time,mon,tues,wed,thurs,fri,sat,sun from schedules,
		(
			-- #select the schedule ids corresponding to the instructor in that term
			select  course_offered_name, schedule_uuid from 
			(--select the sections of the particular instructor
				select section_uuid from teachings where instructor_id=INSTRUCTOR
			) as tI,
			(--select the section entries of all the course offering in a given term
				select sections.uuid, course_offered_name, schedule_uuid from sections, 
				(
					-- #select the course offerings of a particular term.
					select uuid, name as course_offered_name from course_offerings where course_offerings.term_code=TERM_CODE 
				) as tCO where sections.course_offering_uuid=tCO.uuid
			) as tS where tI.section_uuid=tS.uuid
		) as tIS where tIS.schedule_uuid=schedules.uuid
	);
end $$ LANGUAGE plpgsql;
/*-----------------------------------------------------------------------------*/

-- 4 student list of course offering
create or replace function get_student_list(
	course_offering text)
returns table(
	student_id bigint)
	as $$
begin
	return query
	(
		select student_id from course_registrations where course_registrations.course_offering=course_offering
	);
end $$ LANGUAGE plpgsql;
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
