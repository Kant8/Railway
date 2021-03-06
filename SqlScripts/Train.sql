/*
   14 мая 2014 г.10:01:18
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
ALTER TABLE dbo.Train
	DROP CONSTRAINT FK_Train_Worker
GO
ALTER TABLE dbo.Worker SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Worker', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Worker', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Worker', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Train
	DROP CONSTRAINT FK_Train_Station
GO
ALTER TABLE dbo.Station SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Station', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Station', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Station', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_Train
	(
	Id int NOT NULL IDENTITY (1, 1),
	Name nvarchar(50) NOT NULL,
	MaxWagonCount int NOT NULL,
	DriverId int NULL,
	CurrentStationId int NOT NULL,
	Velocity float(53) NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_Train SET (LOCK_ESCALATION = TABLE)
GO
SET IDENTITY_INSERT dbo.Tmp_Train ON
GO
IF EXISTS(SELECT * FROM dbo.Train)
	 EXEC('INSERT INTO dbo.Tmp_Train (Id, Name, MaxWagonCount, DriverId, CurrentStationId)
		SELECT Id, Name, MaxWagonCount, DriverId, CurrentStationId FROM dbo.Train WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_Train OFF
GO
ALTER TABLE dbo.Wagon
	DROP CONSTRAINT FK_Wagon_Train
GO
DROP TABLE dbo.Train
GO
EXECUTE sp_rename N'dbo.Tmp_Train', N'Train', 'OBJECT' 
GO
ALTER TABLE dbo.Train ADD CONSTRAINT
	PK_Train PRIMARY KEY CLUSTERED 
	(
	Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Train ADD CONSTRAINT
	FK_Train_Station FOREIGN KEY
	(
	CurrentStationId
	) REFERENCES dbo.Station
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Train ADD CONSTRAINT
	FK_Train_Worker FOREIGN KEY
	(
	DriverId
	) REFERENCES dbo.Worker
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Train', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Train', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Train', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Wagon ADD CONSTRAINT
	FK_Wagon_Train FOREIGN KEY
	(
	TrainId
	) REFERENCES dbo.Train
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Wagon SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Wagon', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Wagon', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Wagon', 'Object', 'CONTROL') as Contr_Per 