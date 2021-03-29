-- 1 add drp time line
create or replace function start_addDrop(
	tc int)
returns void as $$
begin
insert into addDrop values (tc);
end $$ language plpgsql;

create or replace function end_addDrop(
	tc int)
returns void as $$
begin
delete from addDrop where addDrop.term_code=(tc);
delete from pending_requests;
delete from rejected_requests;
end $$ language plpgsql;

create or replace function is_addDrop_on(
	tc int)
returns boolean as $$
begin
return (select exists (select 1 from addDrop where addDrop.term_code=tc));
end $$ language plpgsql;

--2 schedule and room allocation

-- create or replace function allocate_schedule_room(
-- 	tc int --term code
-- 	)

--3 create new course
create or replace function addNewCourse(
	code text,
	name text)
returns void as $$
begin
insert into courses values ('new2021' || code, name);
end $$ language plpgsql;

