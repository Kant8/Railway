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
    
    public partial class Route
    {
        public Route()
        {
            this.Tickets = new HashSet<Ticket>();
        }
    
        public int Id { get; set; }
        public int StartStation { get; set; }
        public System.DateTime StartTime { get; set; }
        public int EndStation { get; set; }
        public System.DateTime EndTime { get; set; }
    
        public virtual ICollection<Ticket> Tickets { get; set; }
    }
}
