/*
   14 мая 2014 г.10:30:18
   User: 
   Server: KONTOROVICH\SQLEXPRESS
   Database: Railway
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
EXECUTE sp_rename N'dbo.SegmentLength.StartWaypoint', N'Tmp_StartWaypointId', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.SegmentLength.EndWaypoint', N'Tmp_EndWaypointId_1', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.SegmentLength.Tmp_StartWaypointId', N'StartWaypointId', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.SegmentLength.Tmp_EndWaypointId_1', N'EndWaypointId', 'COLUMN' 
GO
ALTER TABLE dbo.SegmentLength SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'CONTROL') as Contr_Per 