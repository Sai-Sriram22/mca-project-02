SELECT
  *
FROM Users u
WHERE u.Email LIKE '%admin@gmail.com%';

--UPDATE Users
--SET PasswordHash = 'admin123'
--   ,UpdatedDateTime = GETUTCDATE()
--WHERE UserID LIKE 'c513bdb5-d47e-4fd5-a014-3983f531e9ca'
--AND IsActive = 1;

SELECT
  *
FROM Users u;

SELECT
  *
FROM Patients p;

SELECT
  *
FROM Doctors d;

SELECT
  *
FROM Appointments a;

SELECT
  *
FROM Billing b;

SELECT
  *
FROM LoginHistory lh;

-- Writing the signupcode tempororily deactivated the patients that are there.

--UPDATE patients
--SET isdeleted = 1
--   ,isactive = 0
--   ,updateddatetime = GETUTCDATE()
--   ,updatedby = 'Admin';

USE HospitalDB02
GO

SELECT
  ErrorLogId
 ,ErrorMessage
 ,ErrorProcedure
 ,ErrorLine
 ,ErrorTime
 ,InputContext
FROM dbo.ErrorLogs;
GO

USE HospitalDB02
GO

SELECT
  DBSPExecutionTimeLogId
 ,StoredProcedureName
 ,StartDateTimeUTC
 ,EndDateTimeUTC
 ,DurationMs
 ,UserProfile
 ,Success
 ,AdditionalInfo
FROM dbo.SPTimeLogs;


SELECT
  *
FROM Users u;

01-03-2026 05:44:11.1722091

0431562f-333b-4fe0-b7e6-12826fda4a3c	odsfakjsbdasd,	76	MALE	O879089

SELECT p.PatientID,
  p.FullName AS Name
 ,p.Age,p.Phone
FROM Patients p
WHERE p.PatientID LIKE 'd33cc51d-4468-4a91-b67b-111c5464572b'
AND p.IsActive = 1;