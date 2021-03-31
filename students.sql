with t as (select course_offering_uuid, section_number, (COALESCE(gd.a_count,0) + COALESCE(gd.ab_count,0) + COALESCE(gd.b_count,0) + COALESCE(gd.bc_count,0) + COALESCE(gd.c_count,0) + COALESCE(gd.d_count,0) + COALESCE(gd.f_count,0) + COALESCE(gd.s_count,0) + COALESCE(gd.u_count,0) + COALESCE(gd.cr_count,0) + COALESCE(gd.n_count,0) + COALESCE(gd.p_count,0) + COALESCE(gd.i_count,0) + COALESCE(gd.nw_count,0) + COALESCE(gd.nr_count,0) + COALESCE(gd.other_count)) as lim from grade_distributions as gd)
 update sections set reg_limit= lim  from t where sections.course_offering_uuid=t.course_offering_uuid and sections.num=t.section_number;


-- CREATE MATERIALIZED VIEW course_limits AS
-- SELECT c.uuid as course_uuid,
-- 		c.name as course_name,
-- 		c.num as course_number,
-- 		(MAX(COALESCE(gd.a_count,0) + COALESCE(gd.ab_count,0) + COALESCE(gd.b_count,0) + COALESCE(gd.bc_count,0) + COALESCE(gd.c_count,0) + COALESCE(gd.d_count,0) + COALESCE(gd.f_count,0) + COALESCE(gd.s_count,0) + COALESCE(gd.u_count,0) + COALESCE(gd.cr_count,0) + COALESCE(gd.n_count,0) + COALESCE(gd.p_count,0) + COALESCE(gd.i_count,0) + COALESCE(gd.nw_count,0) + COALESCE(gd.nr_count,0) + COALESCE(gd.other_count))) as course_limit,
-- 		co.term_code as course_offering_term,
-- 		gd.section_number as section_number
-- FROM ((grade_distributions gd 
-- 	join course_offerings co on (gd.course_offering_uuid=co.uuid))
-- 	join courses c on (co.course_uuid=c.uuid))
-- GROUP BY (co.uuid,gd.section_number,c.uuid,c.name,c.num,co.term_code)
-- ORDER BY c.num;

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
SELECT co.uuid as course_offering_uuid
FROM (course_offerings co
	join sections)

--1-SearchCourse--
create or replace function search_course(
	CNAME text, 			--course id
	TC int 				--term_code
	) 
returns table (
	course_number int,
	course_name text,
	course_limit int,
	instructors text,
	section_number int,
	department_data text,
	course_offering_uuid text) 
	as $$
DECLARE 
	CNAME text :=CNAME || '%' ;
begin
	return query
	(SELECT g.course_number as course_number,g.course_name as course_name,g.course_limit as course_limit,g.instructors as instructors,g.section_number as section_number,concat_ws('-',subjects.code,subjects.abbreviation) as department_data,g.course_offering_uuid as course_offering_uuid FROM (SELECT f.course_number,f.course_name,f.course_limit,string_agg(t.instructor_name::text, ',') as instructors,f.section_number,t.course_offering_uuid FROM (SELECT * FROM course_limits WHERE course_limits.course_offering_term=TC)f,(SELECT * FROM instructor_course WHERE instructor_course.course_offering_term=TC)t WHERE t.course_uuid=f.course_uuid and t.course_offering_term=f.course_offering_term and f.section_number=t.section_number
	GROUP BY f.course_uuid,f.section_number,f.course_name,f.course_limit,f.course_number,t.course_offering_uuid)g,subjects,subject_memberships WHERE g.course_name ilike CNAME AND subject_memberships.course_offering_uuid=g.course_offering_uuid AND subjects.code=subject_memberships.subject_code ORDER BY g.course_number,g.section_number
	);
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