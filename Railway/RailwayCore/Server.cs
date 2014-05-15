using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RailwayCore
{
    public class Server
    {
        public static RailwayContext Context { get; private set; }

        public static decimal PricePerLength { get; set; }

        static Server()
        {
            Context = new RailwayContext();
            Context.Database.Connection.Open();

            PricePerLength = 2;
        }

        public void Foo()
        {
            var temp = "";
            var stations = Context.Stations.ToList();
            foreach (var station in stations)
            {
                temp += station.Name + Environment.NewLine;
            }


            var minskP = stations.First(s => s.Name == "Минск-Пассажирский");
            var orshaZ = stations.First(s => s.Name == "Орша-Западная");

            var step = stations.First(s => s.Name == "Степянка");
            var jod = stations.First(s => s.Name == "Жодино");



           

            //var route = new Route();
            //route.StartStation = minskP;
            //route.EndStation = orshaZ;
            //route.StartTime = CreateTrainTime(12, 00);
            //route.EndTime = route.StartTime;
            //route.Train = CreateTrain(minskP);

            //Context.Routes.Add(route);
            //Context.SaveChanges();
            //FillRoute(route);
            //Context.SaveChanges();

            var route = Context.Routes.First();

            var passenger = new Passenger
            {
                FirstName = "Pass1",
                MiddleName = "Pass1",
                LastName = "Pass1",
                IdentityNumber = "12345"
            };

            var ticket = new Ticket();
            ticket.Route = route;
            ticket.Passenger = passenger;
            ticket.Price = 123;
            ticket.InStation = step;
            ticket.OutStation = jod;
            ticket.BuyDate = DateTime.Now;
            ticket.Wagon = route.Train.Wagons.First();
            Context.Tickets.Add(ticket);
            Context.SaveChanges();


            FillTicket(ticket);

            GetNetSegmentsByStationId(1);
            GetStationsOnSegmentsByStationId(1);
            GetLengthsBetweenStations(3, 3);
        }

        private Train CreateTrain(Station startStation)
        {
            var driver = new Worker
            {
                FirstName = "Андрей",
                MiddleName = "Андрей",
                LastName = "Андрей",
                Salary = 400m,
                LengthOfService = 1
            };

            var cond1 = new Worker
            {
                FirstName = "cond1",
                MiddleName = "cond1",
                LastName = "cond1",
                Salary = 200,
                LengthOfService = 1
            };
            var cond2 = new Worker
            {
                FirstName = "cond2",
                MiddleName = "cond2",
                LastName = "cond2",
                Salary = 200,
                LengthOfService = 1
            };
            var cond3 = new Worker
            {
                FirstName = "cond3",
                MiddleName = "cond3",
                LastName = "cond3",
                Salary = 200,
                LengthOfService = 1
            };


            var train = new Train
            {
                Name = "First Train",
                CurrentStation = startStation,
                Driver = driver,
                Velocity = 60
            };

            var wagon1 = new Wagon {MaxPassengerCount = 3, Conductor = cond1};
            var wagon2 = new Wagon { MaxPassengerCount = 3, Conductor = cond2 };
            var wagon3 = new Wagon { MaxPassengerCount = 3, Conductor = cond3 };

            train.Wagons.Add(wagon1); train.Wagons.Add(wagon2); train.Wagons.Add(wagon3);

            return train;
        }

        public DateTime CreateTrainTime(int hours, int minutes)
        {
            var today = DateTime.Today;
            return new DateTime(today.Year, today.Month, today.Day, hours, minutes, 0);
        }

        public DateTime CreateTrainTime(string hourMinStr)
        {
            var parts = hourMinStr.Split(':');
            return CreateTrainTime(Int32.Parse(parts[0]), Int32.Parse(parts[1]));
        }

        public static List<List<GetNetSegmentsByStationId_Result>> GetNetSegmentsByStationId(int stationId)
        {
            var connection = Context.Database.Connection;
            var cmd = connection.CreateCommand();
            cmd.CommandText = "dbo.GetNetSegmentsByStationId";
            cmd.CommandType = CommandType.StoredProcedure;
            var param = new SqlParameter
            {
                ParameterName = "@StationId",
                SqlDbType = SqlDbType.Int,
                Direction = ParameterDirection.Input,
                Value = stationId
            };
            cmd.Parameters.Add(param);

            var result = new List<List<GetNetSegmentsByStationId_Result>>();
            var reader = cmd.ExecuteReader();
            do
            {
                var chain = ((IObjectContextAdapter)Context).ObjectContext
                    .Translate<GetNetSegmentsByStationId_Result>(reader);
                result.Add(chain.ToList());
            } while (reader.NextResult());

            return result;
        }

        public static List<List<GetStationsOnSegmentsByStationId_Result>> GetStationsOnSegmentsByStationId(int stationId)
        {
            var connection = Context.Database.Connection;
            var cmd = connection.CreateCommand();
            cmd.CommandText = "dbo.GetStationsOnSegmentsByStationId";
            cmd.CommandType = CommandType.StoredProcedure;
            var param = new SqlParameter
            {
                ParameterName = "@StationId",
                SqlDbType = SqlDbType.Int,
                Direction = ParameterDirection.Input,
                Value = stationId
            };
            cmd.Parameters.Add(param);

            var result = new List<List<GetStationsOnSegmentsByStationId_Result>>();
            var reader = cmd.ExecuteReader();
            do
            {
                var chain = ((IObjectContextAdapter)Context).ObjectContext
                    .Translate<GetStationsOnSegmentsByStationId_Result>(reader);
                result.Add(chain.ToList());
            } while (reader.NextResult());

            return result;
        }

        public static int GetSegmentLength(DataTable segment)
        {
            var connection = Context.Database.Connection;
            var cmd = connection.CreateCommand();
            cmd.CommandText = "dbo.GetSegmentLengths";
            cmd.CommandType = CommandType.StoredProcedure;
            var param = new SqlParameter
            {
                ParameterName = "@Segment",
                SqlDbType = SqlDbType.Structured,
                Direction = ParameterDirection.Input,
                Value = segment
            };
            cmd.Parameters.Add(param);

            var reader = cmd.ExecuteReader();
            var chain = ((IObjectContextAdapter)Context).ObjectContext
                .Translate<GetSegmentLengths_Result>(reader).ToList();
            int resLength = chain.Sum(c => c.Length);

            return resLength;
        }

        public static int GetLengthsBetweenStations(int startStationId, int endStationId)
        {
            List<GetNetSegmentsByStationId_Result> resSegment = GetSegmentForStations(startStationId, endStationId);
            if (resSegment == null) return 0;

            var lengths = resSegment
                .Join(Context.SegmentLengths, s => s.WaypointId, sl => sl.StartWaypointId, (s, sl) => sl);

            var startStationLengths = lengths.Join(Context.WaypointStations, l => l.StartWaypointId, ws => ws.WaypointId,
                (l, ws) => new {ws.StationId, ws.StationName, l.Length, l.EndWaypointId});

            var stationLengths = startStationLengths.Join(Context.WaypointStations, l => l.EndWaypointId, ws => ws.WaypointId,
                (l, ws) => new
                {
                    StartStatioinId = l.StationId,
                    StartStationName = l.StationName,
                    EndStationId = ws.StationId,
                    EndStationName = ws.StationName,
                    l.Length
                }).ToList();

            return stationLengths.Sum(s => s.Length);

            //var segmentTable = new DataTable();
            //segmentTable.Columns.AddRange(new[]
            //{
            //    new DataColumn("Id", typeof (int)) {AllowDBNull =true}, new DataColumn("PrevWaypointId", typeof (int)){AllowDBNull =true},
            //    new DataColumn("WaypointId", typeof (int)){AllowDBNull =true}, new DataColumn("NextWaypointId", typeof (int)){AllowDBNull =true}
            //});

            //foreach (var segment in resSegment.TakeWhile(segment => segment.Id != end.Id).ToList())
            //{
            //    segmentTable.Rows.Add(segment.Id, segment.PrevWaypointId, segment.WaypointId, segment.NextWaypointId);
            //}

            //return GetSegmentLength(segmentTable);
        }

        public static List<GetNetSegmentsByStationId_Result> GetFullSegmentForStations(int startStationId, int endStationId)
        {
            var segments = GetNetSegmentsByStationId(startStationId);

            var endWaypoints = GetWaypointsForStation(endStationId);

            List<GetNetSegmentsByStationId_Result> resSegment = null;
            foreach (var segment in segments)
            {
                var end = segment.FirstOrDefault(s => s.WaypointId != null && endWaypoints.Contains(s.WaypointId.Value));
                if (end != null)
                {
                    resSegment = segment;
                    break;
                }
            }
            return resSegment;
        }

        public static List<GetNetSegmentsByStationId_Result> GetSegmentForStations(int startStationId, int endStationId)
        {
            var segments = GetNetSegmentsByStationId(startStationId);

            var startWaypoints = GetWaypointsForStation(startStationId);
            var endWaypoints = GetWaypointsForStation(endStationId);

            List<GetNetSegmentsByStationId_Result> resSegment = null;
            foreach (var segment in segments)
            {
                var end = segment.FirstOrDefault(s => s.WaypointId != null && endWaypoints.Contains(s.WaypointId.Value));
                if (end != null)
                {
                    resSegment = segment;
                    break;
                }
            }

            if (resSegment == null) return null;

            var startWaypoint = startWaypoints.Intersect(resSegment.Select(s => s.WaypointId != null ? s.WaypointId.Value : 0)).First();
            var endWaypoint = endWaypoints.Intersect(resSegment.Select(s => s.WaypointId != null ? s.WaypointId.Value : 0)).First();

            var subStartSeg = resSegment.SkipWhile(s => s.WaypointId != startWaypoint).ToList();

            var reversed = subStartSeg.AsEnumerable().Reverse();
            var subSegEnd = reversed.TakeWhile(s => s.WaypointId != endWaypoint).Reverse().ToList();
                

            return subStartSeg.Except(subSegEnd).ToList();
        }

        public static List<int> GetWaypointsForStation(int stationId)
        {
            var segments = GetNetSegmentsByStationId(stationId);

            var result = new List<int>();
            foreach (var segment in segments)
            {
                var waypointId = segment.First().WaypointId;
                if (waypointId != null) result.Add(waypointId.Value);
            }

            return result.Distinct().ToList();
        }

        public static void GetStartEndWaypointsForRoute(int routeId, out int startWaypointId, out int endWaypointId)
        {
            startWaypointId = 0;
            endWaypointId = 0;
            var route = Context.Routes.FirstOrDefault(r => r.Id == routeId);
            if (route == null) return;

            var startSegments = GetNetSegmentsByStationId(route.StartStationId);
            var endWaypoints = GetWaypointsForStation(route.EndStationId);

            List<GetNetSegmentsByStationId_Result> resSegment = null;
            foreach (var segment in startSegments)
            {
                var end = segment.FirstOrDefault(s => s.WaypointId != null && endWaypoints.Contains(s.WaypointId.Value));
                if (end != null)
                {
                    resSegment = segment;
                    break;
                }
            }
            if (resSegment == null) return;

            var startId = resSegment.First().WaypointId;
            if (startId != null) startWaypointId = startId.Value;
            var endId = resSegment.Last().WaypointId;
            if (endId != null) endWaypointId = endId.Value;
        }

        public static DateTime GetTimeTillStationOnRoute(int routeId, int stationId)
        {
            var route = Context.Routes.FirstOrDefault(r => r.Id == routeId);
            if (route == null) throw new ArgumentException("No such route");

            var length = GetLengthsBetweenStations(route.StartStationId, stationId);
            if (length == 0) return route.StartTime;

            double travelHours = length/route.Train.Velocity;

            return route.StartTime.AddHours(travelHours);
        }

        public static void FillTicket(Ticket ticket)
        {
            var route = ticket.Route;
            var inTime = GetTimeTillStationOnRoute(route.Id, ticket.InStationId);
            var outTime = GetTimeTillStationOnRoute(route.Id, ticket.OutStationId);

            ticket.Length = GetLengthsBetweenStations(ticket.InStationId, ticket.OutStationId);
            ticket.Price = CalcCost(ticket.InStationId, ticket.OutStationId);
            ticket.InTime = inTime;
            ticket.OutTime = outTime;
        }

        public static void FillRoute(Route route)
        {
            var endTime = GetTimeTillStationOnRoute(route.Id, route.EndStationId);
            route.EndTime = endTime;
        }

        public static List<Waypoint> CreateNetSegment(List<Station> stations)
        {
            var waypoints = stations.Select(station => new Waypoint {StationId = station.Id}).ToList();

            var segments = new List<RoadNet>();
            segments.Add(new RoadNet
            {
                PrevWaypoint = null,
                Waypoint = waypoints[0],
                NextWaypoint = waypoints[1]
            });
            for (int i = 1; i < waypoints.Count - 1; i++)
            {
                var netSeg = new RoadNet();
                netSeg.PrevWaypoint = waypoints[i - 1];
                netSeg.Waypoint = waypoints[i];
                netSeg.NextWaypoint = waypoints[i + 1];
            }
            segments.Add(new RoadNet
            {
                PrevWaypoint = waypoints[waypoints.Count - 2],
                Waypoint = waypoints[waypoints.Count - 1],
                NextWaypoint = null
            });

            Context.RoadNets.AddRange(segments);
            Context.SaveChanges();

            return waypoints;
        }

        public static List<Station> GetStationsFromSegments(List<List<GetStationsOnSegmentsByStationId_Result>> segments)
        {
            var res = new List<Station>();
            foreach (var segment in segments)
            {
                res.AddRange(segment.Select(part => Context.Stations.Find(part.StationId)));
            }
            return res.Distinct().ToList();
        }

        public static void CreateSegmentLengths(List<Waypoint> waypoints, List<int> lengths)
        {
            for (int i = 0; i < waypoints.Count - 1; i++)
            {
                var segLength = new SegmentLength
                {
                    StartWaypoint = waypoints[i],
                    EndWaypoint = waypoints[i + 1],
                    Length = lengths[i]
                };
                Context.SegmentLengths.Add(segLength);
            }
            Context.SaveChanges();
        }

        public static List<Station> GetJunktionStations()
        {
            var junkWaypoints = Context.RoadNets.Where(w => w.PrevWaypoint == null || w.NextWaypoint == null);
            var junkStationsId = Context.WaypointStations
                .Join(junkWaypoints, ws => ws.WaypointId, jw => jw.WaypointId, (ws, jw) => ws.StationId).Distinct().ToList();

            var result = junkStationsId.Select(jsi => Context.Stations.Find(jsi)).ToList();
            return result;
        }

        public static List<Station> GetJunktionStationPairs(Station station)
        {
            var junkStations = GetJunktionStations().Except(new[] {station});

            var segments = GetStationsOnSegmentsByStationId(station.Id);

            var res = new List<Station>();
            foreach (var segment in segments)
            {
                var ws = segment.Where(seg =>
                {
                    var js = junkStations.FirstOrDefault(st => st.Id == seg.StationId);
                    return js != null;
                });
                res.AddRange(ws.Select(w => junkStations.First(js => js.Id == w.StationId)));
            }
            return res;
        }

        public static List<Train> GetFreeTrains()
        {
            return Context.Trains.Where(t => t.Routes.Count == 0).ToList();
        }

        public static List<Wagon> GetFreeWagons()
        {
            return Context.Wagons.Where(w => w.Train == null).ToList();
        }

        public static List<Worker> GetFreeWorkers()
        {
            return Context.Workers.Where(w => w.Trains.Count == 0 && w.Wagons.Count == 0).ToList();
        }

        public static decimal CalcCost(int startStationId, int endStationId)
        {
            var length = GetLengthsBetweenStations(startStationId, endStationId);
            return length*PricePerLength;
        }

        public static List<Station> GetStationsBetweenStations(int startStationId, int endStationId)
        {
            var segment = GetSegmentForStations(startStationId, endStationId);

            var result = new List<Station>();

            var stationIds = segment.Join(Context.WaypointStations, s => s.WaypointId, ws => ws.WaypointId, (s, ws) => ws.StationId);

            return stationIds.Select(sid => Context.Stations.Find(sid)).ToList();
        }

    }
}
