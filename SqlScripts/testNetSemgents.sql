USE Railway
GO

--declare @segment  table (id int, prevWayId int, wayId int, nextId int);
--insert into @segment exec GetNetSegment @StartWaypointId = 1

--select Waypoint.Id, Station.Id, Station.Name from @segment as seg join Waypoint on Waypoint.Id = seg.wayId join Station on Station.Id = Waypoint.StationId


declare @wayId int
declare @statName nvarchar(50)
declare waypoint_cursor cursor for select Waypoint.Id, Station.Name from Waypoint join Station on Waypoint.StationId = Station.Id

open waypoint_cursor
fetch next from waypoint_cursor into @wayId, @statName

while @@FETCH_STATUS <> 0
begin
	exec GetNetSegment @StartWaypointId = @wayId
	fetch next from waypoint_cursor into @wayId, @statName
end
close waypoint_cursor
