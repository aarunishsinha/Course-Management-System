from flask import Blueprint, render_template

studentRoutes = Blueprint('studentRoutes',__name__)
studentID = ""

@studentRoutes.route("/studentScreen", methods = ["POST"])
def std():
    global studentID
    studentID = request.form.get("StudentID")
    schedule = []

    # schedule = EXECUTE QUERY 6 HERE. Following order from slides

    return render_template(student.html, studentID = studentID, schedule = schedule)

@studentRoutes.route("/studentScreen/dropCourse", methods = ["POST"])
def stdDropCourse():
    global studentID
    schedule = []
    CN = request.form.get("CN")
    COID = request.form.get("COID")
    Days = request.form.get("Days")
    STime = request.form.get("STime")
    ETime = request.form.get("ETime")
    Room = request.form.get("Room")
    ST = request.form.get("ST")

    # drop the course EXECUTE QUERY 3 here
    # schedule = UPDATE Schedule. EXECUTE QUERY 6 HERE. Following order from slides

    return render_template(student.html, studentID = studentID, schedule = schedule)
