#1-add course offering
#input:
/*
course id
term code
section number
limit
room required or not
section type
(room and schedule will be allocated via the registrar not the instructor)
*/
insert into course_offerings values (/*course offering uuid: "new"+termcode+course id*/"",/*course id*/, /*term code*/,/*course name*/)
insert into sections values (/*section uuid: "new"+section no+course offering*/, /* course offering uuid*/, /*section type*/, /*number*/, /*room id*/NULL, /*schedule uuid*/NULL)
insert into teachings values (@INSTRUCTOR,@SECTION_ID)
/*need to add the limit and the room needed somewhere*/
/*-----------------------------------------------------------------------------*/

#2-handling pending requests

/*
input
course offering uuid
student id
accept or reject via variable ACCEPTED
*/
declare @CO text;#course_offerings
declare @ACCEPTED boolean;
declare @SID text;#student id
#get all the pending requests-- a seperate query
select * from pending_requests where course_offerings=@CO;
#accept or reject--a separate query
IF (@ACCEPTED)
	begin
	#add the student to the course. TODO
	end
else
	begin
	#put the student request with reject status
	insert into rejected_requests values (@CO, @SID);
	end
#after this remove student pending request
delete from pending_requests where course_offerings=@CO and student_id=@SID;
/*-----------------------------------------------------------------------------*/
