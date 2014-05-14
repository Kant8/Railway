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

            GetNetSegmentsByStationId(1);
            GetStationsOnSegmentsByStationId(1);
            GetLengthsBetweenStations(3, 3);
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
    }
}
