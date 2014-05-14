-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-14
-- Description:	—читает врем€ приезда c начала маршрута до указанной станции
-- =============================================
CREATE FUNCTION GetTimeTillStationForRoute
(
	@RouteId int,
	@EndStationId int
)
RETURNS datetime
AS
BEGIN
	DECLARE @EndTime datetime
	
	

	-- Add the T-SQL statements to compute the return value here
	SELECT <@ResultVar, sysname, @Result> = <@Param1, sysname, @p1>
	
	
	

	RETURN @EndTime
END
GO

