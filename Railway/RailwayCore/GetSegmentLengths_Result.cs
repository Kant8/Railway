using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RailwayCore
{
    public class GetSegmentLengths_Result
    {
        public int StartStationId { get; set; }
        public string StartStationName { get; set; }
        public int EndStationId { get; set; }
        public string EndStationName { get; set; }
        public int Length { get; set; }

    }
}
