
//------------------------------------------------------------------------------
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
    using System.Collections.Generic;
    
public partial class RoadNet
{

    public int Id { get; set; }

    public int WaypointId { get; set; }

    public Nullable<int> PrevWaypointId { get; set; }

    public Nullable<int> NextWaypointId { get; set; }



    public virtual Waypoint Waypoint { get; set; }

    public virtual Waypoint NextWaypoint { get; set; }

    public virtual Waypoint PrevWaypoint { get; set; }

}

}
