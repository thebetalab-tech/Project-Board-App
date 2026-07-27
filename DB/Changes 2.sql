-- ============================================================================
-- Database Changes Script 2: Task Management Enhancements
-- File: DB/Changes 2.sql
-- ============================================================================

-- 1. Add PointsToCover column to store detailed bullet points or instructions for tasks
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Task') AND name = 'PointsToCover')
BEGIN
    ALTER TABLE Task ADD PointsToCover NVARCHAR(MAX) NULL;
END
GO

-- 2. Add FeedbackText column to store Mentor/Leader feedback on revision requests or appeal rejections
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Task') AND name = 'FeedbackText')
BEGIN
    ALTER TABLE Task ADD FeedbackText NVARCHAR(MAX) NULL;
END
GO

-- 3. Update existing standard statuses to use the new naming workflow ('Working', 'Appealed', 'Completed', 'Revision Needed', 'Failed')
UPDATE Task 
SET Status = 'Working' 
WHERE Status IN ('Pending', 'In Progress');
GO
