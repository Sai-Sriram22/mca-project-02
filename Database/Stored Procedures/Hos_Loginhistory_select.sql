CREATE PROCEDURE dbo.Hos_LoginHistory_GetAll
    @UserProfile NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SPStartDateTimeUTC DATETIME2 = SYSUTCDATETIME(),
            @SPEndDateTimeUTC DATETIME2,
            @DurationMs INT,
            @PatientID UNIQUEIDENTIFIER = NULL,
            @FullName NVARCHAR(100) = NULL;

    BEGIN TRY

        SELECT
            u.FullName,
            lh.Email,
            lh.LoginTimeUTC,
            lh.IPAddress,
            lh.UserAgent,
            lh.IsSuccess,
            lh.FailureReason
        FROM dbo.LoginHistory lh
        LEFT JOIN dbo.Users u
            ON lh.UserID = u.UserID
        WHERE u.IsActive = 1
        ORDER BY lh.LoginTimeUTC DESC;

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