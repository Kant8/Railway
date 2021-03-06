/*
   14 мая 2014 г.12:33:49
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
CREATE TABLE dbo.Tmp_Route
	(
	Id int NOT NULL IDENTITY (1, 1),
	StartStation int NOT NULL,
	StartTime datetime NOT NULL,
	EndStation int NOT NULL,
	EndTime datetime NOT NULL,
	TrainId int NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_Route SET (LOCK_ESCALATION = TABLE)
GO
SET IDENTITY_INSERT dbo.Tmp_Route ON
GO
IF EXISTS(SELECT * FROM dbo.Route)
	 EXEC('INSERT INTO dbo.Tmp_Route (Id, StartStation, StartTime, EndStation, EndTime)
		SELECT Id, StartStation, StartTime, EndStation, EndTime FROM dbo.Route WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_Route OFF
GO
ALTER TABLE dbo.Ticket
	DROP CONSTRAINT FK_Ticket_Route
GO
DROP TABLE dbo.Route
GO
EXECUTE sp_rename N'dbo.Tmp_Route', N'Route', 'OBJECT' 
GO
ALTER TABLE dbo.Route ADD CONSTRAINT
	PK_Route PRIMARY KEY CLUSTERED 
	(
	Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
select Has_Perms_By_Name(N'dbo.Route', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Route', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Route', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Ticket ADD CONSTRAINT
	FK_Ticket_Route FOREIGN KEY
	(
	RouteId
	) REFERENCES dbo.Route
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Ticket SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Ticket', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Ticket', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Ticket', 'Object', 'CONTROL') as Contr_Per 