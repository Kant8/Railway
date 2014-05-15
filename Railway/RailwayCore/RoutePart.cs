using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RailwayCore
{
    public partial class Route
    {
        public override string ToString()
        {
            return String.Format("{0} ({1}) - {2} ({3})",
                StartStation.Name,
                StartTime.ToShortTimeString(),
                EndStation.Name,
                EndTime.HasValue ? EndTime.Value.ToShortTimeString() : StartTime.ToShortTimeString());
        }
    }
}
