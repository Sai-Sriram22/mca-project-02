USE HospitalDB02
GO

INSERT INTO dbo.Users (UserID
, FullName
, Email
, PasswordHash
, IsActive
, IsDeleted
, CreatedDateTime
, UpdatedDateTime)
  VALUES (DEFAULT -- UserID - uniqueidentifier NOT NULL
  , '' -- FullName - varchar(100) NOT NULL
  , '' -- Email - varchar(150) NOT NULL
  , '' -- PasswordHash - varchar(255) NOT NULL
  , DEFAULT -- IsActive - bit NOT NULL
  , DEFAULT -- IsDeleted - bit NOT NULL
  , DEFAULT -- 'YYYY-MM-DD hh:mm:ss[.nnn]'-- CreatedDateTime - datetime NOT NULL
  , GETDATE() -- 'YYYY-MM-DD hh:mm:ss[.nnn]'-- UpdatedDateTime - datetime
  );
GO