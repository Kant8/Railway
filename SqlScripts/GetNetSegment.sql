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
-- Description:	Достает цепочку по стартовой точке
-- =============================================
CREATE PROCEDURE GetNetSegment
	-- Add the parameters for the stored procedure here
	@StartWaypointId int,
	@Forward bit = 1 	
AS
BEGIN
	SET NOCOUNT ON;
	if @Forward = 1
	begin
		if (select NextWaypointId from RoadNet where WaypointId = @StartWaypointId) is not null
		with rzd_net (Id, PrevWaypointId, WaypointId, NextWaypointId)
		as
		(
			select Id, PrevWaypointId, WaypointId, NextWaypointId from RoadNet where WaypointId=@StartWaypointId
			union all
			select X.Id, X.PrevWaypointId, X.WaypointId, X.NextWaypointId from RoadNet as X
			join rzd_net on rzd_net.NextWaypointId = X.WaypointId
		)
		select * from rzd_net
	end
	else
	begin
		if (select PrevWaypointId from RoadNet where WaypointId = @StartWaypointId) is not null
		with rzd_net (Id, PrevWaypointId, WaypointId, NextWaypointId)
		as
		(
			select Id, PrevWaypointId, WaypointId, NextWaypointId from RoadNet where WaypointId=@StartWaypointId
			union all
			select X.Id, X.PrevWaypointId, X.WaypointId, X.NextWaypointId from RoadNet as X
			join rzd_net on rzd_net.PrevWaypointId = X.WaypointId
		)
		select * from rzd_net
	end
END
GO
