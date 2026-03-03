SELECT
  *
FROM Users u;

CREATE OR ALTER PROCEDURE Hos_User_Login (@UserName NVARCHAR(250) = NULL,     -- User login name
@Password NVARCHAR(200) = NULL      -- User password
)
AS
BEGIN
  SET NOCOUNT ON;

  -- ==========================================
  -- Declare execution logging variables
  -- ==========================================
  DECLARE @SPStartDateTimeUTC DATETIME2 = SYSUTCDATETIME()
         ,  -- SP start timestamp
          @SPEndDateTimeUTC DATETIME2
         ,@DurationMs INT;

  BEGIN TRY
    -- ==========================================
    -- Start of your business logic
    -- ==========================================

    IF EXISTS (SELECT
          1
        FROM Users u
        WHERE @UserName = u.FullName
        AND u.PasswordHash = @Password
        AND u.IsActive = 1);
    BEGIN
      SELECT
        u.UserID
       ,u.FullName
       ,u.IsActive AS Success
      FROM Users u
      WHERE u.FullName = @UserName;
    END

    ELSE

BEGIN

  SELECT
    NULL AS UserID
   ,NULL AS FullName
   ,'INVALID_CREDENTIALS' AS LoginStatus;

END
END;








-- ==========================================
-- Capture end time and duration for logging
-- ==========================================
SET @SPEndDateTimeUTC = SYSUTCDATETIME();
SET @DurationMs = DATEDIFF(MILLISECOND, @SPStartDateTimeUTC, @SPEndDateTimeUTC);

-- ==========================================
-- Insert execution log for successful run
-- ==========================================
INSERT INTO SptimeLogs (DBSPExecutionTimeLogId
, StoredProcedureName
, StartDateTimeUTC
, EndDateTimeUTC
, DurationMs
, UserProfile
, Success
, AdditionalInfo)
  VALUES (NEWID(), OBJECT_NAME(@@PROCID)                       -- Current SP name
  , @SPStartDateTimeUTC, @SPEndDateTimeUTC, @DurationMs, @UserProfile, 1                                            -- Success
  , 'SP executed successfully');

  END TRY
BEGIN
  -- ==========================================
  -- Capture error details
  -- ==========================================
  INSERT INTO ErrorLogs (ErrorMessage
  , ErrorProcedure
  , ErrorLine
  , ErrorTime
  , InputContext)
    VALUES (ERROR_MESSAGE(),                        -- Error message
    ERROR_PROCEDURE(),                      -- Procedure where error occurred
    ERROR_LINE(),                           -- Line number of error
    SYSUTCDATETIME(),                       -- Error timestamp
    CONCAT('InputParam1: ', @InputParam1, ', UserProfile: ', @UserProfile));  -- Input context

  -- ==========================================
  -- Capture execution log for failed run
  -- ==========================================
  SET @SPEndDateTimeUTC = SYSUTCDATETIME();
  SET @DurationMs = DATEDIFF(MILLISECOND, @SPStartDateTimeUTC, @SPEndDateTimeUTC);

  INSERT INTO SptimeLogs (DBSPExecutionTimeLogId
  , StoredProcedureName
  , StartDateTimeUTC
  , EndDateTimeUTC
  , DurationMs
  , UserProfile
  , Success
  , AdditionalInfo)
    VALUES (NEWID(), OBJECT_NAME(@@PROCID), @SPStartDateTimeUTC, @SPEndDateTimeUTC, @DurationMs, @UserProfile, 0                                         -- Failed execution
    , ERROR_MESSAGE());

  -- Optional: re-throw the error to propagate it to the caller
  THROW;
END
CATCH
END;
GO


