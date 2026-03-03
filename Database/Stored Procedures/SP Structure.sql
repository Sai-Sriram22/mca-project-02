USE HospitalDB;
GO

CREATE OR ALTER PROCEDURE SP_Name
(
    @InputParam1 NVARCHAR(250) = NULL,     -- Example input parameter
    @UserProfile NVARCHAR(200) = NULL      -- User profile for logging
)
AS
BEGIN
    SET NOCOUNT ON;

    -- ==========================================
    -- Declare execution logging variables
    -- ==========================================
    DECLARE 
        @SPStartDateTimeUTC DATETIME2 = SYSUTCDATETIME(),  -- SP start timestamp
        @SPEndDateTimeUTC   DATETIME2,
        @DurationMs         INT;

    BEGIN TRY
        -- ==========================================
        -- Start of your business logic
        -- ==========================================









        -- ==========================================
        -- Capture end time and duration for logging
        -- ==========================================
        SET @SPEndDateTimeUTC = SYSUTCDATETIME();
        SET @DurationMs = DATEDIFF(MILLISECOND, @SPStartDateTimeUTC, @SPEndDateTimeUTC);

        -- ==========================================
        -- Insert execution log for successful run
        -- ==========================================
        INSERT INTO SptimeLogs
            (DBSPExecutionTimeLogId
            , StoredProcedureName
            , StartDateTimeUTC
            , EndDateTimeUTC
            , DurationMs
            , UserProfile
            , Success
            , AdditionalInfo)
        VALUES
            (NEWID()
            , OBJECT_NAME(@@PROCID)                       -- Current SP name
            , @SPStartDateTimeUTC
            , @SPEndDateTimeUTC
            , @DurationMs
            , @UserProfile
            , 1                                            -- Success
            , 'SP executed successfully');

    END TRY
    BEGIN CATCH
        -- ==========================================
        -- Capture error details
        -- ==========================================
        INSERT INTO ErrorLogs
            (ErrorMessage
            , ErrorProcedure
            , ErrorLine
            , ErrorTime
            , InputContext)
        VALUES
            (ERROR_MESSAGE(),                        -- Error message
             ERROR_PROCEDURE(),                      -- Procedure where error occurred
             ERROR_LINE(),                           -- Line number of error
             SYSUTCDATETIME(),                       -- Error timestamp
             CONCAT('InputParam1: ', @InputParam1, ', UserProfile: ', @UserProfile));  -- Input context

        -- ==========================================
        -- Capture execution log for failed run
        -- ==========================================
        SET @SPEndDateTimeUTC = SYSUTCDATETIME();
        SET @DurationMs = DATEDIFF(MILLISECOND, @SPStartDateTimeUTC, @SPEndDateTimeUTC);

        INSERT INTO SptimeLogs
            (DBSPExecutionTimeLogId
            , StoredProcedureName
            , StartDateTimeUTC
            , EndDateTimeUTC
            , DurationMs
            , UserProfile
            , Success
            , AdditionalInfo)
        VALUES
            (NEWID()
            , OBJECT_NAME(@@PROCID)
            , @SPStartDateTimeUTC
            , @SPEndDateTimeUTC
            , @DurationMs
            , @UserProfile
            , 0                                         -- Failed execution
            , ERROR_MESSAGE());

        -- Optional: re-throw the error to propagate it to the caller
        THROW;
    END CATCH
END;
GO


