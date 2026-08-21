-- =============================================================================
-- Migration Script: Group Join Features
-- Date: 2026-08-21
-- Description: Adds enrollment validation, join request tracking, and rejection notifications
-- =============================================================================

-- 1. Add RequestedAt column to GroupMembers for tracking when requests were made
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('GroupMembers') AND name = 'RequestedAt')
BEGIN
    ALTER TABLE GroupMembers ADD RequestedAt DATETIME DEFAULT GETDATE();
END
GO

-- 2. Update JoinStatus values to include 'Requested' and 'Rejected' statuses
-- Note: This doesn't change existing data, just prepares the schema
-- The application will use: 'Pending', 'Requested', 'Accepted', 'Rejected'

-- 3. Add GroupStatus column to track if group is accepting members
-- This is already covered by MemberNeeded column in Groups table

-- 4. Ensure GroupMembers has proper indexes for join status lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GroupMembers_JoinStatus')
BEGIN
    CREATE INDEX IX_GroupMembers_JoinStatus ON GroupMembers(JoinStatus);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GroupMembers_UserId_JoinStatus')
BEGIN
    CREATE INDEX IX_GroupMembers_UserId_JoinStatus ON GroupMembers(UserId, JoinStatus);
END
GO

-- 5. Update sp_crud_groups to support MemberNeeded status
-- This is already handled in the current schema

-- 6. Create stored procedure for handling group join requests
IF OBJECT_ID('sp_select_group_join_requests', 'P') IS NOT NULL DROP PROCEDURE sp_select_group_join_requests;
GO
CREATE PROCEDURE sp_select_group_join_requests
    @Action NVARCHAR(30),       -- 'BY_USER', 'BY_GROUP', 'ALL_PENDING', 'BY_STATUS'
    @UserId INT = NULL,
    @GroupId INT = NULL,
    @Status NVARCHAR(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'BY_USER'
    BEGIN
        SELECT
            gm.GroupId, gm.UserId, gm.JoinStatus, gm.RequestedAt,
            g.GroupName, g.TechId, g.Status AS GroupStatus, g.MemberNeeded,
            t.TechName,
            l.FullName AS LeaderName, l.Email AS LeaderEmail
        FROM GroupMembers gm
        INNER JOIN Groups g ON gm.GroupId = g.GroupId
        LEFT JOIN Technologies t ON g.TechId = t.TechId
        INNER JOIN Users l ON g.LeaderId = l.UserId
        WHERE gm.UserId = @UserId
        ORDER BY gm.RequestedAt DESC;
    END
    ELSE IF @Action = 'BY_GROUP'
    BEGIN
        SELECT
            gm.GroupId, gm.UserId, gm.JoinStatus, gm.RequestedAt,
            u.FullName, u.Email, u.EnrollmentNo
        FROM GroupMembers gm
        INNER JOIN Users u ON gm.UserId = u.UserId
        WHERE gm.GroupId = @GroupId
        ORDER BY gm.RequestedAt DESC;
    END
    ELSE IF @Action = 'ALL_PENDING'
    BEGIN
        SELECT
            gm.GroupId, gm.UserId, gm.JoinStatus, gm.RequestedAt,
            g.GroupName, t.TechName,
            l.FullName AS LeaderName,
            u.FullName AS RequestedByName, u.Email AS RequestedByEmail, u.EnrollmentNo AS RequestedEnrollment
        FROM GroupMembers gm
        INNER JOIN Groups g ON gm.GroupId = g.GroupId
        LEFT JOIN Technologies t ON g.TechId = t.TechId
        INNER JOIN Users l ON g.LeaderId = l.UserId
        INNER JOIN Users u ON gm.UserId = u.UserId
        WHERE gm.JoinStatus IN ('Pending', 'Requested')
        ORDER BY gm.RequestedAt DESC;
    END
    ELSE IF @Action = 'BY_STATUS'
    BEGIN
        SELECT
            gm.GroupId, gm.UserId, gm.JoinStatus, gm.RequestedAt,
            g.GroupName, t.TechName,
            l.FullName AS LeaderName,
            u.FullName AS RequestedByName
        FROM GroupMembers gm
        INNER JOIN Groups g ON gm.GroupId = g.GroupId
        LEFT JOIN Technologies t ON g.TechId = t.TechId
        INNER JOIN Users l ON g.LeaderId = l.UserId
        INNER JOIN Users u ON gm.UserId = u.UserId
        WHERE gm.JoinStatus = @Status
        ORDER BY gm.RequestedAt DESC;
    END
END
GO

-- 7. Create stored procedure for user's active group join requests
IF OBJECT_ID('sp_get_user_active_request', 'P') IS NOT NULL DROP PROCEDURE sp_get_user_active_request;
GO
CREATE PROCEDURE sp_get_user_active_request
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Returns any pending or requested group join request for this user
    SELECT
        gm.GroupId, gm.JoinStatus, gm.RequestedAt,
        g.GroupName, t.TechName, l.FullName AS LeaderName
    FROM GroupMembers gm
    INNER JOIN Groups g ON gm.GroupId = g.GroupId
    LEFT JOIN Technologies t ON g.TechId = t.TechId
    INNER JOIN Users l ON g.LeaderId = l.UserId
    WHERE gm.UserId = @UserId AND gm.JoinStatus IN ('Pending', 'Requested')
END
GO

-- 8. Create stored procedure for handling group join request rejection notification
IF OBJECT_ID('sp_insert_rejection_notification', 'P') IS NOT NULL DROP PROCEDURE sp_insert_rejection_notification;
GO
CREATE PROCEDURE sp_insert_rejection_notification
    @UserId INT,
    @GroupName NVARCHAR(100),
    @LeaderName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (UserId, Message, Link)
    VALUES (
        @UserId,
        'Your request to join group "' + @GroupName + '" has been rejected by ' + @LeaderName + '.',
        '~/Student/Member/MyRequests.aspx'
    );
END
GO
