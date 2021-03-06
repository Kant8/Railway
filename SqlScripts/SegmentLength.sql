/*
   14 мая 2014 г.10:13:02
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
CREATE TABLE dbo.SegmentLength
	(
	Id int NOT NULL IDENTITY (1, 1),
	StartWaypoint int NOT NULL,
	EndWaypoint int NOT NULL,
	Length int NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.SegmentLength ADD CONSTRAINT
	PK_SegmentLength PRIMARY KEY CLUSTERED 
	(
	Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.SegmentLength ADD CONSTRAINT
	FK_SegmentLength_SegmentLength FOREIGN KEY
	(
	Id
	) REFERENCES dbo.SegmentLength
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.SegmentLength SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.SegmentLength', 'Object', 'CONTROL') as Contr_Per 