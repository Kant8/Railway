USE [master]
GO
/****** Object:  Database [Railway]    Script Date: 15.05.2014 15:51:37 ******/
CREATE DATABASE [Railway]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Railway', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Railway.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Railway_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Railway_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Railway] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Railway].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Railway] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Railway] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Railway] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Railway] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Railway] SET ARITHABORT OFF 
GO
ALTER DATABASE [Railway] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Railway] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Railway] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Railway] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Railway] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Railway] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Railway] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Railway] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Railway] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Railway] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Railway] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Railway] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Railway] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Railway] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Railway] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Railway] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Railway] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Railway] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Railway] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Railway] SET  MULTI_USER 
GO
ALTER DATABASE [Railway] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Railway] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Railway] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Railway] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [Railway]
GO
/****** Object:  UserDefinedTableType [dbo].[SegmentTableType]    Script Date: 15.05.2014 15:51:37 ******/
CREATE TYPE [dbo].[SegmentTableType] AS TABLE(
	[Id] [int] NULL,
	[PrevWaypointId] [int] NULL,
	[WaypointId] [int] NULL,
	[NextWaypointId] [int] NULL
)
GO
/****** Object:  StoredProcedure [dbo].[ClearRoadNet]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-13
-- Description:	Очищает и сбрасывает счетчик id
-- =============================================
CREATE PROCEDURE [dbo].[ClearRoadNet]	
AS
BEGIN
	delete from RoadNet
	DBCC CHECKIDENT (RoadNet, RESEED, 0)

END


GO
/****** Object:  StoredProcedure [dbo].[GetJunktionStations]    Script Date: 15.05.2014 15:51:37 ******/
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

GO
/****** Object:  StoredProcedure [dbo].[GetNetSegment]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-13
-- Description:	Достает цепочку по стартовой точке
-- =============================================
CREATE PROCEDURE [dbo].[GetNetSegment]
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
/****** Object:  StoredProcedure [dbo].[GetNetSegmentsByStationId]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-13
-- Description:	Получает набор путей для станции
-- =============================================
CREATE PROCEDURE [dbo].[GetNetSegmentsByStationId]
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
/****** Object:  StoredProcedure [dbo].[GetSegmentLengths]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-14
-- Description:	Выдает длины для сегмента
-- =============================================
CREATE PROCEDURE [dbo].[GetSegmentLengths]
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
/****** Object:  StoredProcedure [dbo].[GetStationsOnSegmentsByStationId]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-13
-- Description:	Возвращает станции на доступных из старта сегментах
-- =============================================
CREATE PROCEDURE [dbo].[GetStationsOnSegmentsByStationId]
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
/****** Object:  StoredProcedure [dbo].[GetStationsOnSegmentsByStationIdFull]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrey Kontorovich
-- Create date: 2014-05-13
-- Description:	Возвращает станции на доступных из старта сегментах
-- =============================================
CREATE PROCEDURE [dbo].[GetStationsOnSegmentsByStationIdFull]
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
			select s.id as Id, s.prevWayId as PrevWaypointId, s.wayId as WaypointId, s.nextWayId as NextWaypointId, 
			wsprev.StationId as PrevStationId, wsprev.StationName as PrevStationName,
			ws.StationId as StationId, ws.StationName as StationName,
			wsnext.StationId as NextStationId, wsnext.StationName as NextStationName
			from @segment as s
			join WaypointStation as ws on ws.WaypointId = s.wayId
			left join WaypointStation as wsprev on wsprev.WaypointId = s.prevWayId
			left join WaypointStation as wsnext on wsnext.WaypointId = s.nextWayId
		delete from @segment

		insert into @segment exec GetNetSegment @StartWaypointId = @wayId, @Forward = 0
		if (select count(*) from @segment) > 0
			select s.id as Id, s.nextWayId as PrevWaypointId, s.wayId as WaypointId, s.prevWayId as NextWaypointId, 
			wsnext.StationId as PrevStationId, wsnext.StationName as PrevStationName,
			ws.StationId as StationId, ws.StationName as StationName,
			wsprev.StationId as NextStationId, wsprev.StationName as NextStationName
			from @segment as s
			join WaypointStation as ws on ws.WaypointId = s.wayId
			left join WaypointStation as wsprev on wsprev.WaypointId = s.prevWayId
			left join WaypointStation as wsnext on wsnext.WaypointId = s.nextWayId

			--select Id, nextWayId as PrevWaypointId, wayId as WaypointId, prevWayId as NextWaypointId from @segment
		delete from @segment
		fetch next from waypoint_cursor into @wayId
	end
	close waypoint_cursor
	deallocate waypoint_cursor

    
END


GO
/****** Object:  Table [dbo].[Passenger]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Passenger](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[IdentityNumber] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Passenger] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RoadNet]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoadNet](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[WaypointId] [int] NOT NULL,
	[PrevWaypointId] [int] NULL,
	[NextWaypointId] [int] NULL,
 CONSTRAINT [PK_RoadNet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Route]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Route](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StartStationId] [int] NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndStationId] [int] NOT NULL,
	[EndTime] [datetime] NULL,
	[TrainId] [int] NOT NULL,
 CONSTRAINT [PK_Route] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SegmentLength]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SegmentLength](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StartWaypointId] [int] NOT NULL,
	[EndWaypointId] [int] NOT NULL,
	[Length] [int] NOT NULL,
 CONSTRAINT [PK_SegmentLength] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Station]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Station](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Station] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ticket]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ticket](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PassengerId] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[WagonId] [int] NOT NULL,
	[RouteId] [int] NOT NULL,
	[BuyDate] [datetime] NOT NULL,
	[InStationId] [int] NOT NULL,
	[OutStationId] [int] NOT NULL,
	[Length] [int] NOT NULL,
	[InTime] [datetime] NULL,
	[OutTime] [datetime] NULL,
 CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Train]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Train](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[MaxWagonCount] [int] NOT NULL,
	[DriverId] [int] NULL,
	[CurrentStationId] [int] NOT NULL,
	[Velocity] [float] NOT NULL,
 CONSTRAINT [PK_Train] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Wagon]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Wagon](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MaxPassengerCount] [int] NOT NULL,
	[PassengerCount] [int] NOT NULL,
	[TrainId] [int] NULL,
	[ConductorId] [int] NULL,
 CONSTRAINT [PK_Wagon] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Waypoint]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Waypoint](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StationId] [int] NOT NULL,
 CONSTRAINT [PK_Waypoint] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Worker]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Worker](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[LengthOfService] [int] NOT NULL,
	[Salary] [money] NOT NULL,
 CONSTRAINT [PK_Worker] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[WaypointStation]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WaypointStation]
AS
SELECT        dbo.Station.Id AS StationId, dbo.Waypoint.Id AS WaypointId, dbo.Station.Name AS StationName
FROM            dbo.Station INNER JOIN
                         dbo.Waypoint ON dbo.Station.Id = dbo.Waypoint.StationId


GO
SET IDENTITY_INSERT [dbo].[Passenger] ON 

INSERT [dbo].[Passenger] ([Id], [FirstName], [MiddleName], [LastName], [IdentityNumber]) VALUES (2, N'Pass1', N'Pass1', N'Pass1', N'12345')
INSERT [dbo].[Passenger] ([Id], [FirstName], [MiddleName], [LastName], [IdentityNumber]) VALUES (3, N'pass1', N'pass1', N'pass1', N'MP12341235')
SET IDENTITY_INSERT [dbo].[Passenger] OFF
SET IDENTITY_INSERT [dbo].[RoadNet] ON 

INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (1, 1, NULL, 5)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (2, 5, 1, 6)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (3, 6, 5, 7)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (4, 7, 6, 8)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (5, 8, 7, 9)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (6, 9, 8, 10)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (7, 10, 9, 11)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (8, 11, 10, 12)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (9, 12, 11, 13)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (10, 13, 12, 14)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (11, 14, 13, 15)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (12, 15, 14, 16)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (13, 16, 15, 17)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (14, 17, 16, 18)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (15, 18, 17, 19)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (16, 19, 18, 20)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (17, 20, 19, 21)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (18, 21, 20, NULL)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (19, 22, NULL, 26)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (20, 26, 22, 27)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (21, 27, 26, 28)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (22, 28, 27, 29)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (23, 29, 28, 30)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (24, 30, 29, 31)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (25, 31, 30, 32)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (26, 32, 31, 33)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (27, 33, 32, NULL)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (28, 34, NULL, 35)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (29, 35, 34, NULL)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (30, 36, NULL, 37)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (31, 37, 36, 38)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (32, 38, 37, 39)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (33, 39, 38, 40)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (34, 40, 39, 41)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (35, 41, 40, 42)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (36, 42, 41, 43)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (37, 43, 42, 44)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (38, 44, 43, NULL)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (39, 45, NULL, 48)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (40, 48, 45, 49)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (41, 49, 48, 50)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (42, 50, 49, 51)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (43, 51, 50, 52)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (44, 52, 51, 53)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (45, 53, 52, 54)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (46, 54, 53, 2)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (47, 2, 54, NULL)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (48, 3, NULL, 55)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (49, 55, 3, 56)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (50, 56, 55, 57)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (51, 57, 56, 58)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (52, 58, 57, 59)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (53, 59, 58, 60)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (54, 60, 59, 61)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (55, 61, 60, 62)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (56, 62, 61, 63)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (57, 63, 62, 64)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (58, 64, 63, NULL)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (59, 65, NULL, 69)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (60, 69, 65, 70)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (61, 70, 69, 71)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (62, 71, 70, 72)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (63, 72, 71, 73)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (64, 73, 72, 74)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (65, 74, 73, 75)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (66, 75, 74, 76)
INSERT [dbo].[RoadNet] ([Id], [WaypointId], [PrevWaypointId], [NextWaypointId]) VALUES (67, 76, 75, NULL)
SET IDENTITY_INSERT [dbo].[RoadNet] OFF
SET IDENTITY_INSERT [dbo].[Route] ON 

INSERT [dbo].[Route] ([Id], [StartStationId], [StartTime], [EndStationId], [EndTime], [TrainId]) VALUES (1, 1, CAST(0x0000A32B00C5C100 AS DateTime), 18, CAST(0x0000A32B00C5C100 AS DateTime), 1)
INSERT [dbo].[Route] ([Id], [StartStationId], [StartTime], [EndStationId], [EndTime], [TrainId]) VALUES (5, 1, CAST(0x0000A32C00D63BC0 AS DateTime), 35, CAST(0x0000A32C00EF6C69 AS DateTime), 2)
SET IDENTITY_INSERT [dbo].[Route] OFF
SET IDENTITY_INSERT [dbo].[SegmentLength] ON 

INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (1, 1, 5, 4)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (2, 5, 6, 6)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (3, 6, 7, 4)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (4, 7, 8, 4)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (5, 8, 9, 7)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (6, 9, 10, 15)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (7, 10, 11, 10)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (8, 11, 12, 12)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (9, 12, 13, 19)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (10, 13, 14, 12)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (11, 14, 15, 11)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (12, 15, 16, 16)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (13, 16, 17, 13)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (14, 17, 18, 12)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (15, 18, 19, 24)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (16, 19, 20, 21)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (17, 20, 21, 23)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (18, 45, 48, 10)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (19, 48, 49, 14)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (20, 49, 50, 20)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (21, 50, 51, 22)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (22, 51, 52, 21)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (23, 52, 53, 10)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (24, 53, 54, 7)
INSERT [dbo].[SegmentLength] ([Id], [StartWaypointId], [EndWaypointId], [Length]) VALUES (25, 54, 2, 3)
SET IDENTITY_INSERT [dbo].[SegmentLength] OFF
SET IDENTITY_INSERT [dbo].[Station] ON 

INSERT [dbo].[Station] ([Id], [Name]) VALUES (1, N'Минск-Пассажирский')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (2, N'Минск-Восточный')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (3, N'Степянка')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (4, N'Озерище')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (5, N'Колодищи')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (6, N'Городище')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (7, N'Смолевичи')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (8, N'Красное Знамя')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (9, N'Жодино')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (10, N'Борисов')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (11, N'Новосады')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (12, N'Приямино')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (13, N'Крупки')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (14, N'Бобр')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (15, N'Славное')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (16, N'Толочин')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (17, N'Коханово')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (18, N'Орша-Центральная')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (19, N'Орша-Западная')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (20, N'Червено')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (21, N'Прокшино')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (22, N'Копысь')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (23, N'Шклов')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (24, N'Рыжковичи')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (25, N'Лотва')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (26, N'Могилев-1')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (27, N'Могилев-2')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (28, N'Голынец')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (29, N'Вендриж')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (30, N'Друть')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (31, N'Воничи')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (32, N'Несета')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (33, N'Елизово')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (34, N'Осиповичи-2')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (35, N'Осиповичи-1')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (36, N'Верейцы')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (37, N'Талька')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (38, N'Пуховичи')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (39, N'Руденск')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (40, N'Михановичи')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (41, N'Колядичи')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (42, N'Минск-Южный')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (43, N'Институт Культуры')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (44, N'Помыслище')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (45, N'Фаниполь')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (46, N'Койданово')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (47, N'Негорелое')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (48, N'Колосово')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (49, N'Столбцы')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (50, N'Городея')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (51, N'Погорельцы')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (52, N'Барановичи-Центральные')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (53, N'Лесная')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (54, N'Доманово')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (55, N'Ивацевичи')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (56, N'Оранчицы')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (57, N'Тевли')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (58, N'Жабинка')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (59, N'Брест-Восточный')
INSERT [dbo].[Station] ([Id], [Name]) VALUES (60, N'Брест-Центральный')
SET IDENTITY_INSERT [dbo].[Station] OFF
SET IDENTITY_INSERT [dbo].[Ticket] ON 

INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (1, 2, 123.0000, 1, 1, CAST(0x0000A32B01102BD4 AS DateTime), 3, 9, 0, NULL, NULL)
INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (2, 3, 214.0000, 4, 5, CAST(0x0000A32C00FB05CE AS DateTime), 1, 36, 107, CAST(0x0000A32C010860CE AS DateTime), CAST(0x0000A32C00EF6C69 AS DateTime))
INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (3, 3, 194.0000, 5, 5, CAST(0x0000A32C01020536 AS DateTime), 42, 36, 97, CAST(0x0000A32C00D6F08E AS DateTime), CAST(0x0000A32C00ED11BB AS DateTime))
INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (4, 3, 194.0000, 5, 5, CAST(0x0000A32C0103AA89 AS DateTime), 42, 36, 97, CAST(0x0000A32C00D6F08E AS DateTime), CAST(0x0000A32C00ED11BB AS DateTime))
INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (5, 2, 166.0000, 2, 1, CAST(0x0000A32C0103E4F6 AS DateTime), 14, 9, 83, CAST(0x0000A32B00ED9450 AS DateTime), CAST(0x0000A32B00DC0050 AS DateTime))
INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (6, 2, 142.0000, 3, 1, CAST(0x0000A32C0103FDF9 AS DateTime), 3, 9, 71, CAST(0x0000A32B00C99960 AS DateTime), CAST(0x0000A32B00DC0050 AS DateTime))
INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (7, 2, 162.0000, 1, 1, CAST(0x0000A32C0104381C AS DateTime), 1, 9, 81, CAST(0x0000A32B00C6DA40 AS DateTime), CAST(0x0000A32B00DC0050 AS DateTime))
INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (8, 2, 290.0000, 1, 1, CAST(0x0000A32C0104702A AS DateTime), 1, 14, 145, CAST(0x0000A32B00C6DA40 AS DateTime), CAST(0x0000A32B00ED9450 AS DateTime))
INSERT [dbo].[Ticket] ([Id], [PassengerId], [Price], [WagonId], [RouteId], [BuyDate], [InStationId], [OutStationId], [Length], [InTime], [OutTime]) VALUES (9, 2, 82.0000, 5, 5, CAST(0x0000A32C0104861C AS DateTime), 1, 39, 41, CAST(0x0000A32C00D72CD2 AS DateTime), CAST(0x0000A32C00DFE2BB AS DateTime))
SET IDENTITY_INSERT [dbo].[Ticket] OFF
SET IDENTITY_INSERT [dbo].[Train] ON 

INSERT [dbo].[Train] ([Id], [Name], [MaxWagonCount], [DriverId], [CurrentStationId], [Velocity]) VALUES (1, N'First Train', 0, 1, 1, 60)
INSERT [dbo].[Train] ([Id], [Name], [MaxWagonCount], [DriverId], [CurrentStationId], [Velocity]) VALUES (2, N'Second Train', 2, 5, 1, 70)
SET IDENTITY_INSERT [dbo].[Train] OFF
SET IDENTITY_INSERT [dbo].[Wagon] ON 

INSERT [dbo].[Wagon] ([Id], [MaxPassengerCount], [PassengerCount], [TrainId], [ConductorId]) VALUES (1, 3, 2, 1, 2)
INSERT [dbo].[Wagon] ([Id], [MaxPassengerCount], [PassengerCount], [TrainId], [ConductorId]) VALUES (2, 3, 1, 1, 3)
INSERT [dbo].[Wagon] ([Id], [MaxPassengerCount], [PassengerCount], [TrainId], [ConductorId]) VALUES (3, 3, 1, 1, 4)
INSERT [dbo].[Wagon] ([Id], [MaxPassengerCount], [PassengerCount], [TrainId], [ConductorId]) VALUES (4, 5, 1, 2, 6)
INSERT [dbo].[Wagon] ([Id], [MaxPassengerCount], [PassengerCount], [TrainId], [ConductorId]) VALUES (5, 25, 3, 2, 7)
SET IDENTITY_INSERT [dbo].[Wagon] OFF
SET IDENTITY_INSERT [dbo].[Waypoint] ON 

INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (1, 1)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (2, 1)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (3, 1)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (4, 1)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (5, 2)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (6, 3)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (7, 4)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (8, 5)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (9, 6)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (10, 7)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (11, 8)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (12, 9)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (13, 10)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (14, 11)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (15, 12)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (16, 13)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (17, 14)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (18, 15)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (19, 16)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (20, 17)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (21, 18)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (22, 18)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (23, 18)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (24, 18)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (25, 18)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (26, 19)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (27, 20)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (28, 21)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (29, 22)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (30, 23)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (31, 24)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (32, 25)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (33, 26)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (34, 26)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (35, 27)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (36, 27)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (37, 28)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (38, 29)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (39, 30)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (40, 31)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (41, 32)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (42, 33)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (43, 34)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (44, 35)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (45, 35)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (46, 35)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (47, 35)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (48, 36)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (49, 37)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (50, 38)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (51, 39)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (52, 40)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (53, 41)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (54, 42)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (55, 43)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (56, 44)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (57, 45)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (58, 46)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (59, 47)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (60, 48)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (61, 49)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (62, 50)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (63, 51)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (64, 52)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (65, 52)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (66, 52)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (67, 52)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (68, 52)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (69, 53)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (70, 54)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (71, 55)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (72, 56)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (73, 57)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (74, 58)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (75, 59)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (76, 60)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (77, 60)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (78, 60)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (79, 26)
INSERT [dbo].[Waypoint] ([Id], [StationId]) VALUES (80, 27)
SET IDENTITY_INSERT [dbo].[Waypoint] OFF
SET IDENTITY_INSERT [dbo].[Worker] ON 

INSERT [dbo].[Worker] ([Id], [FirstName], [MiddleName], [LastName], [LengthOfService], [Salary]) VALUES (1, N'Андрей', N'Андрей', N'Андрей', 1, 400.0000)
INSERT [dbo].[Worker] ([Id], [FirstName], [MiddleName], [LastName], [LengthOfService], [Salary]) VALUES (2, N'cond1', N'cond1', N'cond1', 1, 200.0000)
INSERT [dbo].[Worker] ([Id], [FirstName], [MiddleName], [LastName], [LengthOfService], [Salary]) VALUES (3, N'cond2', N'cond2', N'cond2', 1, 200.0000)
INSERT [dbo].[Worker] ([Id], [FirstName], [MiddleName], [LastName], [LengthOfService], [Salary]) VALUES (4, N'cond3', N'cond3', N'cond3', 1, 200.0000)
INSERT [dbo].[Worker] ([Id], [FirstName], [MiddleName], [LastName], [LengthOfService], [Salary]) VALUES (5, N'driver2', N'driver2', N'driver2', 23, 1234.0000)
INSERT [dbo].[Worker] ([Id], [FirstName], [MiddleName], [LastName], [LengthOfService], [Salary]) VALUES (6, N'cond4', N'cond4', N'cond4', 12, 12.0000)
INSERT [dbo].[Worker] ([Id], [FirstName], [MiddleName], [LastName], [LengthOfService], [Salary]) VALUES (7, N'cond5', N'cond5', N'cond5', 3, 200.0000)
SET IDENTITY_INSERT [dbo].[Worker] OFF
ALTER TABLE [dbo].[RoadNet]  WITH CHECK ADD  CONSTRAINT [FK_RoadNet_Waypoint] FOREIGN KEY([WaypointId])
REFERENCES [dbo].[Waypoint] ([Id])
GO
ALTER TABLE [dbo].[RoadNet] CHECK CONSTRAINT [FK_RoadNet_Waypoint]
GO
ALTER TABLE [dbo].[RoadNet]  WITH CHECK ADD  CONSTRAINT [FK_RoadNet_Waypoint_Next] FOREIGN KEY([NextWaypointId])
REFERENCES [dbo].[Waypoint] ([Id])
GO
ALTER TABLE [dbo].[RoadNet] CHECK CONSTRAINT [FK_RoadNet_Waypoint_Next]
GO
ALTER TABLE [dbo].[RoadNet]  WITH CHECK ADD  CONSTRAINT [FK_RoadNet_Waypoint_Prev] FOREIGN KEY([PrevWaypointId])
REFERENCES [dbo].[Waypoint] ([Id])
GO
ALTER TABLE [dbo].[RoadNet] CHECK CONSTRAINT [FK_RoadNet_Waypoint_Prev]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Station_End] FOREIGN KEY([EndStationId])
REFERENCES [dbo].[Station] ([Id])
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [FK_Route_Station_End]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Station_Start] FOREIGN KEY([StartStationId])
REFERENCES [dbo].[Station] ([Id])
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [FK_Route_Station_Start]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Train] FOREIGN KEY([TrainId])
REFERENCES [dbo].[Train] ([Id])
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [FK_Route_Train]
GO
ALTER TABLE [dbo].[SegmentLength]  WITH CHECK ADD  CONSTRAINT [FK_SegmentLength_Waypoint_End] FOREIGN KEY([EndWaypointId])
REFERENCES [dbo].[Waypoint] ([Id])
GO
ALTER TABLE [dbo].[SegmentLength] CHECK CONSTRAINT [FK_SegmentLength_Waypoint_End]
GO
ALTER TABLE [dbo].[SegmentLength]  WITH CHECK ADD  CONSTRAINT [FK_SegmentLength_Waypoint_Start] FOREIGN KEY([StartWaypointId])
REFERENCES [dbo].[Waypoint] ([Id])
GO
ALTER TABLE [dbo].[SegmentLength] CHECK CONSTRAINT [FK_SegmentLength_Waypoint_Start]
GO
ALTER TABLE [dbo].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Passenger] FOREIGN KEY([PassengerId])
REFERENCES [dbo].[Passenger] ([Id])
GO
ALTER TABLE [dbo].[Ticket] CHECK CONSTRAINT [FK_Ticket_Passenger]
GO
ALTER TABLE [dbo].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Route] FOREIGN KEY([RouteId])
REFERENCES [dbo].[Route] ([Id])
GO
ALTER TABLE [dbo].[Ticket] CHECK CONSTRAINT [FK_Ticket_Route]
GO
ALTER TABLE [dbo].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Station_In] FOREIGN KEY([InStationId])
REFERENCES [dbo].[Station] ([Id])
GO
ALTER TABLE [dbo].[Ticket] CHECK CONSTRAINT [FK_Ticket_Station_In]
GO
ALTER TABLE [dbo].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Station_Out] FOREIGN KEY([OutStationId])
REFERENCES [dbo].[Station] ([Id])
GO
ALTER TABLE [dbo].[Ticket] CHECK CONSTRAINT [FK_Ticket_Station_Out]
GO
ALTER TABLE [dbo].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_Wagon] FOREIGN KEY([WagonId])
REFERENCES [dbo].[Wagon] ([Id])
GO
ALTER TABLE [dbo].[Ticket] CHECK CONSTRAINT [FK_Ticket_Wagon]
GO
ALTER TABLE [dbo].[Train]  WITH CHECK ADD  CONSTRAINT [FK_Train_Station] FOREIGN KEY([CurrentStationId])
REFERENCES [dbo].[Station] ([Id])
GO
ALTER TABLE [dbo].[Train] CHECK CONSTRAINT [FK_Train_Station]
GO
ALTER TABLE [dbo].[Train]  WITH CHECK ADD  CONSTRAINT [FK_Train_Worker] FOREIGN KEY([DriverId])
REFERENCES [dbo].[Worker] ([Id])
GO
ALTER TABLE [dbo].[Train] CHECK CONSTRAINT [FK_Train_Worker]
GO
ALTER TABLE [dbo].[Wagon]  WITH CHECK ADD  CONSTRAINT [FK_Wagon_Train] FOREIGN KEY([TrainId])
REFERENCES [dbo].[Train] ([Id])
GO
ALTER TABLE [dbo].[Wagon] CHECK CONSTRAINT [FK_Wagon_Train]
GO
ALTER TABLE [dbo].[Wagon]  WITH CHECK ADD  CONSTRAINT [FK_Wagon_Worker] FOREIGN KEY([ConductorId])
REFERENCES [dbo].[Worker] ([Id])
GO
ALTER TABLE [dbo].[Wagon] CHECK CONSTRAINT [FK_Wagon_Worker]
GO
ALTER TABLE [dbo].[Waypoint]  WITH CHECK ADD  CONSTRAINT [FK_Waypoint_Station] FOREIGN KEY([StationId])
REFERENCES [dbo].[Station] ([Id])
GO
ALTER TABLE [dbo].[Waypoint] CHECK CONSTRAINT [FK_Waypoint_Station]
GO
/****** Object:  Trigger [dbo].[CheckPassengerCount]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create trigger [dbo].[CheckPassengerCount]
on [dbo].[Ticket]
after insert
as
declare @wagonId int, @passCount int, @maxPassCount int

select @wagonId = WagonId from inserted

select @passCount = w.PassengerCount, @maxPassCount = w.MaxPassengerCount from Wagon as w
where w.Id = @wagonId

if @passCount >= @maxPassCount
begin
	rollback transaction	
end
else
begin
	update Wagon set PassengerCount = @passCount + 1
	where Wagon.Id = @wagonId
end


GO
/****** Object:  Trigger [dbo].[DecPassengerCount]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create trigger [dbo].[DecPassengerCount]
on [dbo].[Ticket]
after delete
as
declare @wagonId int, @passCount int, @maxPassCount int

select @wagonId = WagonId from inserted

select @passCount = w.PassengerCount, @maxPassCount = w.MaxPassengerCount from Wagon as w
where w.Id = @wagonId

if @passCount >= 1
begin
	update Wagon set PassengerCount = @passCount - 1
	where Wagon.Id = @wagonId
end

GO
/****** Object:  Trigger [dbo].[CheckWagonCount]    Script Date: 15.05.2014 15:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [dbo].[CheckWagonCount]
on [dbo].[Wagon]
after insert
as
declare @trainId int, @wagonsCount int, @maxWagonsCount int

select @trainId = TrainId from inserted

select @wagonsCount = count(*) from Wagon as w
where w.TrainId = @trainId

select @maxWagonsCount = t.MaxWagonCount from Train as t
where t.Id = @trainId

if @wagonsCount >= @maxWagonsCount
begin
	rollback transaction	
end



GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Station"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 102
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Waypoint"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 102
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'WaypointStation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'WaypointStation'
GO
USE [master]
GO
ALTER DATABASE [Railway] SET  READ_WRITE 
GO
