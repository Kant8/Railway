USE Railway
GO

declare @segment SegmentTableType;

--insert into @segment exec GetNetSegment @StartWaypointId = 2, @Forward = 0

--select * from @segment

--select SUM(l.Length) from (
--select wsstart.StationName as StartStationName, wsend.StationName as EndStationName, sl1.Length from @segment as s
--join SegmentLength as sl1 on s.WaypointId = sl1.StartWaypointId
--join WaypointStation as wsstart on wsstart.WaypointId = sl1.StartWaypointId
--join WaypointStation as wsend on wsend.WaypointId = sl1.EndWaypointId) as l

--exec GetSegmentLengths @Segment = @segment

DECLARE @StartStationId int
	
--select @StartStationId = r.StartStation from Route as r where r.Id = @RouteId

insert into @segment exec GetNetSegmentsByStationId @StationId = 1

select * from @segment
