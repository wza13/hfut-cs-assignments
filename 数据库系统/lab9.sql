/*
ALTER TABLE class
	ADD c_total INT DEFAULT 0;

SELECT * FROM class
*/

/*
UPDATE class SET c_total = 0;
*/

/*
CREATE TRIGGER t_inst_stu 
ON student
FOR INSERT AS
BEGIN
	DECLARE @clsNO CHAR(6);
	SELECT @clsNO = clsNO FROM inserted
	IF (@clsNO IS NOT NULL)
	--BEGIN
		--PRINT 'INSERT ´¥·¢Æ÷'
		UPDATE class SET c_total = c_total+1 WHERE clsNO=@clsNO;
	--END
END
*/

/*
CREATE TRIGGER t_dele_stu
ON student
FOR DELETE AS
BEGIN
	DECLARE @clsNO CHAR(6);
	SELECT @clsNO = clsNO FROM deleted
	IF (@clsNO IS NOT NULL)
		UPDATE class SET c_total = c_total-1 WHERE clsNO=@clsNO;
END
*/

/*
CREATE TRIGGER t_dele_stu
ON student
FOR DELETE AS
BEGIN
	DECLARE @clsNO CHAR(6);
	SELECT @clsNO = clsNO FROM deleted
	IF (@clsNO IS NOT NULL)
		UPDATE class SET c_total = c_total-1 WHERE clsNO=@clsNO;
END
*/

/*
CREATE TRIGGER t_update_stu
ON student
FOR UPDATE AS
BEGIN
	DECLARE @clsNO CHAR(6);
	SELECT @clsNO = clsNO FROM deleted
	IF (@clsNO IS NOT NULL)
		UPDATE class SET c_total = c_total-1 WHERE clsNO=@clsNO;
	SELECT @clsNO = clsNO FROM inserted
	IF (@clsNO IS NOT NULL)
		UPDATE class SET c_total = c_total+1 WHERE clsNO=@clsNO;
END
*/

/*
SELECT * FROM class;
INSERT INTO student(sno, sname, clsNO, ssex)
	VALUES ('20180001', 'Óàè÷¿¡', 'CS01', 'ÄÐ');
SELECT * FROM class

SELECT * FROM class;
UPDATE student
	SET clsNO = 'CS02'
	WHERE sno = '20180001';
SELECT * FROM class;

SELECT * FROM class;
DELETE student
	WHERE sno = '20180001';
SELECT * FROM class;
*/