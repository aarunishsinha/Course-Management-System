--query to set the register limit from grade distribution. already done
-- with t as 
-- (select course_offering_uuid, section_number, (COALESCE(gd.a_count,0) + COALESCE(gd.ab_count,0) + COALESCE(gd.b_count,0) + COALESCE(gd.bc_count,0) + COALESCE(gd.c_count,0) + COALESCE(gd.d_count,0) + COALESCE(gd.f_count,0) + COALESCE(gd.s_count,0) + COALESCE(gd.u_count,0) + COALESCE(gd.cr_count,0) + COALESCE(gd.n_count,0) + COALESCE(gd.p_count,0) + COALESCE(gd.i_count,0) + COALESCE(gd.nw_count,0) + COALESCE(gd.nr_count,0) + COALESCE(gd.other_count)) as lim from grade_distributions as gd)
--  update sections set reg_limit= lim  from t where sections.course_offering_uuid=t.course_offering_uuid and sections.num=t.section_number;

CREATE MATERIALIZED VIEW instructor_course AS
SELECT i.id as instructor_id,
		i.name as instructor_name,
		c.name as course_name,
		c.uuid as course_uuid,
		co.uuid as course_offering_uuid,
		co.term_code as course_offering_term,
		s.num as section_number
FROM ((((instructors i 
	join teachings t on (i.id=t.instructor_id))
	join sections s on (t.section_uuid=s.uuid))
	join course_offerings co on (s.course_offering_uuid=co.uuid))
	join courses c on (co.course_uuid=c.uuid));

CREATE MATERIALIZED VIEW schedule_room AS
	SELECT distinct course_offering_uuid, 
	sections.num as section_number, 
	facility_code,room_code,--room data
	start_time,end_time,mon,tues,wed,thurs,fri,sat,sun --schedule data
	FROM sections, schedules, rooms 
	where
	-- join constraints on rooms
	sections.room_uuid=rooms.uuid
	--join constraints on schedule
	and sections.schedule_uuid=schedules.uuid;

--1-SearchCourse--
create or replace function search_course(
	CNAME text, 			--course id
	TC int 				--term_code
	) 
returns table (
	course_offering_uuid text,
	section_number int,
	course_name text,
	course_limit int,
	instructors text,
	department_data text,
	facility_code text,
	room_code text,
	start_time int ,
	end_time int ,
	mon boolean ,
	tues boolean ,
	wed boolean ,
	thurs boolean ,
	fri boolean ,
	sat boolean ,
	sun boolean ) 
	as $$
DECLARE 
	CNAME text :=CNAME || '%' ;
begin
	return query
	
	(
		SELECT course_offering_uuid, t1.section_number, course_name, reg_limit as course_limit, instructors, 
		concat_ws('-',subjects.code,subjects.abbreviation) as department_data, 
		facility_code,room_code,--room data
		start_time,end_time,mon,tues,wed,thurs,fri,sat,sun --schedule data
		from
	 	(
	 		SELECT string_agg(t.instructor_name::text, ',') as instructors, course_name, course_offering_uuid, section_number 
	 		from instructor_course where instructor_course.course_name ilike CNAME and instructor_course.course_offering_term=TC
	 		GROUP by course_name, course_offering_uuid, section_number
	 		
	 	) as t1,
	 	sections, subject_memberships, schedule_room
	 	--join constraints on sections
	 	where t1.section_number=sections.num and t1.course_offering_uuid=sections.course_offering_uuid 
	 	--join constraints on subject_memberships
	 	and t1.course_offering_uuid=subject_memberships.course_offering_uuid
	 	--join constraints on schedule_room
	 	and sections.course_offering_uuid=schedule_room.course_offering_uuid and sections.num=schedule_room.section_number
	) ;
end $$ LANGUAGE plpgsql;

--EXAMPLE--
-- select * from search_course('Freshman',1082); --


--5-PastCourseStats--
create or replace function past_course_stats(
	CNAME text 			--course id
	) 
returns table (
	course_name text,
	course_limit int,
	a_count numeric(10,2),
	ab_count numeric(10,2),
	b_count numeric(10,2),
	bc_count numeric(10,2),
	c_count numeric(10,2),
	d_count numeric(10,2),
	f_count numeric(10,2),
	s_count numeric(10,2),
	u_count numeric(10,2),
	cr_count numeric(10,2),
	n_count numeric(10,2),
	p_count numeric(10,2),
	i_count numeric(10,2),
	nw_count numeric(10,2),
	nr_count numeric(10,2),
	other_count numeric(10,2)) 
	as $$
DECLARE 
	CNAME text :=CNAME || '%' ;	
begin
	return query
	(SELECT t.course_name as course_name,MAX(t.course_limit) as course_limit,AVG(grade_distributions.a_count)::numeric(10,2) as a_count,AVG(grade_distributions.ab_count)::numeric(10,2) as ab_count,AVG(grade_distributions.b_count)::numeric(10,2) as b_count,AVG(grade_distributions.bc_count)::numeric(10,2) as bc_count,AVG(grade_distributions.c_count)::numeric(10,2) as c_count,AVG(grade_distributions.d_count)::numeric(10,2) as d_count,AVG(grade_distributions.f_count)::numeric(10,2) as f_count,AVG(grade_distributions.s_count)::numeric(10,2) as s_count,AVG(grade_distributions.u_count)::numeric(10,2) as u_count,AVG(grade_distributions.cr_count)::numeric(10,2) as cr_count,AVG(grade_distributions.n_count)::numeric(10,2) as n_count,AVG(grade_distributions.p_count)::numeric(10,2) as p_count,AVG(grade_distributions.i_count)::numeric(10,2) as i_count,AVG(grade_distributions.nw_count)::numeric(10,2) as nw_count,AVG(grade_distributions.nr_count)::numeric(10,2) as nr_count,AVG(grade_distributions.other_count)::numeric(10,2) as other_count FROM (SELECT course_uuid,course_limits.course_name,course_offering_term,course_limits.course_limit from course_limits where course_limits.course_name ilike CNAME)t,course_offerings,grade_distributions WHERE t.course_uuid=course_offerings.course_uuid AND t.course_offering_term=course_offerings.term_code AND course_offerings.uuid=grade_distributions.course_offering_uuid GROUP BY t.course_uuid,t.course_name
	);
end $$ LANGUAGE plpgsql;

--EXAMPLE--
-- select * FROM past_course_stats('Freshman'); --
