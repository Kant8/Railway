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

        static Server()
        {
            Context = new RailwayContext();
            Context.Database.Connection.Open();
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



           

            //var route = new Route();
            //route.StartStation = minskP;
            //route.EndStation = orshaZ;
            //route.StartTime = CreateTrainTime(12, 00);
            //route.EndTime = route.StartTime;
            //route.Train = CreateTrain(minskP);

            //Context.Routes.Add(route);
            //Context.SaveChanges();

            var route = Context.Routes.First();

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
                .Translate<GetSegmentLengths_Result>(reader);
            int resLength = chain.Sum(c => c.Length);

            return resLength;
        }

        public static int GetLengthsBetweenStations(int startStationId, int endStationId)
        {
            var segments = GetNetSegmentsByStationId(startStationId);

            var endWaypoints = GetWaypointsForStation(endStationId);

            GetNetSegmentsByStationId_Result end = null;
            List<GetNetSegmentsByStationId_Result> resSegment = null;
            foreach (var segment in segments)
            {
                end = segment.FirstOrDefault(s => s.WaypointId != null && endWaypoints.Contains(s.WaypointId.Value));
                if (end != null)
                {
                    resSegment = segment;
                    break;
                }
            }
            if (resSegment == null) return 0;

            var segmentTable = new DataTable();
            segmentTable.Columns.AddRange(new[]
            {
                new DataColumn("Id", typeof (int)) {AllowDBNull =true}, new DataColumn("PrevWaypointId", typeof (int)){AllowDBNull =true},
                new DataColumn("WaypointId", typeof (int)){AllowDBNull =true}, new DataColumn("NextWaypointId", typeof (int)){AllowDBNull =true}
            });

            foreach (var segment in resSegment.TakeWhile(segment => segment.Id != end.Id))
            {
                segmentTable.Rows.Add(segment.Id, segment.PrevWaypointId, segment.WaypointId, segment.NextWaypointId);
            }

            return GetSegmentLength(segmentTable);
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

            GetNetSegmentsByStationId_Result end = null;
            List<GetNetSegmentsByStationId_Result> resSegment = null;
            foreach (var segment in startSegments)
            {
                end = segment.FirstOrDefault(s => s.WaypointId != null && endWaypoints.Contains(s.WaypointId.Value));
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

            double travelHours = (double) length/route.Train.Velocity;

            return route.StartTime.AddHours(travelHours);
        }

        public static void FillTicket(Ticket ticket)
        {
            var route = ticket.Route;
            var inTime = GetTimeTillStationOnRoute(route.Id, ticket.InStationId);
            var outTime = GetTimeTillStationOnRoute(route.Id, ticket.OutStationId);

            ticket.Length = GetLengthsBetweenStations(ticket.InStationId, ticket.OutStationId);
            ticket.InTime = inTime;
            ticket.OutTime = outTime;
        }
    }
}
