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
        }

        public static List<List<GetNetSegmentsByStationId_Result>> GetNetSegmentsByStationId(int stationId)
        {
            var connection = Context.Database.Connection;
            var cmd = connection.CreateCommand();
            cmd.CommandText = "dbo.GetNetSegmentsByStationId";
            cmd.CommandType = CommandType.StoredProcedure;
            var param = new SqlParameter();
            param.ParameterName = "@StationId";
            param.SqlDbType = SqlDbType.Int;
            param.Direction = ParameterDirection.Input;
            param.Value = stationId;
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
            var param = new SqlParameter();
            param.ParameterName = "@StationId";
            param.SqlDbType = SqlDbType.Int;
            param.Direction = ParameterDirection.Input;
            param.Value = stationId;
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
    }
}
