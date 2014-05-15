using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RailwayCore
{
    public partial class Wagon
    {
        public override string ToString()
        {
            return String.Format("{0} - занято {1}/{2}", Id, PassengerCount, MaxPassengerCount);
        }
    }
}
