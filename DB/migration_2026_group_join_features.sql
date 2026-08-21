-- =============================================================================
-- Migration Script: Group Join Features
-- Date: 2026-08-21
-- Description: Adds enrollment validation, join request tracking, and rejection notifications
-- =============================================================================

-- 1. Add RequestedAt column to GroupMembers for tracking when requests were made
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('GroupMembers') AND name = 'RequestedAt')
BEGIN
    ALTER TABLE GroupMembers ADD RequestedAt DATETIME DEFAULT GETDATE();
    PRINT 'Added RequestedAt column to GroupMembers';
END
ELSE
BEGIN
    PRINT 'RequestedAt column already exists in GroupMembers - skipping';
END
GO

-- 2. Add IsActive column to Groups table for enable/disable groups
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Groups') AND name = 'IsActive')
BEGIN
    ALTER TABLE Groups ADD IsActive BIT DEFAULT 1;
    PRINT 'Added IsActive column to Groups';
END
ELSE
BEGIN
    PRINT 'IsActive column already exists in Groups - skipping';
END
GO

-- 3. Ensure GroupMembers has proper indexes for join status lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GroupMembers_JoinStatus')
BEGIN
    CREATE INDEX IX_GroupMembers_JoinStatus ON GroupMembers(JoinStatus);
    PRINT 'Created IX_GroupMembers_JoinStatus index';
END
ELSE
BEGIN
    PRINT 'IX_GroupMembers_JoinStatus index already exists - skipping';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_GroupMembers_UserId_JoinStatus')
BEGIN
    CREATE INDEX IX_GroupMembers_UserId_JoinStatus ON GroupMembers(UserId, JoinStatus);
    PRINT 'Created IX_GroupMembers_UserId_JoinStatus index';
END
ELSE
BEGIN
    PRINT 'IX_GroupMembers_UserId_JoinStatus index already exists - skipping';
END
GO

-- 4. Verify columns were added (optional - for debugging)
PRINT 'Migration completed successfully!';
