from flask import Blueprint, render_template

studentRoutes = Blueprint('studentRoutes',__name__)
studentID = ""

@studentRoutes.route("/studentScreen", methods = ["POST"])
def inst():
    global studentID
    studentID = request.form.get("StudentID")
    schedule = []

    # schedule = EXECUTE QUERY 6 HERE. Following order from slides

    return render_template(student.html, studentID = studentID, schedule = schedule)
