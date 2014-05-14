USE Railway
GO

CREATE TYPE SegmentTableType AS TABLE
( 
	Id int, 
	PrevWaypointId int, 
	WaypointId int, 
	NextWaypointId int
)