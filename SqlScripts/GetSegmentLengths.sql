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
-- Create date: 2014-05-14
-- Description:	Выдает длины для сегмента
-- =============================================
CREATE PROCEDURE GetSegmentLengths
	@Segment SegmentTableType READONLY
AS
BEGIN
	SET NOCOUNT ON;

    select 
		wsstart.StationId as StartStationId, wsstart.StationName as StartStationName, 
		wsend.StationId as EndStationId, wsend.StationName as EndStationName, 
		sl1.Length 
    from @Segment as s
	join SegmentLength as sl1 on s.WaypointId = sl1.StartWaypointId
	join WaypointStation as wsstart on wsstart.WaypointId = sl1.StartWaypointId
	join WaypointStation as wsend on wsend.WaypointId = sl1.EndWaypointId
	
END
GO
