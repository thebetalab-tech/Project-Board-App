-- ============================================================================
-- Deletion Audit System — Migration Script
-- File: DB/deletion_audit_schema.sql
-- Run this script ONCE against your database to add the deletion audit system.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. CREATE DeletedRecords TABLE
-- ----------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DeletedRecords')
BEGIN
    CREATE TABLE DeletedRecords (
        DeleteId        INT IDENTITY(1,1) PRIMARY KEY,
        EntityType      NVARCHAR(50)    NOT NULL,   -- 'User', 'Group', 'Project', 'Task', 'Appeal', 'Technology'
        EntityId        INT             NOT NULL,    -- Original PK of the deleted entity
        EntityName      NVARCHAR(300)   NOT NULL,    -- Human-readable display name / title
        EntityDetails   NVARCHAR(MAX)   NULL,        -- JSON-like snapshot of key fields at deletion time
        DeletedBy       INT             NULL,        -- FK to Users (admin who triggered deletion)
        DeletedByName   NVARCHAR(100)   NOT NULL DEFAULT 'System', -- Denormalized; survives user deletion
        DeletedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
        Reason          NVARCHAR(MAX)   NULL,        -- Optional reason / note for deletion
        ParentDeleteId  INT             NULL FOREIGN KEY REFERENCES DeletedRecords(DeleteId)  -- For cascade-deleted children
    );
END
GO

-- Index for fast lookup by type and date
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DeletedRecords_EntityType' AND object_id = OBJECT_ID('DeletedRecords'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DeletedRecords_EntityType ON DeletedRecords (EntityType, DeletedAt DESC);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DeletedRecords_DeletedBy' AND object_id = OBJECT_ID('DeletedRecords'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DeletedRecords_DeletedBy ON DeletedRecords (DeletedBy, DeletedAt DESC);
END
GO

-- ----------------------------------------------------------------------------
-- 2. STORED PROCEDURES
-- ----------------------------------------------------------------------------

-- sp_crud_deleted_records  —  INSERT log entries + query helpers
IF OBJECT_ID('sp_crud_deleted_records', 'P') IS NOT NULL DROP PROCEDURE sp_crud_deleted_records;
GO
CREATE PROCEDURE sp_crud_deleted_records
    @Action         NVARCHAR(30),           -- 'INSERT', 'ALL', 'BY_TYPE', 'BY_ACTOR', 'SEARCH', 'STATS', 'BY_DATE_RANGE'
    @EntityType     NVARCHAR(50)    = NULL,
    @EntityId       INT             = NULL,
    @EntityName     NVARCHAR(300)   = NULL,
    @EntityDetails  NVARCHAR(MAX)   = NULL,
    @DeletedBy      INT             = NULL,
    @DeletedByName  NVARCHAR(100)   = 'System',
    @Reason         NVARCHAR(MAX)   = NULL,
    @ParentDeleteId INT             = NULL,
    @SearchKeyword  NVARCHAR(200)   = NULL,
    @DateFrom       DATETIME        = NULL,
    @DateTo         DATETIME        = NULL,
    @PageNumber     INT             = 1,
    @PageSize       INT             = 25
AS
BEGIN
    SET NOCOUNT ON;

    -- -------------------------
    -- INSERT — log a deletion
    -- -------------------------
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO DeletedRecords (EntityType, EntityId, EntityName, EntityDetails, DeletedBy, DeletedByName, DeletedAt, Reason, ParentDeleteId)
        VALUES (@EntityType, @EntityId, @EntityName, @EntityDetails, @DeletedBy, ISNULL(@DeletedByName, 'System'), GETDATE(), @Reason, @ParentDeleteId);

        SELECT SCOPE_IDENTITY() AS NewDeleteId;
        RETURN;
    END

    -- -------------------------
    -- STATS — count per type
    -- -------------------------
    IF @Action = 'STATS'
    BEGIN
        SELECT 
            EntityType,
            COUNT(1) AS TotalDeleted,
            MAX(DeletedAt) AS LastDeletedAt
        FROM DeletedRecords
        WHERE ParentDeleteId IS NULL   -- top-level only
        GROUP BY EntityType
        ORDER BY TotalDeleted DESC;

        SELECT COUNT(1) AS GrandTotal FROM DeletedRecords WHERE ParentDeleteId IS NULL;
        RETURN;
    END

    -- -------------------------
    -- ALL — paged list, newest first
    -- -------------------------
    IF @Action = 'ALL'
    BEGIN
        SELECT 
            d.*,
            u.FullName AS ActorFullName
        FROM DeletedRecords d
        LEFT JOIN Users u ON d.DeletedBy = u.UserId
        ORDER BY d.DeletedAt DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        SELECT COUNT(1) AS TotalRows FROM DeletedRecords;
        RETURN;
    END

    -- -------------------------
    -- BY_TYPE — filter by entity type
    -- -------------------------
    IF @Action = 'BY_TYPE'
    BEGIN
        SELECT 
            d.*,
            u.FullName AS ActorFullName
        FROM DeletedRecords d
        LEFT JOIN Users u ON d.DeletedBy = u.UserId
        WHERE d.EntityType = @EntityType
        ORDER BY d.DeletedAt DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        SELECT COUNT(1) AS TotalRows FROM DeletedRecords WHERE EntityType = @EntityType;
        RETURN;
    END

    -- -------------------------
    -- BY_ACTOR — filter by who deleted
    -- -------------------------
    IF @Action = 'BY_ACTOR'
    BEGIN
        SELECT 
            d.*,
            u.FullName AS ActorFullName
        FROM DeletedRecords d
        LEFT JOIN Users u ON d.DeletedBy = u.UserId
        WHERE d.DeletedBy = @DeletedBy
        ORDER BY d.DeletedAt DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        SELECT COUNT(1) AS TotalRows FROM DeletedRecords WHERE DeletedBy = @DeletedBy;
        RETURN;
    END

    -- -------------------------
    -- SEARCH — keyword in name or details
    -- -------------------------
    IF @Action = 'SEARCH'
    BEGIN
        SELECT 
            d.*,
            u.FullName AS ActorFullName
        FROM DeletedRecords d
        LEFT JOIN Users u ON d.DeletedBy = u.UserId
        WHERE 
            (@EntityType IS NULL OR d.EntityType = @EntityType)
            AND (
                d.EntityName LIKE '%' + @SearchKeyword + '%'
                OR d.EntityDetails LIKE '%' + @SearchKeyword + '%'
                OR d.DeletedByName LIKE '%' + @SearchKeyword + '%'
            )
        ORDER BY d.DeletedAt DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        SELECT COUNT(1) AS TotalRows
        FROM DeletedRecords
        WHERE 
            (@EntityType IS NULL OR EntityType = @EntityType)
            AND (
                EntityName LIKE '%' + @SearchKeyword + '%'
                OR EntityDetails LIKE '%' + @SearchKeyword + '%'
                OR DeletedByName LIKE '%' + @SearchKeyword + '%'
            );
        RETURN;
    END

    -- -------------------------
    -- BY_DATE_RANGE — filter by deletion date window
    -- -------------------------
    IF @Action = 'BY_DATE_RANGE'
    BEGIN
        SELECT 
            d.*,
            u.FullName AS ActorFullName
        FROM DeletedRecords d
        LEFT JOIN Users u ON d.DeletedBy = u.UserId
        WHERE 
            (@EntityType IS NULL OR d.EntityType = @EntityType)
            AND (@DateFrom IS NULL OR d.DeletedAt >= @DateFrom)
            AND (@DateTo IS NULL OR d.DeletedAt <= DATEADD(DAY, 1, @DateTo))
        ORDER BY d.DeletedAt DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        SELECT COUNT(1) AS TotalRows
        FROM DeletedRecords
        WHERE 
            (@EntityType IS NULL OR EntityType = @EntityType)
            AND (@DateFrom IS NULL OR DeletedAt >= @DateFrom)
            AND (@DateTo IS NULL OR DeletedAt <= DATEADD(DAY, 1, @DateTo));
        RETURN;
    END
END
GO

PRINT 'Deletion Audit System migration completed successfully.';
PRINT 'Table: DeletedRecords';
PRINT 'Procedure: sp_crud_deleted_records';
GO
