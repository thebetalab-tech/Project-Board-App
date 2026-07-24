-- ============================================================================
-- Task Management Database Table & Stored Procedures
-- File: DB/task.sql
-- ============================================================================

-- 1. TABLE CREATION
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Task')
BEGIN
    CREATE TABLE Task (
        TaskId INT IDENTITY(1,1) PRIMARY KEY,
        TaskTitle NVARCHAR(200) NOT NULL,
        TaskDescription NVARCHAR(MAX) NULL,
        GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(GroupId) ON DELETE CASCADE,
        AssignedBy INT NOT NULL FOREIGN KEY REFERENCES Users(UserId),
        AssignedTo INT NOT NULL FOREIGN KEY REFERENCES Users(UserId),
        TaskLevel NVARCHAR(20) NOT NULL, -- 'MentorToLeader' or 'LeaderToMember'
        ParentTaskId INT NULL FOREIGN KEY REFERENCES Task(TaskId),
        DueDate DATETIME NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- 'Pending', 'In Progress', 'Completed'
        ReportText NVARCHAR(MAX) NULL,
        ReportSubmittedAt DATETIME NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        UpdatedAt DATETIME DEFAULT GETDATE()
    );
END
GO

-- 2. SELECTION STORED PROCEDURE
IF OBJECT_ID('sp_select_tasks', 'P') IS NOT NULL
    DROP PROCEDURE sp_select_tasks;
GO

CREATE PROCEDURE sp_select_tasks
    @Action NVARCHAR(30),       -- 'BY_GROUP', 'BY_ASSIGNED_TO', 'BY_ASSIGNED_BY', 'BY_ID', 'MENTOR_LEADER_TASKS', 'LEADER_MEMBER_TASKS'
    @TaskId INT = NULL,
    @GroupId INT = NULL,
    @UserId INT = NULL,
    @TaskLevel NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'BY_ID'
    BEGIN
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        WHERE t.TaskId = @TaskId;
    END
    ELSE IF @Action = 'BY_GROUP'
    BEGIN
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        WHERE t.GroupId = @GroupId
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'BY_ASSIGNED_TO'
    BEGIN
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        WHERE t.AssignedTo = @UserId
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'MENTOR_LEADER_TASKS'
    BEGIN
        -- Tasks assigned by a Mentor or received by a Leader for a Group/Mentor
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        WHERE t.TaskLevel = 'MentorToLeader'
          AND (@GroupId IS NULL OR t.GroupId = @GroupId)
          AND (@UserId IS NULL OR t.AssignedBy = @UserId OR t.AssignedTo = @UserId)
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'LEADER_MEMBER_TASKS'
    BEGIN
        -- Tasks assigned by a Leader to Members
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        WHERE t.TaskLevel = 'LeaderToMember'
          AND (@GroupId IS NULL OR t.GroupId = @GroupId)
          AND (@UserId IS NULL OR t.AssignedBy = @UserId OR t.AssignedTo = @UserId)
        ORDER BY t.CreatedAt DESC;
    END
END
GO

-- 3. CRUD STORED PROCEDURE
IF OBJECT_ID('sp_crud_tasks', 'P') IS NOT NULL
    DROP PROCEDURE sp_crud_tasks;
GO

CREATE PROCEDURE sp_crud_tasks
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE_STATUS', 'SUBMIT_REPORT', 'DELETE'
    @TaskId INT = NULL,
    @TaskTitle NVARCHAR(200) = NULL,
    @TaskDescription NVARCHAR(MAX) = NULL,
    @GroupId INT = NULL,
    @AssignedBy INT = NULL,
    @AssignedTo INT = NULL,
    @TaskLevel NVARCHAR(20) = NULL,
    @ParentTaskId INT = NULL,
    @DueDate DATETIME = NULL,
    @Status NVARCHAR(20) = NULL,
    @ReportText NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Task (
            TaskTitle, TaskDescription, GroupId, AssignedBy, AssignedTo, 
            TaskLevel, ParentTaskId, DueDate, Status, CreatedAt, UpdatedAt
        )
        VALUES (
            @TaskTitle, @TaskDescription, @GroupId, @AssignedBy, @AssignedTo, 
            @TaskLevel, @ParentTaskId, @DueDate, ISNULL(@Status, 'Pending'), GETDATE(), GETDATE()
        );
    END
    ELSE IF @Action = 'UPDATE_STATUS'
    BEGIN
        UPDATE Task
        SET Status = @Status,
            UpdatedAt = GETDATE()
        WHERE TaskId = @TaskId;
    END
    ELSE IF @Action = 'SUBMIT_REPORT'
    BEGIN
        UPDATE Task
        SET ReportText = @ReportText,
            ReportSubmittedAt = GETDATE(),
            Status = ISNULL(@Status, Status),
            UpdatedAt = GETDATE()
        WHERE TaskId = @TaskId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Task WHERE TaskId = @TaskId;
    END
END
GO
