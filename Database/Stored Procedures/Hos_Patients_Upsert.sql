USE HospitalDB02
GO

CREATE PROCEDURE Hos_Patients_Upsert
  @PatientID UNIQUEIDENTIFIER,
  @FullName NVARCHAR(100),
  @Age INT,
  @Gender NVARCHAR(10),
  @Phone NVARCHAR(15),
  @Address NVARCHAR(255),
  @IsActive BIT = 1,
  @IsDeleted BIT = 0,
  @CreatedDateTime DATETIME2 = NULL,
  @UpdatedDateTime DATETIME2 = NULL,
  @UpdatedBy NVARCHAR(100) = 'Admin',
  @UserProfile NVARCHAR(200) = NULL -- optional: who is calling
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SPStartDateTimeUTC DATETIME2 = SYSUTCDATETIME(),
            @SPEndDateTimeUTC DATETIME2,
            @DurationMs INT;

    -- Set default timestamps if not provided
    IF @CreatedDateTime IS NULL SET @CreatedDateTime = SYSUTCDATETIME();
    IF @UpdatedDateTime IS NULL SET @UpdatedDateTime = SYSUTCDATETIME();

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.Patients WHERE PatientID = @PatientID)
        BEGIN
            -- Update existing patient when user edits from application
            UPDATE dbo.Patients
            SET
                FullName = @FullName,
                Age = @Age,
                Gender = @Gender,
                Phone = @Phone,
                Address = @Address,
                IsActive = @IsActive,
                IsDeleted = @IsDeleted,
                CreatedDateTime = @CreatedDateTime,
                UpdatedDateTime = @UpdatedDateTime,
                UpdatedBy = @UpdatedBy
            WHERE PatientID = @PatientID;
        END
        ELSE
        BEGIN
            -- Insert new patient when clicks add patient button
            INSERT INTO dbo.Patients (
                PatientID,
                FullName,
                Age,
                Gender,
                Phone,
                Address,
                IsActive,
                IsDeleted,
                CreatedDateTime,
                UpdatedDateTime,
                UpdatedBy
            )
            VALUES (
                @PatientID,
                @FullName,
                @Age,
                @Gender,
                @Phone,
                @Address,
                @IsActive,
                @IsDeleted,
                @CreatedDateTime,
                @UpdatedDateTime,
                @UpdatedBy
            );
        END

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
            'SP executed successfully'
        );
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
                'PatientID: ', @PatientID,
                ', FullName: ', @FullName,
                ', UserProfile: ', @UserProfile
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

        -- Re-throw the error
        THROW;
    END CATCH
END
GO

