USE HospitalDB02;
GO

-- =========================
-- SP Execution Time Logs
-- =========================
CREATE TABLE SPTimeLogs (
    DBSPExecutionTimeLogId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    StoredProcedureName NVARCHAR(255),
    StartDateTimeUTC DATETIME2,
    EndDateTimeUTC DATETIME2,
    DurationMs INT,
    UserProfile NVARCHAR(200),
    Success BIT,
    AdditionalInfo NVARCHAR(MAX)
);

-- =========================
-- Error Logs
-- =========================
CREATE TABLE ErrorLogs (
    ErrorLogId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ErrorMessage NVARCHAR(MAX),
    ErrorProcedure NVARCHAR(255),
    ErrorLine INT,
    ErrorTime DATETIME2 DEFAULT SYSUTCDATETIME(),
    InputContext NVARCHAR(MAX)
);


SELECT * FROM SPTimeLogs sl;
SELECT * from ErrorLogs el;