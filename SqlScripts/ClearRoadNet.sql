-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-13
-- Description:	Очищает и сбрасывает счетчик id
-- =============================================
CREATE PROCEDURE ClearRoadNet	
AS
BEGIN
	delete from RoadNet
	DBCC CHECKIDENT (RoadNet, RESEED, 0)

END
GO
