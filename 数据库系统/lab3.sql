USE EDUC;

/*
INSERT INTO Student(sno, sname, ssex, sage, clsNO)
	VALUES ('20171101', 'ÕÅÈý', 'ÄÐ', 19, 'CS01');

SELECT * FROM Student WHERE sno = '20171101';
*/


/*
SELECT * FROM Student WHERE clsNO = 'CS01' OR clsNO = 'CS02';

UPDATE Student
	SET clsNO = 'CS02'
	WHERE sage <= 20 AND clsNO = 'CS01';

SELECT * FROM Student WHERE clsNO = 'CS01' OR clsNO = 'CS02';
*/


/*
SELECT * FROM Student WHERE clsNO = 'CS02';
DELETE FROM Student
	WHERE clsNO = 'CS02' AND sage < 20;
SELECT * FROM Student WHERE clsNO = 'CS02';
*/