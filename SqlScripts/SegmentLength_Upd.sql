/*
   14 мая 2014 г.10:14:47
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
ALTER TABLE dbo.Waypoint SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Waypoint', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Waypoint', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Waypoint', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.SegmentLength
	DROP CONSTRAINT FK_SegmentLength_SegmentLength
GO
ALTER TABLE dbo.SegmentLength ADD CONSTRAINT
	FK_SegmentLength_Waypoint_Start FOREIGN KEY
	(
	StartWaypoint
	) REFERENCES dbo.Waypoint
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.SegmentLength ADD CONSTRAINT
	FK_SegmentLength_Waypoint_End FOREIGN KEY
	(
	EndWaypoint
	) REFERENCES dbo.Waypoint
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.SegmentLength SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'CONTROL') as Contr_Per 