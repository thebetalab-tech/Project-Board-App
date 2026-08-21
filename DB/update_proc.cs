using System;
using System.Data.SqlClient;

class Program {
    static void Main() {
        string connStr = "Server=db60483.databaseasp.net;Database=db60483;User Id=db60483;Password=K+c38N?jf9L!;Encrypt=False;MultipleActiveResultSets=True;";
        using (SqlConnection conn = new SqlConnection(connStr)) {
            conn.Open();
            string sql = @"
ALTER PROCEDURE [dbo].[sp_select_tasks]
    @Action NVARCHAR(30),
    @GroupId INT = NULL,
    @UserId INT = NULL,
    @TaskId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'BY_GROUP'
    BEGIN
        SELECT t.*, uBy.FullName AS AssignedByName, uTo.FullName AS AssignedToName, g.GroupName, ISNULL(p.TaskTitle, '') AS ParentTaskTitle
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
        SELECT t.*, uBy.FullName AS AssignedByName, uTo.FullName AS AssignedToName, g.GroupName, ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.AssignedTo = @UserId
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'BY_ASSIGNED_BY'
    BEGIN
        SELECT t.*, uBy.FullName AS AssignedByName, uTo.FullName AS AssignedToName, g.GroupName, ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.AssignedBy = @UserId
        ORDER BY t.CreatedAt DESC;
    END
    ELSE IF @Action = 'BY_ID'
    BEGIN
        SELECT t.*, uBy.FullName AS AssignedByName, uTo.FullName AS AssignedToName, g.GroupName, ISNULL(p.TaskTitle, '') AS ParentTaskTitle
        FROM Task t
        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
        INNER JOIN Groups g ON t.GroupId = g.GroupId
        LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
        WHERE t.TaskId = @TaskId;
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
        WHERE t.TaskLevel IN ('MentorToLeader', 'AdminToLeader', 'AdminToAll')
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
          AND (@GroupId IS NULL OR t.GroupId = @GroupId)
        ORDER BY t.CreatedAt DESC;
    END
END
";
            using (SqlCommand cmd = new SqlCommand(sql, conn)) {
                cmd.ExecuteNonQuery();
            }
        }
        Console.WriteLine("Done");
    }
}
