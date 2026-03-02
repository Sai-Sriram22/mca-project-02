USE HospitalDB02;
GO

SELECT
  *
FROM Patients p
WHERE p.IsActive = 1;

--UPDATE patients
--SET Address = 'Dubai'
--WHERE PatientID = '0431562f-333b-4fe0-b7e6-12826fda4a3c'
--AND FullName = 'odsfakjsbdasd,'
--AND IsActive = 1;

SELECT * FROM Users u;

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users';

SELECT * from SPTimeLogs sl;
SELECT * from ErrorLogs el;