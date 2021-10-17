# Course Management System
A Course Management System for The University of Wisconsin Madison.

Our project can be used by students and instructors to manage their courses. Instructors can add course offerings to which students can register. There is also a third user for the admin/registrar to start a term, start and end the add drop phase, add new students and courses. In addition to these there are a lot of other functionalities we have implemented that we have discussed in the subsequent sections.


## Resources and languages used in the project

[<img alt="Dataset from Kaggle" title="Kaggle Dataset Link" width="70px" src="https://www.kaggle.com/static/images/site-logo.png" />][datasetURL] &nbsp; <img alt="PostgreSQL was used in the backend" title="PostgreSQL as Backend" width="27px" src="https://www.postgresql.org/media/img/about/press/elephant.png" /> &nbsp; <img alt="Flask application framework was used" title="Flask Application Framework" width="40px" src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcms-assets.tutsplus.com%2Fuploads%2Fusers%2F30%2Fposts%2F16037%2Fpreview_image%2Fflask.png&f=1&nofb=1" />

A demostration of our working system is present on google drive: [Demo Video]


## Installation Instructions

- Clone this repository on your local computer.
- Our project uses flask and psycopg2-binary so it needs to download the same before execution. You may use the command below.
```
bash setup_front_end.sh
```
- Below are the configurations for the Postgres Server:
```
dbname=group_13
user=group_13
port=5432
```
Note: You must change the host's IP address in the following files before proceeding any further
1. [app.py](https://github.com/aarunishsinha/Course-Management-System/blob/main/app.py) (Line No. - 12)
2. [students.py](https://github.com/aarunishsinha/Course-Management-System/blob/main/students.py) (Line No. - 5)
3. [Admin.py](https://github.com/aarunishsinha/Course-Management-System/blob/main/Admin.py) (Line No. - 6)
- Download the [data dump](https://drive.google.com/drive/folders/1HDx3uShbgdi1MJdjkv7QZJDr8yh0lLM7?usp=sharing) and upload it on the Postgres server.
- To start the flash server do
```
bash run.sh
```
## Data Source
The data upon which we made the system was majorly taken from Kaggle whose link is provided in the Resource section. This dataset did not have have term code information. This we manually scraped from The University's [Division of Business Services Website]

The following data cleaning was undertaken
- In the sections table of the dataset, null values were actually 'null' i.e. a string. We updated it by changing that to SQL NULL.
- We wanted to simulate the course registration process in our project. For this we came up with a notion of registration limit. For a course offered, students can directly add themselves until the limit is full. After that, a pending request to the instructor is sent and it is accepted or rejected by them. For this we calculated the registration limit of all the course offerings. This was done via the grade_distribution table. This contains the distribution of the number of grades for each course. We calculated the registration limit for a course offering and section via summing all the number of grades given for that. We added this to the section table.
- We added some new tables like pending_requests, rejected_requests, course_registrations, current_term, adddrop  to simulate the course registration/pending/drop process. The dataset did not have a table for students, we added one.

---
[datasetURL]:  https://www.kaggle.com/Madgrades/uw-madison-courses
[Demo Video]: https://drive.google.com/file/d/1mJKFb27aCpLbkgED3ENUNf29iWzZXxPC/view?usp=sharing
[Division of Business Services Website]: https://businessservices.wisc.edu/making-payments/charge-to-a-students-account/term-codes/
