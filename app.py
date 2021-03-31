from flask import Flask, render_template, send_from_directory, request, redirect, url_for
import os
import nltk
import numpy as np
import pandas as pd


app = Flask(__name__)
# app['debug'] = True

# UPLOAD_FOLDER ='./uploads/'
# app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
# CONFIG_FOLDER ='./config/'
# app.config['CONFIG_FOLDER'] = CONFIG_FOLDER
# PDF_FOLDER ='./pdfs/'
# app.config['PDF_FOLDER'] = PDF_FOLDER
# app.config['TMP'] = './tmp/'
currentStudentLoginId = ""  # the student who is currently logged in
currentProfLoginId = ""     # # the instructor who is currently logged in

@app.route("/")  #main webpage rendering
def main():
    return render_template("HomeScreen.html") #the main form

@app.route("/instructorScreen", methods = ["POST"])
def inst():
    currentProfLoginId = request.form.get("ProfID")
    return render_template("instructor.html",AddCourseMsg="", requests = [])

@app.route("/instructorScreen/AddCourse", methods = ["POST"])
def instAC():
    # See what is to be done with AddCourseMsg
    global currentProfLoginId
    CID = request.form.get("CID")
    TC = request.form.get("TC")
    SN = request.form.get("SN")
    LM = request.form.get("LM")
    ST = request.form.get("ST")
    RoomReq = request.form.get("RoomReq")

    # EXECUTE DATABASE QUERY HERE

    return render_template("instructor.html",AddCourseMsg="", requests = [])

@app.route("/instructorScreen/Requests", methods = ["POST"])
def instRequests():
    # See what is to be done with AddCourseMsg
    global currentProfLoginId
    COID = request.form.get("COID")
    requests = [123,1231,13,144]

    # requests = EXECUTE DATABASE QUERY HERE

    return render_template("instructor.html",AddCourseMsg="", requests = requests)

@app.route("/instructorScreen/ProcessRequests", methods = ["POST"])
def instProcessRequests():
    # See what is to be done with AddCourseMsg
    global currentProfLoginId
    COID = request.form.get("COID")
    requests = []

    # requests = EXECUTE DATABASE QUERY HERE

    return render_template("instructor.html",AddCourseMsg="", requests = [])



if __name__ == '__main__':
    app.run()
