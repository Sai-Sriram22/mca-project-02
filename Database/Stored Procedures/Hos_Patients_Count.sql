CREATE OR ALTER PROCEDURE dbo.Hos_Patients_Count
    @PatientID UNIQUEIDENTIFIER = NULL,
    @UserProfile NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SPStartDateTimeUTC DATETIME2 = SYSUTCDATETIME(),
            @SPEndDateTimeUTC DATETIME2,
            @DurationMs INT,
            @FullName NVARCHAR(100) = NULL;

    BEGIN TRY

        SELECT 
            COUNT(*) AS TotalPatients
        FROM Patients p
        WHERE p.IsActive = 1;

        SET @SPEndDateTimeUTC = SYSUTCDATETIME();
        SET @DurationMs = DATEDIFF(MILLISECOND, @SPStartDateTimeUTC, @SPEndDateTimeUTC);

        INSERT INTO dbo.SPTimeLogs
        (
            DBSPExecutionTimeLogId,
            StoredProcedureName,
            StartDateTimeUTC,
            EndDateTimeUTC,
            DurationMs,
            UserProfile,
            Success,
            AdditionalInfo
        )
        VALUES
        (
            NEWID(),
            OBJECT_NAME(@@PROCID),
            @SPStartDateTimeUTC,
            @SPEndDateTimeUTC,
            @DurationMs,
            @UserProfile,
            1,
            'SP executed successfully'
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.ErrorLogs
        (
            ErrorMessage,
            ErrorProcedure,
            ErrorLine,
            ErrorTime,
            InputContext
        )
        VALUES
        (
            ERROR_MESSAGE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            SYSUTCDATETIME(),
            CONCAT(
                'PatientID: ', @PatientID,
                ', FullName: ', @FullName,
                ', UserProfile: ', @UserProfile
            )
        );

        SET @SPEndDateTimeUTC = SYSUTCDATETIME();
        SET @DurationMs = DATEDIFF(MILLISECOND, @SPStartDateTimeUTC, @SPEndDateTimeUTC);

        INSERT INTO dbo.SPTimeLogs
        (
            DBSPExecutionTimeLogId,
            StoredProcedureName,
            StartDateTimeUTC,
            EndDateTimeUTC,
            DurationMs,
            UserProfile,
            Success,
            AdditionalInfo
        )
        VALUES
        (
            NEWID(),
            OBJECT_NAME(@@PROCID),
            @SPStartDateTimeUTC,
            @SPEndDateTimeUTC,
            @DurationMs,
            @UserProfile,
            0,
            ERROR_MESSAGE()
        );

        THROW;
    END CATCH
END
GO