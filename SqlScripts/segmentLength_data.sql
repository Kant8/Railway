USE Railway
GO


--exec GetStationsOnSegmentsByStationId @StationId = 1

INSERT INTO SegmentLength
           ([StartWaypointId]
           ,[EndWaypointId]
           ,[Length])
     VALUES
           (1, 5, 4), (5, 6, 6), (6, 7, 4), (7, 8, 4), (8, 9, 7),
           (9, 10, 15), (10, 11, 10), (11, 12, 12), (12, 13, 19), (13, 14, 12),
           (14, 15, 11), (15, 16, 16), (16, 17, 13), (17, 18, 12), (18, 19, 24),
           (19, 20, 21), (20, 21, 23),
           
           (45, 48, 10), (48, 49, 14), (49, 50, 20), (50, 51, 22), (51, 52, 21),
           (52, 53, 10), (53, 54, 7), (54, 2, 3)
           
GO

