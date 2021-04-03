from flask import Blueprint, Flask, render_template, send_from_directory, request, redirect, url_for
import os
import psycopg2

conn = psycopg2.connect('dbname=postgres')

cur = conn.cursor()

app = Flask(__name__)

adminRoutes = Blueprint('adminRoutes',__name__,template_folder='templates',
    static_folder='static')

@adminRoutes.route("/adminScreen", methods = ["POST"])
def adminMain():
    return render_template("Admin.html", StartMsg = "", endMsg="", checkMsg = "", addMsg = "", addStudentMsg = "")


@adminRoutes.route("/adminScreen/startAddDrop", methods = ["POST"])
def adminStartAddDrop():
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
        startMsg="Add/Drop Period started"
    except Exception as e:
        print (e)

    return render_template("Admin.html",startMsg = startMsg, endMsg="", checkMsg = "", addMsg = "", addStudentMsg = "")


@adminRoutes.route("/adminScreen/endAddDrop", methods = ["POST"])
def adminEndAddDrop():
    TC = request.form.get("TC")
    endMsg = "Add Drop Ended"

    # endMsg = EXECUTE QUERY HERE
    try:
        query="""
        BEGIN;
        SELECT end_addDrop(%s);
        COMMIT;
        """ % (str(TC))
        cur.execute(query)
        endMsg="Add/Drop Period ended"
    except Exception as e:
        print (e)

    return render_template("Admin.html",startMsg = "", endMsg=endMsg, checkMsg = "", addMsg = "", addStudentMsg = "")


@adminRoutes.route("/adminScreen/isAddDropOn", methods = ["POST"])
def adminIsAddDropOn():
    TC = request.form.get("TC")
    checkMsg = "Add Drop is not on"

    # checkMsg = EXECUTE QUERY HERE

    return render_template("Admin.html",startMsg = "", endMsg="", checkMsg = checkMsg, addMsg = "", addStudentMsg = "")


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
        addMsg-"Course added"
    except Exception as e:
        print (e)

    return render_template("Admin.html",startMsg = "", endMsg="", checkMsg = "", addMsg = addMsg, addStudentMsg = "")


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
        addMsg-"Student Registered"
    except Exception as e:
        print (e)

    return render_template("Admin.html",startMsg = "", endMsg="", checkMsg = "", addMsg = "", addStudentMsg = addStudentMsg)
