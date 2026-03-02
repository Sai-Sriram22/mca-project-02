CREATE PROCEDURE Hos_LoginHistory_Insert
    @LoginHistoryID UNIQUEIDENTIFIER,
    @UserID UNIQUEIDENTIFIER = NULL,
    @Email NVARCHAR(150),
    @IPAddress NVARCHAR(50),
    @UserAgent NVARCHAR(300),
    @IsSuccess BIT,
    @FailureReason NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.LoginHistory
    (
        LoginHistoryID,
        UserID,
        Email,
        LoginTimeUTC,
        IPAddress,
        UserAgent,
        IsSuccess,
        FailureReason
    )
    VALUES
    (
        @LoginHistoryID,
        @UserID,
        @Email,
        SYSUTCDATETIME(),
        @IPAddress,
        @UserAgent,
        @IsSuccess,
        @FailureReason
    );
END
GO