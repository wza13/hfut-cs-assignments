USE EDUC;

SELECT COUNT(*) FROM student;

SELECT COUNT(*) FROM (SELECT DISTINCT sno FROM sc) AS sno_dist;

SELECT cno, COUNT(*) FROM sc GROUP BY cno;

SELECT student.sno, sname
	FROM student, 
		(SELECT sno FROM sc
			GROUP BY sno
			HAVING COUNT(cno) > 2) AS new_sc
	WHERE student.sno = new_sc.sno;
