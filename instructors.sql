#add course offering

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
/*need to add the limit and the room needed somewhere*/