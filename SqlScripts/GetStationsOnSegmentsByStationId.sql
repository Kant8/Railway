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
-- Description:	Возвращает станции на доступных из старта сегментах
-- =============================================
CREATE PROCEDURE GetStationsOnSegmentsByStationId
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
		declare @segment  table (id int, prevWayId int, wayId int, nextWayId int);

		insert into @segment exec GetNetSegment @StartWaypointId = @wayId, @Forward = 1
		if (select count(*) from @segment) > 0
			select s.wayId as WaypointId, 			
			ws.StationId as StationId, ws.StationName as StationName			
			from @segment as s
			join WaypointStation as ws on ws.WaypointId = s.wayId
		delete from @segment

		insert into @segment exec GetNetSegment @StartWaypointId = @wayId, @Forward = 0
		if (select count(*) from @segment) > 0
			select s.wayId as WaypointId,
			ws.StationId as StationId, ws.StationName as StationName
			from @segment as s
			join WaypointStation as ws on ws.WaypointId = s.wayId

		delete from @segment
		fetch next from waypoint_cursor into @wayId
	end
	close waypoint_cursor
	deallocate waypoint_cursor

    
END
GO
