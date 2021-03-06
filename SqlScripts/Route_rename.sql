/*
   14 мая 2014 г.13:55:40
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
EXECUTE sp_rename N'dbo.Route.StartStation', N'Tmp_StartStationId_2', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.Route.EndStation', N'Tmp_EndStationId_3', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.Route.Tmp_StartStationId_2', N'StartStationId', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.Route.Tmp_EndStationId_3', N'EndStationId', 'COLUMN' 
GO
ALTER TABLE dbo.Route SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Route', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Route', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Route', 'Object', 'CONTROL') as Contr_Per 