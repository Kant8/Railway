USE Railway
GO

declare @segment table (id int, prevWayId int, WayId int, nextWayId int);

insert into @segment exec GetNetSegment @StartWaypointId = 1

select * from @segment