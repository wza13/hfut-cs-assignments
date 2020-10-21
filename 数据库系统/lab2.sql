/*
USE EDUC;

CREATE TABLE class (
	clsNO CHAR(6) PRIMARY KEY,
	clsName VARCHAR(16) NOT NULL,
	Director VARCHAR(10),
	Specialty VARCHAR(30)
);

CREATE TABLE student (
	sno CHAR(8) PRIMARY KEY,
	sname VARCHAR(10) NOT NULL,
	ssex CHAR(2) CHECK(ssex in ('男', '女')),
	clsNO CHAR(6) FOREIGN KEY REFERENCES class(clsNO),
	saddr VARCHAR(20),
	--sage TINYINT CHECK(sage between 10 and 30),
	sage DECIMAL(3, 0) CHECK(sage between 10 and 30),
	height DECIMAL(4, 2)
	--DECIMAL(M, D)，其中M称为精度，表示总共的位数；D称为标度，表示小数的位数
);

CREATE TABLE course (
	cno CHAR(4) PRIMARY KEY,
	cname VARCHAR(16) NOT NULL,
	cpno CHAR(4) FOREIGN KEY REFERENCES course(cno), --先修课程
	credit DECIMAL(2, 1)
);

CREATE TABLE sc (
	sno CHAR(8) FOREIGN KEY REFERENCES student(sno),
	cno CHAR(4) FOREIGN KEY REFERENCES course(cno),
	grade DECIMAL(3, 1),
	PRIMARY KEY (sno, cno)
);


CREATE TABLE student1 (
	sno CHAR(8) PRIMARY KEY,
	sname VARCHAR(10) NOT NULL,
	ssex CHAR(2) CHECK(ssex in ('男', '女')),
	clsNO CHAR(6) FOREIGN KEY REFERENCES class(clsNO),
	saddr VARCHAR(20),
	--sage TINYINT CHECK(sage between 10 and 30),
	sage DECIMAL(3, 0) CHECK(sage between 10 and 30),
	height DECIMAL(4, 2)
	--DECIMAL(M, D)，其中M称为精度，表示总共的位数；D称为标度，表示小数的位数
);

ALTER TABLE student1 ADD s_entrance DATE;
--ALTER TABLE student1 ALTER COLUMN sage DECIMAL(3, 0) CHECK(sage between 10 and 40);
ALTER TABLE student1 DROP CONSTRAINT CK__student1__sage__33D4B598;
ALTER TABLE student1 ADD CONSTRAINT CK_student_age CHECK(sage between 10 and 40);
ALTER TABLE student1 ALTER COLUMN saddr VARCHAR(40);

DROP TABLE student1;
*/
