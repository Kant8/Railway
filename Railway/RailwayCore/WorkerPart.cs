using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RailwayCore
{
    public partial class Worker
    {
        public override string ToString()
        {
            return String.Format("{0} {1} {2} - ${3}, {4} лет", LastName, FirstName, MiddleName, Salary, LengthOfService);
        }
    }
}
