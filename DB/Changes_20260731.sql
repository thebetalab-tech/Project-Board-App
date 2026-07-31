-- ============================================================================
-- DB Migration: Appeals System & Task Category Updates
-- ============================================================================

-- 1. ADD NEW COLUMNS TO APPEALS
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Appeals') AND name = 'ChangesMade')
BEGIN
    ALTER TABLE Appeals ADD ChangesMade NVARCHAR(MAX) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Appeals') AND name = 'IsCompleted')
BEGIN
    ALTER TABLE Appeals ADD IsCompleted BIT NOT NULL DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Appeals') AND name = 'Explanation')
BEGIN
    ALTER TABLE Appeals ADD Explanation NVARCHAR(MAX) NULL;
END
GO

-- 2. ADD NEW COLUMN TO TASK
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Task') AND name = 'TaskCategory')
BEGIN
    ALTER TABLE Task ADD TaskCategory NVARCHAR(50) NOT NULL DEFAULT 'Normal Task';
END
GO

-- 3. UPDATE CRUD FOR APPEALS
IF OBJECT_ID('sp_crud_appeals', 'P') IS NOT NULL
    DROP PROCEDURE sp_crud_appeals;
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

        -- Update Task status to Appealed
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

        -- Sync Task Status & FeedbackText if AppealId is provided
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

-- 4. UPDATE SELECT FOR APPEALS TO INCLUDE NEW COLUMNS (If any view logic requires them)
IF OBJECT_ID('sp_select_appeals', 'P') IS NOT NULL
    DROP PROCEDURE sp_select_appeals;
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

-- 5. UPDATE CRUD FOR TASKS TO SUPPORT TASK CATEGORY
IF OBJECT_ID('sp_crud_tasks', 'P') IS NOT NULL
    DROP PROCEDURE sp_crud_tasks;
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
