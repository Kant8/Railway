using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RailwayCore
{
    public partial class Ticket
    {
        public override string ToString()
        {
            return String.Format("{0} ({1}) - {2} ({3})",
                InStation.Name,
                InTime.HasValue ? InTime.Value.ToShortTimeString() : "---",
                OutStation.Name,
                OutTime.HasValue ? OutTime.Value.ToShortTimeString() : "---");
        }

        public string ToLongString()
        {
            var routeStr = Route.ToString();

            var sb = new StringBuilder();

            sb.AppendLine("Маршрут: " + routeStr);
            sb.AppendLine("Отправление: " + InStation.Name + " в " + (InTime.HasValue ? InTime.Value.ToShortTimeString() : "---"));
            sb.AppendLine("Прибытие: " + OutStation.Name + " в " + (OutTime.HasValue ? OutTime.Value.ToShortTimeString() : "---"));
            sb.AppendLine("Поезд: " + Route.Train.Name);
            sb.AppendLine("Вагон: " + Wagon.Id);
            sb.AppendLine("Длина поездки: " + Length);
            sb.AppendLine("Стоимость: " + Price);

            return sb.ToString();
        }
    }
}
