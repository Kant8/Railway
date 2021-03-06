/*
   14 мая 2014 г.12:42:22
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
ALTER TABLE dbo.Station SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Station', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Station', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Station', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Ticket
	DROP CONSTRAINT FK_Ticket_Wagon
GO
ALTER TABLE dbo.Wagon SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Wagon', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Wagon', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Wagon', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Ticket
	DROP CONSTRAINT FK_Ticket_Route
GO
ALTER TABLE dbo.Route SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Route', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Route', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Route', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Ticket
	DROP CONSTRAINT FK_Ticket_Passenger
GO
ALTER TABLE dbo.Passenger SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Passenger', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Passenger', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Passenger', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_Ticket
	(
	Id int NOT NULL IDENTITY (1, 1),
	PassengerId int NOT NULL,
	Price money NOT NULL,
	WagonId int NOT NULL,
	RouteId int NOT NULL,
	BuyDate datetime NOT NULL,
	InStationId int NOT NULL,
	OutStationId int NOT NULL,
	Length int NOT NULL,
	InTime datetime NOT NULL,
	OutTime datetime NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_Ticket SET (LOCK_ESCALATION = TABLE)
GO
SET IDENTITY_INSERT dbo.Tmp_Ticket ON
GO
IF EXISTS(SELECT * FROM dbo.Ticket)
	 EXEC('INSERT INTO dbo.Tmp_Ticket (Id, PassengerId, Price, WagonId, RouteId, BuyDate)
		SELECT Id, PassengerId, Price, WagonId, RouteId, BuyDate FROM dbo.Ticket WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_Ticket OFF
GO
DROP TABLE dbo.Ticket
GO
EXECUTE sp_rename N'dbo.Tmp_Ticket', N'Ticket', 'OBJECT' 
GO
ALTER TABLE dbo.Ticket ADD CONSTRAINT
	PK_Ticket PRIMARY KEY CLUSTERED 
	(
	Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Ticket ADD CONSTRAINT
	FK_Ticket_Passenger FOREIGN KEY
	(
	PassengerId
	) REFERENCES dbo.Passenger
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
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
ALTER TABLE dbo.Ticket ADD CONSTRAINT
	FK_Ticket_Wagon FOREIGN KEY
	(
	WagonId
	) REFERENCES dbo.Wagon
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Ticket ADD CONSTRAINT
	FK_Ticket_Station_In FOREIGN KEY
	(
	InStationId
	) REFERENCES dbo.Station
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Ticket ADD CONSTRAINT
	FK_Ticket_Station_Out FOREIGN KEY
	(
	OutStationId
	) REFERENCES dbo.Station
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Ticket', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Ticket', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Ticket', 'Object', 'CONTROL') as Contr_Per 