USE [Railway]
GO
/****** Object:  StoredProcedure [dbo].[GetJunktionStations]    Script Date: 15.05.2014 12:36:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-14
-- Description:	Достает узловые станции
-- =============================================
CREATE PROCEDURE [dbo].[GetJunktionStations]
AS
BEGIN
	SET NOCOUNT ON;
	select distinct * from
	(
		select ws.StationId as Id, ws.StationName as Name from RoadNet as rn
		join WaypointStation as ws
		on ws.WaypointId = rn.WaypointId
		where rn.PrevWaypointId is null or rn.NextWaypointId is null
	) as js
END
