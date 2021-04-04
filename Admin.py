from flask import Blueprint, Flask, render_template, send_from_directory, request, redirect, url_for
import os
import psycopg2

# conn = psycopg2.connect('dbname=postgres')
conn = psycopg2.connect('dbname=group_13 user=group_13 password=p0XvR8Ch4BAGb host=10.17.50.232 port=5432')

cur = conn.cursor()

app = Flask(__name__)

adminRoutes = Blueprint('adminRoutes',__name__,template_folder='templates',
    static_folder='static')
TC = ""

@adminRoutes.route("/adminScreen", methods = ["POST"])
def adminMain():
    return render_template("Admin.html", StartMsg = "", endMsg="", checkMsg = "", addMsg = "", addStudentMsg = "", startTermMsg="")


@adminRoutes.route("/adminScreen/startAddDrop", methods = ["POST"])
def adminStartAddDrop():
    global TC
    TC = request.form.get("TC")
    startMsg = "Add Drop Started"

    # startMsg = EXECUTE QUERY HERE
    try:
        query="""
        BEGIN;
        SELECT start_addDrop(%s);
        COMMIT;
        """ % (str(TC))
        cur.execute(query)
        startMsg="Add/Drop Period started for Term" + str(TC)
    except Exception as e:
        print (e)
        cur.execute("ROLLBACK;")

    return render_template("Admin.html",startMsg = startMsg, endMsg="", checkMsg = "", addMsg = "", addStudentMsg = "", startTermMsg="")


@adminRoutes.route("/adminScreen/endAddDrop", methods = ["POST"])
def adminEndAddDrop():
    # TC = request.form.get("TC")
    global TC
    endMsg = "Add Drop Ended"

    # endMsg = EXECUTE QUERY HERE
    try:
        query="""
        BEGIN;
        SELECT end_addDrop(%s);
        COMMIT;
        """ % (str(TC))
        cur.execute(query)
        endMsg="Add/Drop Period ended for Term" + str(TC)
    except Exception as e:
        print (e)
        cur.execute("ROLLBACK;")

    return render_template("Admin.html",startMsg = "", endMsg=endMsg, checkMsg = "", addMsg = "", addStudentMsg = "", startTermMsg="")


@adminRoutes.route("/adminScreen/isAddDropOn", methods = ["POST"])
def adminIsAddDropOn():
    TC = request.form.get("TC")
    checkMsg = "default"

    # checkMsg = EXECUTE QUERY HERE
    try:
        query="""
        BEGIN;
        SELECT * from is_addDrop_on(%s);
        """ % (str(TC))
        cur.execute(query)
        is_it=cur.fetchall()
        cur.execute("COMMIT;")
        is_it = is_it[0][0]
        if is_it==True:
            checkMsg="Add/Drop is ON"
        else:
            checkMsg="Add/Drop is OFF"
    except Exception as e:
        print (e)
        cur.execute("ROLLBACK;")


    return render_template("Admin.html",startMsg = "", endMsg="", checkMsg = checkMsg, addMsg = "", addStudentMsg = "", startTermMsg="")


@adminRoutes.route("/adminScreen/addNewCourse", methods = ["POST"])
def adminaddCourse():
    CID = request.form.get("CID") # course id
    CN = request.form.get("CN") # course name
    addMsg = "default"

    # addMsg = EXECUTE QUERY HERE
    try:
        query="""
        BEGIN;
        SELECT addNewCourse('%s','%s');
        COMMIT;
        """ % (str(CID),str(CN))
        cur.execute(query)
        addMsg="Course added"
    except Exception as e:
        print (e)
        cur.execute("ROLLBACK;")

    return render_template("Admin.html",startMsg = "", endMsg="", checkMsg = "", addMsg = addMsg, addStudentMsg = "", startTermMsg="")


@adminRoutes.route("/adminScreen/addNewStudent", methods = ["POST"])
def adminaddStudent():
    SID = request.form.get("SID")  # student ID
    SN = request.form.get("SN")  # student name
    addStudentMsg = "default"

    # addStudentMsg = EXECUTE QUERY HERE
    try:
        query="""
        BEGIN;
        SELECT addNewStudent(%s,'%s');
        COMMIT;
        """ % (str(SID),str(SN))
        cur.execute(query)
        addStudentMsg="Student Registered"
    except Exception as e:
        print (e)
        cur.execute("ROLLBACK;")

    return render_template("Admin.html",startMsg = "", endMsg="", checkMsg = "", addMsg = "", addStudentMsg = addStudentMsg, startTermMsg="")


@adminRoutes.route("/adminScreen/startTerm", methods = ["POST"])
def adminStartTerm():
    TC = request.form.get("TC")
    termMsg = "default"
    # EXECUTE QUERY HERE
    try:
        query="""
        BEGIN;
        SELECT start_term(%s);
        COMMIT;
        """ % (str(TC))
        cur.execute(query)
        termMsg="Term Started"
    except Exception as e:
        print (e)
        termMsg = "Error Starting the Term"
        cur.execute("ROLLBACK;")
    # termMsg = "Error Starting the Term"  -- add under exception block

    return render_template("Admin.html", StartMsg = "", endMsg="", checkMsg = "", addMsg = "", addStudentMsg = "", startTermMsg=termMsg)
