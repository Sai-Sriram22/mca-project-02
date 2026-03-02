USE HospitalDB02
GO

CREATE PROCEDURE Hos_Users_SignUp
    @UserID UNIQUEIDENTIFIER = NULL,
    @FullName NVARCHAR(100),
    @Email NVARCHAR(150),
    @PasswordHash NVARCHAR(255),
    @IsActive BIT = 1,
    @IsDeleted BIT = 0,
    @CreatedDateTime DATETIME2 = NULL,
    @UpdatedDateTime DATETIME2 = NULL,
    @UserProfile NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SPStartDateTimeUTC DATETIME2 = SYSUTCDATETIME(),
            @SPEndDateTimeUTC DATETIME2,
            @DurationMs INT;

    IF @UserID IS NULL
        SET @UserID = NEWID();

    IF @CreatedDateTime IS NULL
        SET @CreatedDateTime = SYSUTCDATETIME();

    IF @UpdatedDateTime IS NULL
        SET @UpdatedDateTime = SYSUTCDATETIME();

    BEGIN TRY

        -- Check if email already exists

        IF EXISTS (
            SELECT 1 
            FROM dbo.Users 
            WHERE Email = @Email 
              AND IsDeleted = 0
        )
        BEGIN
            RAISERROR('Email already registered.', 16, 1);
            RETURN;
        END

        -- Insert new user
        INSERT INTO dbo.Users (
            UserID,
            FullName,
            Email,
            PasswordHash,
            IsActive,
            IsDeleted,
            CreatedDateTime,
            UpdatedDateTime
        )
        VALUES (
            @UserID,
            @FullName,
            @Email,
            @PasswordHash,
            @IsActive,
            @IsDeleted,
            @CreatedDateTime,
            @UpdatedDateTime
        );

        -- Log successful execution
        SET @SPEndDateTimeUTC = SYSUTCDATETIME();
        SET @DurationMs = DATEDIFF(MILLISECOND, @SPStartDateTimeUTC, @SPEndDateTimeUTC);

        INSERT INTO dbo.SPTimeLogs (
            DBSPExecutionTimeLogId,
            StoredProcedureName,
            StartDateTimeUTC,
            EndDateTimeUTC,
            DurationMs,
            UserProfile,
            Success,
            AdditionalInfo
        )
        VALUES (
            NEWID(),
            OBJECT_NAME(@@PROCID),
            @SPStartDateTimeUTC,
            @SPEndDateTimeUTC,
            @DurationMs,
            @UserProfile,
            1,
            'User registered successfully'
        );

        -- Return success
        SELECT 1 AS Success, 'User registered successfully' AS Message;

    END TRY
    BEGIN CATCH

        -- Log error
        INSERT INTO dbo.ErrorLogs (
            ErrorMessage,
            ErrorProcedure,
            ErrorLine,
            ErrorTime,
            InputContext
        )
        VALUES (
            ERROR_MESSAGE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            SYSUTCDATETIME(),
            CONCAT(
                'Email: ', @Email,
                ', FullName: ', @FullName
            )
        );

        -- Log failed execution
        SET @SPEndDateTimeUTC = SYSUTCDATETIME();
        SET @DurationMs = DATEDIFF(MILLISECOND, @SPStartDateTimeUTC, @SPEndDateTimeUTC);

        INSERT INTO dbo.SPTimeLogs (
            DBSPExecutionTimeLogId,
            StoredProcedureName,
            StartDateTimeUTC,
            EndDateTimeUTC,
            DurationMs,
            UserProfile,
            Success,
            AdditionalInfo
        )
        VALUES (
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