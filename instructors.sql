-- 1-add course offering
-- input:
/*
course id
term code
section number
limit
room required or not
section type
instructor
(room and schedule will be allocated via the registrar not the instructor)
*/
-- start transaction;
-- drop  FUNCTION add_course_offering(text,integer,integer,integer,boolean,text,bigint);
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

	insert into course_offerings values (COID, CID, TC,/*course name*/(select courses.name from courses where courses.uuid=CID));
	insert into sections values (SECTION_ID, COID, ST, SN, /*room id*/NULL, /*schedule uuid*/NULL);
	insert into teachings values (INSTRUCTOR,SECTION_ID);

	/*need to add the limit and the room needed somewhere*/
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

-- declare CO text;#course_offerings
-- declare ACCEPTED boolean;
-- declare SID text;#student id
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
-- /*
-- input
-- instructor id
-- term code
-- */
-- declare INSTRUCTOR bigint;
-- declare TERM_CODE int;
-- select * from schedules,
-- (
-- 	#select the schedule ids corresponding to the instructor in that term
-- 	select  course_offered_name, schedule_uuid from 
-- 	(#select the sections of the particular instructor
-- 		select section_uuid from teachings where instructor_id=INSTRUCTOR
-- 	) as tI,
-- 	(#select the section entries of all the course offering in a given term
-- 		select sections.uuid, course_offered_name, schedule_uuid from sections, 
-- 		(
-- 			#select the course offerings of a particular term.
-- 			select uuid, name as course_offered_name from course_offerings where course_offerings.term_code=TERM_CODE 
-- 		) as tCO where sections.course_offering_uuid=tCO.uuid
-- 	) as tS where tI.section_uuid=tS.uuid
-- ) as tIS where tIS.schedule_uuid=schedules.uuid
-- /*-----------------------------------------------------------------------------*/
