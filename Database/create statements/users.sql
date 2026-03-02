--UPDATE patients
--SET isdeleted = 1
--   ,isactive = 0
--WHERE patientid = 'a936c6f2-07b7-4ec0-a454-3fcb46e0aec7';

CREATE TABLE Users (
    UserID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),

    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDateTime DATETIME NULL
);

INSERT INTO Users (FullName, Email, PasswordHash)
VALUES ('Admin User', 'admin@gmail.com', 'admin123');

SELECT * from Users;