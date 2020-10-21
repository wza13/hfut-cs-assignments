/*
CREATE PROCEDURE p_stu_info1 AS
	SELECT * FROM student WHERE sage < 21
*/

/*
CREATE PROCEDURE p_stu_info2(@sno char(8)) AS
	SELECT * FROM student 
		WHERE sage IN (SELECT sage FROM student WHERE sno=@sno)
*/

/*
CREATE PROCEDURE p_stu_info3(@sno char(8)) AS
	SELECT * FROM student WHERE sno = @sno
*/

/*
CREATE PROCEDURE p_stu_grade(@sno char(8)) AS
	SELECT * FROM sc WHERE sno = @sno
*/

exec p_stu_info1;
exec p_stu_info2 '20170101';
exec p_stu_info3 '20170101';
exec p_stu_grade '20170101';
