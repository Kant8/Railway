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
-- Description:	Получает набор путей для станции
-- =============================================
CREATE PROCEDURE GetNetSegmentsByStationId
	-- Add the parameters for the stored procedure here
	@StationId int
AS
BEGIN
	SET NOCOUNT ON;

	declare @wayId int
	declare waypoint_cursor cursor for 
		select Waypoint.Id from Waypoint
		join Station on Waypoint.StationId = Station.Id where Station.Id = @StationId

	open waypoint_cursor
	fetch next from waypoint_cursor into @wayId
	while @@FETCH_STATUS = 0
	begin
		exec GetNetSegment @StartWaypointId = @wayId, @Forward = 1

		declare @segment  table (id int, prevWayId int, wayId int, nextId int);
		insert into @segment exec GetNetSegment @StartWaypointId = @wayId, @Forward = 0
		if (select count(*) from @segment) > 0
			select Id, nextId as PrevWaypointId, wayId as WaypointId, prevWayId as NextWaypointId from @segment
		delete from @segment
		fetch next from waypoint_cursor into @wayId
	end
	close waypoint_cursor
	deallocate waypoint_cursor
END
GO
