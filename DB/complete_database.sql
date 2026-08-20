-- ============================================================================
-- Complete Master Database Setup Script
-- Project Board Database Schema & Stored Procedures
-- File: DB/complete_database.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. TABLES CREATION
-- ----------------------------------------------------------------------------

-- Users Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        UserId INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) UNIQUE NOT NULL,
        PasswordHash NVARCHAR(256) NOT NULL,
        EnrollmentNo NVARCHAR(20) NULL,
        Role NVARCHAR(10) NOT NULL,    
        IsActive BIT DEFAULT 1,
        CreatedAt DATETIME DEFAULT GETDATE(),
        IsLeader BIT DEFAULT 0         
    );
END
GO

-- Technologies Master Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Technologies')
BEGIN
    CREATE TABLE Technologies (
        TechId INT IDENTITY(1,1) PRIMARY KEY,
        TechName NVARCHAR(50) UNIQUE NOT NULL 
    );
END
GO

-- Faculty Expertise Mapping
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Faculty')
BEGIN
    CREATE TABLE Faculty (
        FacultyId INT FOREIGN KEY REFERENCES Users(UserId),
        TechId INT FOREIGN KEY REFERENCES Technologies(TechId),
        PRIMARY KEY (FacultyId, TechId) 
    );
END
GO

-- Groups Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Groups')
BEGIN
    CREATE TABLE Groups (
        GroupId INT IDENTITY(1,1) PRIMARY KEY,
        GroupName NVARCHAR(100) NOT NULL,
        LeaderId INT FOREIGN KEY REFERENCES Users(UserId),
        TechId INT FOREIGN KEY REFERENCES Technologies(TechId),
        MentorId INT FOREIGN KEY REFERENCES Users(UserId) NULL,
        Status NVARCHAR(30) DEFAULT 'Forming' 
    );
END
GO

-- Group Members Mapping
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GroupMembers')
BEGIN
    CREATE TABLE GroupMembers (
        GroupId INT FOREIGN KEY REFERENCES Groups(GroupId),
        UserId INT FOREIGN KEY REFERENCES Users(UserId),
        JoinStatus NVARCHAR(15) DEFAULT 'Pending', 
        PRIMARY KEY (GroupId, UserId) 
    );
END
GO

-- Projects Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Projects')
BEGIN
    CREATE TABLE Projects (
        ProjectId INT IDENTITY(1,1) PRIMARY KEY,
        GroupId INT FOREIGN KEY REFERENCES Groups(GroupId),
        ProjectType CHAR(3) NOT NULL,          
        ProjectTitle NVARCHAR(150) NOT NULL,
        NormalizedTitle NVARCHAR(150) NOT NULL,
        Functionality NVARCHAR(1000) NOT NULL,
        Status NVARCHAR(15) DEFAULT 'Pending', 
        SubmittedAt DATETIME DEFAULT GETDATE()
    );
END
GO

-- Project Keywords Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProjectKeywords')
BEGIN
    CREATE TABLE ProjectKeywords (
        TagId INT IDENTITY(1,1) PRIMARY KEY,
        ProjectId INT FOREIGN KEY REFERENCES Projects(ProjectId),
        Keyword NVARCHAR(30) NOT NULL 
    );
END
GO

-- Group Mentor Rejections Tracking Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GroupMentorRejections')
BEGIN
    CREATE TABLE GroupMentorRejections (
        GroupId INT FOREIGN KEY REFERENCES Groups(GroupId),
        FacultyId INT FOREIGN KEY REFERENCES Users(UserId),
        RejectedAt DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (GroupId, FacultyId) 
    );
END
GO

-- Task Management Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Task')
BEGIN
    CREATE TABLE Task (
        TaskId INT IDENTITY(1,1) PRIMARY KEY,
        TaskTitle NVARCHAR(200) NOT NULL,
        TaskDescription NVARCHAR(MAX) NULL,
        PointsToCover NVARCHAR(MAX) NULL,
        FeedbackText NVARCHAR(MAX) NULL,
        GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(GroupId) ON DELETE CASCADE,
        AssignedBy INT NOT NULL FOREIGN KEY REFERENCES Users(UserId),
        AssignedTo INT NOT NULL FOREIGN KEY REFERENCES Users(UserId),
        TaskLevel NVARCHAR(20) NOT NULL, -- 'MentorToLeader' or 'LeaderToMember'
        ParentTaskId INT NULL FOREIGN KEY REFERENCES Task(TaskId),
        DueDate DATETIME NULL,
        Status NVARCHAR(50) NOT NULL DEFAULT 'Working', -- 'Working', 'Appealed', 'Completed', 'Revision Needed', 'Failed'
        ReportText NVARCHAR(MAX) NULL,
        ReportSubmittedAt DATETIME NULL,
        TaskCategory NVARCHAR(50) NOT NULL DEFAULT 'Normal Task',
        CreatedAt DATETIME DEFAULT GETDATE(),
        UpdatedAt DATETIME DEFAULT GETDATE()
    );
END
GO

-- Appeals Management Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Appeals')
BEGIN
    CREATE TABLE Appeals (
        AppealId INT IDENTITY(1,1) PRIMARY KEY,
        TaskId INT NOT NULL FOREIGN KEY REFERENCES Task(TaskId) ON DELETE CASCADE,
        StudentId INT NOT NULL FOREIGN KEY REFERENCES Users(UserId),
        GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(GroupId),
        Reason NVARCHAR(MAX) NOT NULL,
        ChangesMade NVARCHAR(MAX) NULL,
        IsCompleted BIT NOT NULL DEFAULT 0,
        Explanation NVARCHAR(MAX) NULL,
        Status NVARCHAR(30) NOT NULL DEFAULT 'Pending Review', -- 'Pending Review', 'Accepted', 'Rejected'
        ReviewerId INT NULL FOREIGN KEY REFERENCES Users(UserId),
        Remarks NVARCHAR(MAX) NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        ReviewedAt DATETIME NULL
    );
END
GO

-- Notifications Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Notifications')
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

-- Rejection Logs Table
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


-- ----------------------------------------------------------------------------
-- 2. STORED PROCEDURES
-- ----------------------------------------------------------------------------

-- Users Stored Procedures
IF OBJECT_ID('sp_select_users', 'P') IS NOT NULL DROP PROCEDURE sp_select_users;
GO
CREATE PROCEDURE sp_select_users
    @Action NVARCHAR(20),       -- 'ALL', 'BY_ID', 'BY_ROLE'
    @UserId INT = NULL,
    @Role NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Action = 'ALL'
    BEGIN
        SELECT * FROM Users WHERE IsActive = 1;
    END
    ELSE IF @Action = 'BY_ID'
    BEGIN
        SELECT * FROM Users WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'BY_ROLE'
    BEGIN
        SELECT * FROM Users WHERE Role = @Role AND IsActive = 1;
    END
END
GO

IF OBJECT_ID('sp_crud_users', 'P') IS NOT NULL DROP PROCEDURE sp_crud_users;
GO
CREATE PROCEDURE sp_crud_users
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE', 'DELETE'
    @UserId INT = NULL,
    @FullName NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @PasswordHash NVARCHAR(256) = NULL,
    @EnrollmentNo NVARCHAR(20) = NULL,
    @Role NVARCHAR(10) = NULL,
    @IsLeader BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Users (FullName, Email, PasswordHash, EnrollmentNo, Role, IsLeader)
        VALUES (@FullName, @Email, @PasswordHash, @EnrollmentNo, @Role, @IsLeader);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Users
        SET FullName = ISNULL(@FullName, FullName), 
            Email = ISNULL(@Email, Email), 
            EnrollmentNo = ISNULL(@EnrollmentNo, EnrollmentNo)
        WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        -- Complete Cascade Hard Delete
        IF OBJECT_ID('Task', 'U') IS NOT NULL
        BEGIN
            DELETE FROM Task WHERE ParentTaskId IN (SELECT TaskId FROM Task WHERE AssignedTo = @UserId OR AssignedBy = @UserId);
            DELETE FROM Task WHERE AssignedTo = @UserId OR AssignedBy = @UserId;
        END;

        DELETE FROM GroupMembers WHERE UserId = @UserId;
        DELETE FROM GroupMentorRejections WHERE FacultyId = @UserId;
        DELETE FROM Faculty WHERE FacultyId = @UserId;
        UPDATE Groups SET MentorId = NULL, Status = 'Forming' WHERE MentorId = @UserId;

        DECLARE @GroupIds TABLE (GroupId INT);
        INSERT INTO @GroupIds SELECT GroupId FROM Groups WHERE LeaderId = @UserId;

        IF OBJECT_ID('ProjectKeywords', 'U') IS NOT NULL
            DELETE FROM ProjectKeywords WHERE ProjectId IN (SELECT ProjectId FROM Projects WHERE GroupId IN (SELECT GroupId FROM @GroupIds));

        IF OBJECT_ID('Projects', 'U') IS NOT NULL
            DELETE FROM Projects WHERE GroupId IN (SELECT GroupId FROM @GroupIds);

        IF OBJECT_ID('Task', 'U') IS NOT NULL
            DELETE FROM Task WHERE GroupId IN (SELECT GroupId FROM @GroupIds);

        DELETE FROM GroupMentorRejections WHERE GroupId IN (SELECT GroupId FROM @GroupIds);
        DELETE FROM GroupMembers WHERE GroupId IN (SELECT GroupId FROM @GroupIds);
        DELETE FROM Groups WHERE LeaderId = @UserId;

        DELETE FROM Users WHERE UserId = @UserId;
    END
END
GO

IF OBJECT_ID('sp_LoginUser', 'P') IS NOT NULL DROP PROCEDURE sp_LoginUser;
GO
CREATE PROCEDURE sp_LoginUser
    @LoginId NVARCHAR(100),       -- Email, EnrollmentNo, or UserId
    @PasswordHash NVARCHAR(256)   -- Hashed password
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        UserId, 
        FullName, 
        Email, 
        EnrollmentNo, 
        Role, 
        IsLeader
    FROM 
        Users
    WHERE 
        IsActive = 1                        
        AND PasswordHash = @PasswordHash    
        AND (                               
            Email = @LoginId 
            OR EnrollmentNo = @LoginId 
            OR TRY_CAST(@LoginId AS INT) = UserId
        );
END
GO

-- Technologies Stored Procedures
IF OBJECT_ID('sp_select_technologies', 'P') IS NOT NULL DROP PROCEDURE sp_select_technologies;
GO
CREATE PROCEDURE sp_select_technologies
    @Action NVARCHAR(20),       -- 'ALL', 'BY_ID'
    @TechId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Action = 'ALL'
    BEGIN
        SELECT * FROM Technologies ORDER BY TechName;
    END
    ELSE IF @Action = 'BY_ID'
    BEGIN
        SELECT * FROM Technologies WHERE TechId = @TechId;
    END
END
GO

IF OBJECT_ID('sp_crud_technologies', 'P') IS NOT NULL DROP PROCEDURE sp_crud_technologies;
GO
CREATE PROCEDURE sp_crud_technologies
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE', 'DELETE'
    @TechId INT = NULL,
    @TechName NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Technologies (TechName) VALUES (@TechName);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Technologies SET TechName = @TechName WHERE TechId = @TechId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Technologies WHERE TechId = @TechId;
    END
END
GO

-- Groups Stored Procedures
IF OBJECT_ID('sp_select_groups', 'P') IS NOT NULL DROP PROCEDURE sp_select_groups;
GO
CREATE PROCEDURE sp_select_groups
    @Action NVARCHAR(20),       -- 'ALL', 'BY_ID', 'FULL_DETAILS', 'BY_MENTOR'
    @GroupId INT = NULL,
    @MentorId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Action = 'ALL'
    BEGIN
        SELECT * FROM Groups;
    END
    ELSE IF @Action = 'BY_ID'
    BEGIN
        SELECT * FROM Groups WHERE GroupId = @GroupId;
    END
    ELSE IF @Action = 'BY_MENTOR'
    BEGIN
        SELECT * FROM Groups WHERE MentorId = @MentorId;
    END
    ELSE IF @Action = 'FULL_DETAILS'
    BEGIN
        SELECT 
            g.GroupName, Leader.FullName AS LeaderName, ISNULL(Mentor.FullName, 'Not Assigned') AS MentorName,
            STRING_AGG(Member.FullName, ', ') AS AllMembers
        FROM Groups g
        INNER JOIN Users Leader ON g.LeaderId = Leader.UserId
        LEFT JOIN Users Mentor ON g.MentorId = Mentor.UserId
        LEFT JOIN GroupMembers gm ON g.GroupId = gm.GroupId AND gm.JoinStatus = 'Accepted'
        LEFT JOIN Users Member ON gm.UserId = Member.UserId
        GROUP BY g.GroupName, Leader.FullName, Mentor.FullName;
    END
END
GO

IF OBJECT_ID('sp_crud_groups', 'P') IS NOT NULL DROP PROCEDURE sp_crud_groups;
GO
CREATE PROCEDURE sp_crud_groups
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE_STATUS', 'ASSIGN_MENTOR', 'DELETE'
    @GroupId INT = NULL,
    @GroupName NVARCHAR(100) = NULL,
    @LeaderId INT = NULL,
    @TechId INT = NULL,
    @MentorId INT = NULL,
    @Status NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Groups (GroupName, LeaderId, TechId, Status)
        VALUES (@GroupName, @LeaderId, @TechId, 'Forming');
        
        DECLARE @NewGroupId INT = SCOPE_IDENTITY();
        INSERT INTO GroupMembers (GroupId, UserId, JoinStatus) VALUES (@NewGroupId, @LeaderId, 'Accepted');
    END
    ELSE IF @Action = 'UPDATE_STATUS'
    BEGIN
        UPDATE Groups SET Status = @Status WHERE GroupId = @GroupId;
    END
    ELSE IF @Action = 'ASSIGN_MENTOR'
    BEGIN
        UPDATE Groups SET MentorId = @MentorId, Status = 'Pending Faculty Approval' WHERE GroupId = @GroupId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Groups WHERE GroupId = @GroupId;
    END
END
GO

-- Projects Stored Procedures
IF OBJECT_ID('sp_select_projects', 'P') IS NOT NULL DROP PROCEDURE sp_select_projects;
GO
CREATE PROCEDURE sp_select_projects
    @Action NVARCHAR(20),       -- 'BY_GROUP', 'BY_STATUS', 'ALL'
    @ProjectId INT = NULL,
    @GroupId INT = NULL,
    @Status NVARCHAR(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Action = 'ALL'
    BEGIN
        SELECT * FROM Projects;
    END
    ELSE IF @Action = 'BY_GROUP'
    BEGIN
        SELECT * FROM Projects WHERE GroupId = @GroupId;
    END
    ELSE IF @Action = 'BY_STATUS'
    BEGIN
        SELECT * FROM Projects WHERE Status = @Status;
    END
END
GO

IF OBJECT_ID('sp_crud_projects', 'P') IS NOT NULL DROP PROCEDURE sp_crud_projects;
GO
CREATE PROCEDURE sp_crud_projects
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE_STATUS', 'DELETE'
    @ProjectId INT = NULL,
    @GroupId INT = NULL,
    @ProjectType CHAR(3) = NULL,
    @ProjectTitle NVARCHAR(150) = NULL,
    @NormalizedTitle NVARCHAR(150) = NULL,
    @Functionality NVARCHAR(1000) = NULL,
    @Status NVARCHAR(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Projects (GroupId, ProjectType, ProjectTitle, NormalizedTitle, Functionality, Status)
        VALUES (@GroupId, @ProjectType, @ProjectTitle, @NormalizedTitle, @Functionality, 'Pending');
    END
    ELSE IF @Action = 'UPDATE_STATUS'
    BEGIN
        UPDATE Projects SET Status = @Status WHERE ProjectId = @ProjectId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Projects WHERE ProjectId = @ProjectId;
    END
END
GO

-- Task Management Stored Procedures
IF OBJECT_ID('sp_select_tasks', 'P') IS NOT NULL DROP PROCEDURE sp_select_tasks;
GO
CREATE PROCEDURE sp_select_tasks
    @Action NVARCHAR(30),       -- 'BY_GROUP', 'BY_ASSIGNED_TO', 'BY_ASSIGNED_BY', 'BY_ID', 'MENTOR_LEADER_TASKS', 'LEADER_MEMBER_TASKS', 'GROUP_MENTOR_TASKS'
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
            g.GroupName,
            ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.TaskId = @TaskId;
    END
    ELSE IF @Action = 'BY_GROUP'
    BEGIN
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName,
            ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.GroupId = @GroupId
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'BY_ASSIGNED_TO'
    BEGIN
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName,
            ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.AssignedTo = @UserId
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'MENTOR_LEADER_TASKS'
    BEGIN
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName,
            ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.TaskLevel = 'MentorToLeader'
          AND (@GroupId IS NULL OR t.GroupId = @GroupId)
          AND (@UserId IS NULL OR t.AssignedBy = @UserId OR t.AssignedTo = @UserId)
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'LEADER_MEMBER_TASKS'
    BEGIN
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName,
            ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.TaskLevel = 'LeaderToMember'
          AND (@GroupId IS NULL OR t.GroupId = @GroupId)
          AND (@UserId IS NULL OR t.AssignedBy = @UserId OR t.AssignedTo = @UserId)
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'GROUP_MENTOR_TASKS'
    BEGIN
        SELECT 
            t.*,
            uBy.FullName AS AssignedByName,
            uTo.FullName AS AssignedToName,
            g.GroupName,
            ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.TaskLevel = 'MentorToLeader'
          AND t.GroupId = @GroupId
        ORDER BY t.CreatedAt DESC;
    END
END
GO

IF OBJECT_ID('sp_crud_tasks', 'P') IS NOT NULL DROP PROCEDURE sp_crud_tasks;
GO
CREATE PROCEDURE sp_crud_tasks
    @Action NVARCHAR(30),       -- 'INSERT', 'UPDATE_STATUS', 'SUBMIT_REPORT', 'DELETE'
    @TaskId INT = NULL,
    @TaskTitle NVARCHAR(200) = NULL,
    @TaskDescription NVARCHAR(MAX) = NULL,
    @PointsToCover NVARCHAR(MAX) = NULL,
    @FeedbackText NVARCHAR(MAX) = NULL,
    @GroupId INT = NULL,
    @AssignedBy INT = NULL,
    @AssignedTo INT = NULL,
    @TaskLevel NVARCHAR(20) = NULL,
    @ParentTaskId INT = NULL,
    @DueDate DATETIME = NULL,
    @Status NVARCHAR(50) = NULL,
    @ReportText NVARCHAR(MAX) = NULL,
    @TaskCategory NVARCHAR(50) = 'Normal Task'
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Task (
            TaskTitle, TaskDescription, PointsToCover, GroupId, AssignedBy, AssignedTo, 
            TaskLevel, ParentTaskId, DueDate, Status, TaskCategory, CreatedAt, UpdatedAt
        )
        VALUES (
            @TaskTitle, @TaskDescription, @PointsToCover, @GroupId, @AssignedBy, @AssignedTo, 
            @TaskLevel, @ParentTaskId, @DueDate, ISNULL(@Status, 'Working'), @TaskCategory, GETDATE(), GETDATE()
        );
    END
    ELSE IF @Action = 'UPDATE_STATUS'
    BEGIN
        UPDATE Task
        SET Status = ISNULL(@Status, Status),
            FeedbackText = ISNULL(@FeedbackText, FeedbackText),
            UpdatedAt = GETDATE()
        WHERE TaskId = @TaskId;
    END
    ELSE IF @Action = 'SUBMIT_REPORT'
    BEGIN
        UPDATE Task
        SET ReportText = @ReportText,
            ReportSubmittedAt = GETDATE(),
            Status = ISNULL(@Status, 'Appealed'),
            UpdatedAt = GETDATE()
        WHERE TaskId = @TaskId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Task WHERE TaskId = @TaskId;
    END
END
GO

-- Appeals Management Stored Procedures
IF OBJECT_ID('sp_select_appeals', 'P') IS NOT NULL DROP PROCEDURE sp_select_appeals;
GO
CREATE PROCEDURE sp_select_appeals
    @Action NVARCHAR(30),       -- 'BY_TASK', 'BY_STUDENT', 'BY_GROUP', 'BY_REVIEWER', 'BY_ID', 'ALL'
    @AppealId INT = NULL,
    @TaskId INT = NULL,
    @StudentId INT = NULL,
    @GroupId INT = NULL,
    @ReviewerId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'BY_ID'
    BEGIN
        SELECT 
            a.*,
            t.TaskTitle,
            t.TaskDescription,
            t.DueDate,
            t.Status AS TaskStatus,
            uStu.FullName AS StudentName,
            uStu.Email AS StudentEmail,
            uRev.FullName AS ReviewerName,
            g.GroupName
        FROM Appeals a
        INNER JOIN Task t ON a.TaskId = t.TaskId
        INNER JOIN Users uStu ON a.StudentId = uStu.UserId
        LEFT JOIN Users uRev ON a.ReviewerId = uRev.UserId
        INNER JOIN Groups g ON a.GroupId = g.GroupId
        WHERE a.AppealId = @AppealId;
    END
    ELSE IF @Action = 'BY_TASK'
    BEGIN
        SELECT 
            a.*,
            t.TaskTitle,
            uStu.FullName AS StudentName,
            uRev.FullName AS ReviewerName
        FROM Appeals a
        INNER JOIN Task t ON a.TaskId = t.TaskId
        INNER JOIN Users uStu ON a.StudentId = uStu.UserId
        LEFT JOIN Users uRev ON a.ReviewerId = uRev.UserId
        WHERE a.TaskId = @TaskId
        ORDER BY a.CreatedAt DESC;
    END
    ELSE IF @Action = 'BY_STUDENT'
    BEGIN
        SELECT 
            a.*,
            t.TaskTitle,
            uStu.FullName AS StudentName,
            uRev.FullName AS ReviewerName
        FROM Appeals a
        INNER JOIN Task t ON a.TaskId = t.TaskId
        INNER JOIN Users uStu ON a.StudentId = uStu.UserId
        LEFT JOIN Users uRev ON a.ReviewerId = uRev.UserId
        WHERE a.StudentId = @StudentId
        ORDER BY a.CreatedAt DESC;
    END
    ELSE IF @Action = 'BY_GROUP'
    BEGIN
        SELECT 
            a.*,
            t.TaskTitle,
            uStu.FullName AS StudentName,
            uRev.FullName AS ReviewerName,
            g.GroupName
        FROM Appeals a
        INNER JOIN Task t ON a.TaskId = t.TaskId
        INNER JOIN Users uStu ON a.StudentId = uStu.UserId
        LEFT JOIN Users uRev ON a.ReviewerId = uRev.UserId
        INNER JOIN Groups g ON a.GroupId = g.GroupId
        WHERE a.GroupId = @GroupId
        ORDER BY a.CreatedAt DESC;
    END
    ELSE IF @Action = 'ALL'
    BEGIN
        SELECT 
            a.*,
            t.TaskTitle,
            uStu.FullName AS StudentName,
            uRev.FullName AS ReviewerName,
            g.GroupName
        FROM Appeals a
        INNER JOIN Task t ON a.TaskId = t.TaskId
        INNER JOIN Users uStu ON a.StudentId = uStu.UserId
        LEFT JOIN Users uRev ON a.ReviewerId = uRev.UserId
        INNER JOIN Groups g ON a.GroupId = g.GroupId
        ORDER BY a.CreatedAt DESC;
    END
END
GO

IF OBJECT_ID('sp_crud_appeals', 'P') IS NOT NULL DROP PROCEDURE sp_crud_appeals;
GO
CREATE PROCEDURE sp_crud_appeals
    @Action NVARCHAR(30),       -- 'INSERT', 'REVIEW', 'DELETE'
    @AppealId INT = NULL,
    @TaskId INT = NULL,
    @StudentId INT = NULL,
    @GroupId INT = NULL,
    @Reason NVARCHAR(MAX) = NULL,
    @Status NVARCHAR(30) = NULL,
    @ReviewerId INT = NULL,
    @Remarks NVARCHAR(MAX) = NULL,
    @ChangesMade NVARCHAR(MAX) = NULL,
    @IsCompleted BIT = 0,
    @Explanation NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Appeals (TaskId, StudentId, GroupId, Reason, ChangesMade, IsCompleted, Explanation, Status, CreatedAt)
        VALUES (@TaskId, @StudentId, @GroupId, @Reason, @ChangesMade, @IsCompleted, @Explanation, 'Pending Review', GETDATE());

        UPDATE Task 
        SET Status = 'Appealed',
            ReportText = @Reason,
            ReportSubmittedAt = GETDATE(),
            UpdatedAt = GETDATE()
        WHERE TaskId = @TaskId;
    END
    ELSE IF @Action = 'REVIEW'
    BEGIN
        UPDATE Appeals
        SET Status = ISNULL(@Status, Status),
            ReviewerId = ISNULL(@ReviewerId, ReviewerId),
            Remarks = ISNULL(@Remarks, Remarks),
            ReviewedAt = GETDATE()
        WHERE AppealId = @AppealId;

        IF @AppealId IS NOT NULL
        BEGIN
            DECLARE @TargetTaskId INT;
            SELECT @TargetTaskId = TaskId FROM Appeals WHERE AppealId = @AppealId;
            
            IF @TargetTaskId IS NOT NULL
            BEGIN
                DECLARE @NewTaskStatus NVARCHAR(50) = CASE 
                    WHEN @Status = 'Accepted' THEN 'Completed'
                    WHEN @Status = 'Rejected' THEN 'Revision Needed'
                    ELSE 'Appealed'
                END;

                UPDATE Task
                SET Status = @NewTaskStatus,
                    FeedbackText = ISNULL(@Remarks, FeedbackText),
                    UpdatedAt = GETDATE()
                WHERE TaskId = @TargetTaskId;
            END
        END
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Appeals WHERE AppealId = @AppealId;
    END
END
GO

-- Notifications Stored Procedures
IF OBJECT_ID('sp_select_notifications', 'P') IS NOT NULL DROP PROCEDURE sp_select_notifications;
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

IF OBJECT_ID('sp_crud_notifications', 'P') IS NOT NULL DROP PROCEDURE sp_crud_notifications;
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

-- Rejection Logs Stored Procedures
IF OBJECT_ID('sp_select_rejectionlogs', 'P') IS NOT NULL DROP PROCEDURE sp_select_rejectionlogs;
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

IF OBJECT_ID('sp_crud_rejectionlogs', 'P') IS NOT NULL DROP PROCEDURE sp_crud_rejectionlogs;
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
