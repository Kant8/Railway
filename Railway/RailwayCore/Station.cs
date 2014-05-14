
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
    
public partial class Station
{

    public Station()
    {

        this.Trains = new HashSet<Train>();

        this.Waypoints = new HashSet<Waypoint>();

        this.InTickets = new HashSet<Ticket>();

        this.OutTickets = new HashSet<Ticket>();

        this.EndRoutes = new HashSet<Route>();

        this.StartRoutes = new HashSet<Route>();

    }


    public int Id { get; set; }

    public string Name { get; set; }



    public virtual ICollection<Train> Trains { get; set; }

    public virtual ICollection<Waypoint> Waypoints { get; set; }

    public virtual ICollection<Ticket> InTickets { get; set; }

    public virtual ICollection<Ticket> OutTickets { get; set; }

    public virtual ICollection<Route> EndRoutes { get; set; }

    public virtual ICollection<Route> StartRoutes { get; set; }

}

}
