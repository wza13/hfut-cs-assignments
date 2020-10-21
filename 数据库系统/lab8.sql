/*
CREATE VIEW V_SC_G(sno, sname, cno, cname, grade)
	AS SELECT student.sno, sname, course.cno, course.cname, grade
		FROM student, course, sc
		WHERE student.sno = sc.sno
			AND sc.cno = course.cno
*/

/*
CREATE VIEW V_YEAR(sno, birthday)
	AS SELECT sno, YEAR(GETDATE()) - sage FROM student;
*/

/*
CREATE VIEW V_AVG_S_G(sno, course_count, avg_grade)
	AS SELECT sno, COUNT(*), AVG(grade)
		FROM sc
		GROUP BY sno
*/

/*
CREATE VIEW V_AVG_C_G(cno, attendance, avg_grade)
	AS SELECT cno, COUNT(*), AVG(grade)
		FROM sc
		GROUP BY cno
*/


/*
SELECT student.sno, sname, avg_grade FROM student, V_AVG_S_G
	WHERE student.sno = V_AVG_S_G.sno
		AND avg_grade >= 90


SELECT sc.sno, cno, grade, avg_grade FROM sc, V_AVG_S_G
	WHERE sc.sno = V_AVG_S_G.sno
		AND grade > avg_grade


SELECT student.sno, sname FROM student, V_YEAR
	WHERE student.sno = V_YEAR.sno
		AND birthday = 1996
*/