/*

      SP_NAME: Hos_User_SignUp_SP
      DESC: When a user signs up, the data gets created into the hospital, userprofiels, and user table.
      SP_CreatedDate: 03-03-2026

*/

CREATE PROCEDURE Hos_User_SignUp_SP
(
    @HospitalName NVARCHAR(200),
    @Name NVARCHAR(150),
    @Email NVARCHAR(150),
    @Password NVARCHAR(255),
    @UserRole_Id UNIQUEIDENTIFIER,
    @Phone NVARCHAR(20) = NULL,
    @Address NVARCHAR(300) = NULL,
    @Gender NVARCHAR(20) = NULL,
    @DOB DATE = NULL,
    @CreatedBy UNIQUEIDENTIFIER = NULL,
    @UserProfile NVARCHAR(200) = NULL -- Who is calling the SP
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SPStartDateTimeUTC DATETIME2 = SYSUTCDATETIME(),
            @SPEndDateTimeUTC DATETIME2,
            @DurationMs INT;

-- Declaring the Primary Keys
    
    DECLARE @Hospital_Id UNIQUEIDENTIFIER = NEWID();
    DECLARE @User_Id UNIQUEIDENTIFIER = NEWID();
    DECLARE @UserProfile_Id UNIQUEIDENTIFIER = NEWID();

    BEGIN TRY
        BEGIN TRAN;

        -- Check duplicate email
        IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email AND IsDeleted = 0)
        BEGIN
            RAISERROR('Email already exists.',16,1);
        END

        -- Insert Hospital
        INSERT INTO Hospitals
        (
            Hospital_Id,
            HospitalName,
            IsActive,
            IsDeleted,
            CreatedBy,
            UpdatedDateTime
        )
        VALUES
        (
            @Hospital_Id,
            @HospitalName,
            1,
            0,
            @CreatedBy,
            SYSDATETIME()
        );

        -- Insert User
        INSERT INTO Users
        (
            User_Id,
            Hospital_Id,
            Name,
            Email,
            UserRole_Id,
            Password,
            IsActive,
            IsDeleted,
            CreatedBy,
            UpdatedDateTime
        )
        VALUES
        (
            @User_Id,
            @Hospital_Id,
            @Name,
            @Email,
            @UserRole_Id,
            @Password,
            1,
            0,
            @CreatedBy,
            SYSDATETIME()
        );

        -- Insert UserProfile
        INSERT INTO UserProfiles
        (
            UserProfile_Id,
            User_Id,
            Phone,
            Address,
            Gender,
            DOB,
            IsActive,
            IsDeleted,
            CreatedBy,
            UpdatedDateTime
        )
        VALUES
        (
            @UserProfile_Id,
            @User_Id,
            @Phone,
            @Address,
            @Gender,
            @DOB,
            1,
            0,
            @CreatedBy,
            SYSDATETIME()
        );

        COMMIT;

        -- Log successful execution
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
            'User signup successful'
        );

        -- Return IDs
        SELECT 
            1 AS Success,
            @Hospital_Id AS Hospital_Id,
            @User_Id AS User_Id,
            @UserProfile_Id AS UserProfile_Id;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK;

        -- Log error details
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
                'Email: ', @Email,
                ', HospitalName: ', @HospitalName,
                ', UserProfile: ', @UserProfile
            )
        );

        -- Log failed execution
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

        SELECT 
            0 AS Success,
            ERROR_MESSAGE() AS ErrorMessage;

    END CATCH
END
GO