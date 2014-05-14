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
    
    public partial class Train
    {
        public Train()
        {
            this.Wagons = new HashSet<Wagon>();
            this.Routes = new HashSet<Route>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public int MaxWagonCount { get; set; }
        public Nullable<int> DriverId { get; set; }
        public int CurrentStationId { get; set; }
        public double Velocity { get; set; }
    
        public virtual Station CurrentStation { get; set; }
        public virtual Worker Driver { get; set; }
        public virtual ICollection<Wagon> Wagons { get; set; }
        public virtual ICollection<Route> Routes { get; set; }
    }
}
