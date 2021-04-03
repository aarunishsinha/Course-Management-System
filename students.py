from flask import Blueprint, Flask, render_template, send_from_directory, request, redirect, url_for
import os
import psycopg2

conn = psycopg2.connect('dbname=postgres')

cur = conn.cursor()

app = Flask(__name__)


studentRoutes = Blueprint('studentRoutes',__name__,template_folder='templates',static_folder='static')
studentID = ""
schedule = [("aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo"),("aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo"),("aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo")]

@studentRoutes.route("/studentScreen", methods = ["POST"])
def std():
    global studentID
    global schedule
    studentID = request.form.get("StudentID")
    # schedule = EXECUTE QUERY 6 HERE. Following order from slides
    try:
        query="""
        BEGIN;
        SELECT * from get_daily_schedule(%s);
        """ % (str(studentID))
        cur.execute(query)
        schedule=cur.fetchall()
        cur.execute("COMMIT;")
    except Exception as e:
        print (e)

    return render_template("student.html", studentID = studentID, schedule = schedule, pastStats = [], addMsg = "", searchResults = [])

@studentRoutes.route("/studentScreen/searchCourse", methods = ["POST"])
def stdSearchCourse():
    global studentID
    global schedule
    CName = request.form.get("CName")
    TC = request.form.get("TC")
    searchResults = [("aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo"),("aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo"),("aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo","aboo")]

    # searchResults = EXECUTE QUERY 6 HERE. Following order from slides
    try:
        query="""
        BEGIN;
        SELECT * from search_course('%s',%s);
        """ % (str(CName),str(TC))
        cur.execute(query)
        searchResults=cur.fetchall()
        cur.execute("COMMIT;")
    except Exception as e:
        print (e)

    return render_template("student.html", studentID = studentID, schedule = schedule, pastStats = [], addMsg = "", searchResults = searchResults)


@studentRoutes.route("/studentScreen/dropCourse", methods = ["POST"])
def stdDropCourse():
    global studentID
    global schedule

    CN = request.form.get("CN")
    SN = request.form.get("SN")
    FC = request.form.get("FC")
    Room = request.form.get("RC")
    STime = request.form.get("STime")
    ETime = request.form.get("ETime")
    M = request.form.get("M")
    T = request.form.get("T")
    W = request.form.get("W")
    Th = request.form.get("Th")
    F = request.form.get("F")
    Sat = request.form.get("Sat")
    Sun = request.form.get("Sun")
    COID = request.form.get("COID")

    schedule = [(1,1,1,1,1,1,1,1,1,1,1,1,1),(1,1,1,1,1,1,1,1,1,1,1,1,1)]

    # drop the course EXECUTE QUERY 3 here
    try:
        query="""
        BEGIN;
        SELECT * from drop_course(%s,'%s');
        """ % (str(studentID),str(COID))
        cur.execute(query)
        cur.execute("COMMIT;")
    except Exception as e:
        print (e)
    # schedule = UPDATE Schedule. EXECUTE QUERY 6 HERE. Following order from
    try:
        query="""
        BEGIN;
        SELECT * from get_daily_schedule(%s);
        """ % (str(studentID))
        cur.execute(query)
        schedule=cur.fetchall()
        cur.execute("COMMIT;")
    except Exception as e:
        print (e)

    return render_template("student.html", studentID = studentID, schedule = schedule, pastStats = [], addMsg = "", searchResults = [])

@studentRoutes.route("/studentScreen/addCourse", methods = ["POST"])
def stdAddCourse():
    global studentID
    global schedule
    COID = request.form.get("COID")
    CN = request.form.get("CN")
    SN = request.form.get("SN")
    CL = request.form.get("CL")
    Inst = request.form.get("Inst")
    DD = request.form.get("DD")
    FC = request.form.get("FC")
    Room = request.form.get("RC")
    STime = request.form.get("STime")
    ETime = request.form.get("ETime")
    M = request.form.get("M")
    T = request.form.get("T")
    W = request.form.get("W")
    Th = request.form.get("Th")
    F = request.form.get("F")
    Sat = request.form.get("Sat")
    Sun = request.form.get("Sun")
    status = 10
    check_reg = 0
    addMsg="default"
    # status  = EXECUTE QUERY HERE
    try:
        query1="""
        BEGIN;
        SELECT CASE WHEN exists(select * from rejected_requests where course_offering='%s' and student_id=%s) THEN 1 ELSE 0 END as checkRejected;
        """ % (str(COID),str(studentID))
        cur.execute(query1)
        check_=cur.fetchall()
        check_reg=check_[0][0]
        cur.execute("COMMIT;")
    except Exception as e:
        print(e)
    if check_reg==1:
        addMsg="You are not allowed to add this course in the current term"
    else:
        try:
            query2="""
            BEGIN;
            SELECT * from add_course(%s,%s,'%s');
            """ % (str(studentID),str(SN),str(COID))
            cur.execute(query2)
            statu=cur.fetchall()
            status=statu[0][0]
            cur.execute("COMMIT;")
        except Exception as e:
            print(e)
        addMsg = "Invalid Request"
        if status == 1:
            addMsg = "Registered Successfully"
        elif status == 0:
            addMsg = "Registration Limit Exceeded. Request Pending"
        elif status == -1:
            addMsg = "Already Registered"
        elif status == 2:
            addMsg = "Course timings clash with schedule of already taken course"
    try:
        query="""
        BEGIN;
        SELECT * from get_daily_schedule(%s);
        """ % (str(studentID))
        cur.execute(query)
        schedule=cur.fetchall()
        cur.execute("COMMIT;")
    except Exception as e:
        print (e)
    print (addMsg)
    return render_template("student.html", studentID = studentID, schedule = schedule, pastStats = [], addMsg = addMsg, searchResults = [])


@studentRoutes.route("/studentScreen/pastStats", methods = ["POST"])
def stdPastStats():
    global studentID
    global schedule
    CName = request.form.get("CName")
    pastStats = [(0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10)]

    # pastStats = EXECUTE QUERY HERE
    try:
        query="""
        BEGIN;
        SELECT * from past_course_stats('%s');
        """ % (str(CName))
        cur.execute(query)
        pastStats=cur.fetchall()
        cur.execute("COMMIT;")
    except Exception as e:
        print (e)

    return render_template("student.html", studentID = studentID, schedule = schedule, pastStats = pastStats, addMsg = "", searchResults = [])
