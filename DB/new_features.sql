-- ============================================================================
-- New Features: Notifications & Rejection Logs
-- File: DB/new_features.sql
-- 
-- Run this script in your SQL Server Management Studio after connecting 
-- to your database (e.g., db78554).
-- ============================================================================

-- 1. Notifications Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Notifictions')
BEGIN
    CREATE TABLE Notifications (
        NotificationId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL FOREIGN KEY REFERENCES Users(UserId) ON DELETE CASCADE,
        Message NVARCHAR(MAX) NOT NULL,
        Link NVARCHAR(MAX) NULL,
        IsRead BIT DEFAULT 0,
        CreatedAt DATETIME DEFAULT GETDATE()
    );
END
GO

-- 2. RejectionLogs Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RejectionLogs')
BEGIN
    CREATE TABLE RejectionLogs (
        LogId INT IDENTITY(1,1) PRIMARY KEY,
        EntityType NVARCHAR(50) NOT NULL, -- 'Group', 'Project', 'Task', 'Appeal'
        EntityId INT NOT NULL,
        RejectedBy INT NOT NULL FOREIGN KEY REFERENCES Users(UserId) ON DELETE CASCADE,
        Reason NVARCHAR(MAX) NOT NULL,
        CreatedAt DATETIME DEFAULT GETDATE()
    );
END
GO


-- 3. Notifications SPs
IF OBJECT_ID('sp_select_notifications', 'P') IS NOT NULL
    DROP PROCEDURE sp_select_notifications;
GO

CREATE PROCEDURE sp_select_notifications
    @Action NVARCHAR(20),       -- 'BY_USER', 'UNREAD_COUNT'
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'BY_USER'
    BEGIN
        SELECT TOP 50 * 
        FROM Notifications 
        WHERE UserId = @UserId 
        ORDER BY CreatedAt DESC;
    END
    ELSE IF @Action = 'UNREAD_COUNT'
    BEGIN
        SELECT COUNT(*) AS UnreadCount 
        FROM Notifications 
        WHERE UserId = @UserId AND IsRead = 0;
    END
END
GO

IF OBJECT_ID('sp_crud_notifications', 'P') IS NOT NULL
    DROP PROCEDURE sp_crud_notifications;
GO

CREATE PROCEDURE sp_crud_notifications
    @Action NVARCHAR(20),       -- 'INSERT', 'MARK_READ', 'MARK_ALL_READ', 'DELETE'
    @NotificationId INT = NULL,
    @UserId INT = NULL,
    @Message NVARCHAR(MAX) = NULL,
    @Link NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Notifications (UserId, Message, Link)
        VALUES (@UserId, @Message, @Link);
    END
    ELSE IF @Action = 'MARK_READ'
    BEGIN
        UPDATE Notifications SET IsRead = 1 WHERE NotificationId = @NotificationId;
    END
    ELSE IF @Action = 'MARK_ALL_READ'
    BEGIN
        UPDATE Notifications SET IsRead = 1 WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Notifications WHERE NotificationId = @NotificationId;
    END
END
GO


-- 4. RejectionLogs SPs
IF OBJECT_ID('sp_select_rejectionlogs', 'P') IS NOT NULL
    DROP PROCEDURE sp_select_rejectionlogs;
GO

CREATE PROCEDURE sp_select_rejectionlogs
    @Action NVARCHAR(20),       -- 'BY_ENTITY'
    @EntityType NVARCHAR(50),
    @EntityId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'BY_ENTITY'
    BEGIN
        SELECT r.*, u.FullName AS RejectedByName
        FROM RejectionLogs r
        INNER JOIN Users u ON r.RejectedBy = u.UserId
        WHERE r.EntityType = @EntityType AND r.EntityId = @EntityId
        ORDER BY r.CreatedAt DESC;
    END
END
GO

IF OBJECT_ID('sp_crud_rejectionlogs', 'P') IS NOT NULL
    DROP PROCEDURE sp_crud_rejectionlogs;
GO

CREATE PROCEDURE sp_crud_rejectionlogs
    @Action NVARCHAR(20),       -- 'INSERT'
    @EntityType NVARCHAR(50),
    @EntityId INT,
    @RejectedBy INT,
    @Reason NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO RejectionLogs (EntityType, EntityId, RejectedBy, Reason)
        VALUES (@EntityType, @EntityId, @RejectedBy, @Reason);
    END
END
GO
