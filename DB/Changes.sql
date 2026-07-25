ALTER TABLE Groups ADD MemberNeeded BIT NOT NULL DEFAULT 1;

-- =============================================
-- Temporary Admin Credentials Query
-- Email: tempadmin@projectboard.com
-- Password: AdminPassword123!
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'tempadmin@projectboard.com')
BEGIN
    INSERT INTO Users (FullName, Email, PasswordHash, EnrollmentNo, Role, IsLeader, IsActive, CreatedAt)
    VALUES ('Temporary Admin', 'tempadmin@projectboard.com', 'QKDF2$100000$w9djwKkaSYvu60eqXp2m6w==$GisPdPEUnPx9NokSarmOLrd15Z4Oi61m1fKlvUlIIsQ=', 'ADM-TEMP-001', 'Admin', 0, 1, GETDATE());
END
ELSE
BEGIN
    UPDATE Users 
    SET PasswordHash = 'QKDF2$100000$w9djwKkaSYvu60eqXp2m6w==$GisPdPEUnPx9NokSarmOLrd15Z4Oi61m1fKlvUlIIsQ=', IsActive = 1, Role = 'Admin' 
    WHERE Email = 'tempadmin@projectboard.com';
END
GO
