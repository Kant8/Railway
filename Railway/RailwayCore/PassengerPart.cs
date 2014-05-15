using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RailwayCore
{
    public partial class Passenger
    {
        public override string ToString()
        {
            return String.Format("{0} {1} {2} - {3}", LastName, FirstName, MiddleName, IdentityNumber);
        }
    }
}
