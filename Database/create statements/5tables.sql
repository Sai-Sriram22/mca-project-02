--DROP TABLE Billing;
--DROP TABLE Appointments;
--DROP TABLE Doctors;
--DROP TABLE Patients;

USE HospitalDB02;
GO

/* =========================
   DROP TABLES IF EXIST
========================= */

IF OBJECT_ID('Billing', 'U') IS NOT NULL DROP TABLE Billing;
IF OBJECT_ID('Appointments', 'U') IS NOT NULL DROP TABLE Appointments;
IF OBJECT_ID('Doctors', 'U') IS NOT NULL DROP TABLE Doctors;
IF OBJECT_ID('Patients', 'U') IS NOT NULL DROP TABLE Patients;
GO


/* =========================
   PATIENTS TABLE
========================= */

CREATE TABLE Patients (
    PatientID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),

    FullName VARCHAR(100) NOT NULL,
    Age INT NOT NULL,
    Gender VARCHAR(10),
    Phone VARCHAR(15),
    Address VARCHAR(255),

    -- Audit & Soft Delete
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDateTime DATETIME NULL,
    UpdatedBy VARCHAR(100) NULL
);
GO


/* =========================
   DOCTORS TABLE
========================= */

CREATE TABLE Doctors (
    DoctorID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),

    FullName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100),

    -- Audit & Soft Delete
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDateTime DATETIME NULL,
    UpdatedBy VARCHAR(100) NULL
);
GO


/* =========================
   APPOINTMENTS TABLE
========================= */

CREATE TABLE Appointments (
    AppointmentID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),

    PatientID UNIQUEIDENTIFIER NOT NULL,
    DoctorID UNIQUEIDENTIFIER NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    Status VARCHAR(50),

    -- Audit & Soft Delete
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDateTime DATETIME NULL,
    UpdatedBy VARCHAR(100) NULL,

    CONSTRAINT FK_Appointments_Patient
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),

    CONSTRAINT FK_Appointments_Doctor
        FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);
GO


/* =========================
   BILLING TABLE
========================= */

CREATE TABLE Billing (
    BillID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),

    PatientID UNIQUEIDENTIFIER NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(50),
    BillDate DATETIME DEFAULT GETDATE(),

    -- Audit & Soft Delete
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDateTime DATETIME NULL,
    UpdatedBy VARCHAR(100) NULL,

    CONSTRAINT FK_Billing_Patient
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);
GO