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
    
    public partial class Wagon
    {
        public Wagon()
        {
            this.Tickets = new HashSet<Ticket>();
        }
    
        public int Id { get; set; }
        public int MaxPassengerCount { get; set; }
        public int PassengerCount { get; set; }
        public Nullable<int> TrainId { get; set; }
        public Nullable<int> ConductorId { get; set; }
    
        public virtual ICollection<Ticket> Tickets { get; set; }
        public virtual Train Train { get; set; }
        public virtual Worker Worker { get; set; }
    }
}
