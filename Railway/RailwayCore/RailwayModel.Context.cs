﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace RailwayCore
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class RailwayContext : DbContext
    {
        public RailwayContext()
            : base("name=RailwayContext")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<Passenger> Passengers { get; set; }
        public virtual DbSet<RoadNet> RoadNets { get; set; }
        public virtual DbSet<Route> Routes { get; set; }
        public virtual DbSet<Station> Stations { get; set; }
        public virtual DbSet<Ticket> Tickets { get; set; }
        public virtual DbSet<Train> Trains { get; set; }
        public virtual DbSet<Wagon> Wagons { get; set; }
        public virtual DbSet<Waypoint> Waypoints { get; set; }
        public virtual DbSet<Worker> Workers { get; set; }
        public virtual DbSet<WaypointStation> WaypointStations { get; set; }
        public virtual DbSet<SegmentLength> SegmentLengths { get; set; }
    
        public virtual int ClearRoadNet()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("ClearRoadNet");
        }
    
        public virtual ObjectResult<GetNetSegment_Result> GetNetSegment(Nullable<int> startWaypointId, Nullable<bool> forward)
        {
            var startWaypointIdParameter = startWaypointId.HasValue ?
                new ObjectParameter("StartWaypointId", startWaypointId) :
                new ObjectParameter("StartWaypointId", typeof(int));
    
            var forwardParameter = forward.HasValue ?
                new ObjectParameter("Forward", forward) :
                new ObjectParameter("Forward", typeof(bool));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetNetSegment_Result>("GetNetSegment", startWaypointIdParameter, forwardParameter);
        }
    
        public virtual ObjectResult<GetNetSegmentsByStationId_Result> GetNetSegmentsByStationId(Nullable<int> stationId)
        {
            var stationIdParameter = stationId.HasValue ?
                new ObjectParameter("StationId", stationId) :
                new ObjectParameter("StationId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetNetSegmentsByStationId_Result>("GetNetSegmentsByStationId", stationIdParameter);
        }
    
        public virtual ObjectResult<GetStationsOnSegmentsByStationId_Result> GetStationsOnSegmentsByStationId(Nullable<int> stationId)
        {
            var stationIdParameter = stationId.HasValue ?
                new ObjectParameter("StationId", stationId) :
                new ObjectParameter("StationId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetStationsOnSegmentsByStationId_Result>("GetStationsOnSegmentsByStationId", stationIdParameter);
        }
    
        public virtual ObjectResult<GetStationsOnSegmentsByStationIdFull_Result> GetStationsOnSegmentsByStationIdFull(Nullable<int> stationId)
        {
            var stationIdParameter = stationId.HasValue ?
                new ObjectParameter("StationId", stationId) :
                new ObjectParameter("StationId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetStationsOnSegmentsByStationIdFull_Result>("GetStationsOnSegmentsByStationIdFull", stationIdParameter);
        }
    
        public virtual int GetSegmentLengths()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("GetSegmentLengths");
        }
    }
}
