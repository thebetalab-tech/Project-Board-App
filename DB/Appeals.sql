-- ============================================================================
-- Appeals Management Database Table & Stored Procedures
-- File: DB/Appeals.sql
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Appeals')
BEGIN
    CREATE TABLE Appeals (
        AppealId INT IDENTITY(1,1) PRIMARY KEY,
        TaskId INT NOT NULL FOREIGN KEY REFERENCES Task(TaskId) ON DELETE CASCADE,
        StudentId INT NOT NULL FOREIGN KEY REFERENCES Users(UserId),
        GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(GroupId),
        Reason NVARCHAR(MAX) NOT NULL,
        Status NVARCHAR(30) NOT NULL DEFAULT 'Pending Review', -- 'Pending Review', 'Accepted', 'Rejected'
        ReviewerId INT NULL FOREIGN KEY REFERENCES Users(UserId),
        Remarks NVARCHAR(MAX) NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        ReviewedAt DATETIME NULL
    );
END
GO

-- 2. SELECTION STORED PROCEDURE
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

-- 3. CRUD STORED PROCEDURE
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
    @Remarks NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Appeals (TaskId, StudentId, GroupId, Reason, Status, CreatedAt)
        VALUES (@TaskId, @StudentId, @GroupId, @Reason, 'Pending Review', GETDATE());

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
