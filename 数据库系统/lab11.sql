/* log in with yzj
SELECT * FROM student;
*/

/*
CREATE ROLE 崔平;
CREATE ROLE 崔小平;
GRANT UPDATE(sno), SELECT ON student to 崔平;
DROP ROLE 崔小平;
*/

/*
EXEC sp_addrolemember @rolename='崔平',@membername='yzj'
*/

/* log in with yzj
SELECT * FROM student;
*/
