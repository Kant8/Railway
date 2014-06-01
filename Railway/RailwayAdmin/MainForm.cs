using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using RailwayCore;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace RailwayAdmin
{
    public partial class MainForm : Form
    {
        public static Server Server { get; private set; }

        public MainForm()
        {
            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            Server = new Server();
            RefreshDataSources();

            AppDomain.CurrentDomain.UnhandledException += UnhandledExceptionsHandler;
        }

        private void UnhandledExceptionsHandler(object sender, UnhandledExceptionEventArgs e)
        {
            MessageBox.Show(((Exception)e.ExceptionObject).Message);
        }

        public void RefreshDataSources()
        {
            var stations = Server.Context.Stations.ToList();
            bindingSourceStations.DataSource = stations;
            bindingSourceSegmentStations.DataSource =
                Server.GetStationsFromSegments(Server.GetStationsOnSegmentsByStationId(stations.First().Id));

            var junkStations = Server.GetJunktionStations();
            bindingSourceJunkStations.DataSource = junkStations;
            bindingSourceJunkStationPairs.DataSource = Server.GetJunktionStationPairs(junkStations.First());

            bindingSourceTrains.DataSource = Server.Context.Trains.ToList();
            bindingSourceRouteTrains.DataSource = Server.GetFreeTrains();

            bindingSourceFreeWagons.DataSource = Server.GetFreeWagons();

            bindingSourceFreeWorkers.DataSource = Server.GetFreeWorkers();

            bindingSourceWorkers.DataSource = Server.Context.Workers.ToList();

            bindingSourceRoutes.DataSource = Server.Context.Routes.ToList();

            bindingSourcePassengers.DataSource = Server.Context.Passengers.ToList();
        }

        private void buttonAddStation_Click(object sender, EventArgs e)
        {
            var newStationName = textBoxNewStationName.Text;
            if (String.IsNullOrWhiteSpace(newStationName))
            {
                MessageBox.Show("Введите название станции");
                return;
            }

            var station = new Station {Name = newStationName};
            Server.Context.Stations.Add(station);
            Server.Context.SaveChanges();
            RefreshDataSources();
        }

        private void buttonDeleteStation_Click(object sender, EventArgs e)
        {
            var station = comboBoxStations.SelectedItem as Station;
            if (station == null) return;
            try
            {
                Server.Context.Stations.Remove(station);
                Server.Context.SaveChanges();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Нельзя удалить станцию с зависимостями: " + ex.Message);
            }

        }

        private void buttonLoadSegments_Click(object sender, EventArgs e)
        {
            var res = openFileDialogCSV.ShowDialog();

            if (res != DialogResult.OK) return;

            var file = openFileDialogCSV.OpenFile();

            using (var reader = new StreamReader(file,Encoding.UTF8))
            {
                do
                {
                    string segmentString = reader.ReadLine();
                    if (segmentString == null) break;

                    var stationNames = segmentString.Split(',').ToList();


                    string lengthString = reader.ReadLine();
                    if (lengthString == null) throw new InvalidDataException("Нет данных о расстоянии между станциями");
                    var lengths = lengthString.Split(',').Select(Int32.Parse).ToList();
                    if (lengths.Count != stationNames.Count - 1) throw new InvalidDataException("Количество длин не совпадает с количеством станций");


                    var stations = new List<Station>();
                    foreach (var name in stationNames)
                    {
                        var station = Server.Context.Stations.FirstOrDefault(s => s.Name == name);
                        if (station == null) throw new InvalidDataException("Нет станции с именем "+name);
                        stations.Add(station);
                    }
                    var waypoints = Server.CreateNetSegment(stations);

                    Server.CreateSegmentLengths(waypoints, lengths);
                } while (!reader.EndOfStream);
            }
        }

        private void comboBoxStations_SelectedValueChanged(object sender, EventArgs e)
        {
            var station = comboBoxStations.SelectedItem as Station;
            if (station == null) return;
            if (station.Waypoints.Count == 0) return;
            bindingSourceSegmentStations.DataSource =
                Server.GetStationsFromSegments(Server.GetStationsOnSegmentsByStationId(station.Id));
        }

        private void comboBoxJunkStationsStart_SelectedValueChanged(object sender, EventArgs e)
        {
            var station = comboBoxJunkStationsStart.SelectedItem as Station;
            if (station == null) return;
            bindingSourceJunkStationPairs.DataSource = Server.GetJunktionStationPairs(station);
        }

        private void buttonAddRoute_Click(object sender, EventArgs e)
        {
            var startStation = comboBoxJunkStationsStart.SelectedItem as Station;
            var endStation = comboBoxJunkStationsEnd.SelectedItem as Station;
            var strTime = textBoxRouteDepartureTime.Text;
            var train = comboBoxRouteTrains.SelectedItem as Train;

            if (startStation == null || endStation == null || train == null) return;
            DateTime startTime;
            try
            {
                startTime = Server.CreateTrainTime(strTime);
            }
            catch
            {
                MessageBox.Show("Формат времени ЧЧ:ММ");
                return;
            }

            var route = new Route
            {
                StartStation = startStation,
                EndStation = endStation,
                StartTime = startTime,
                Train = train
            };
            Server.Context.Routes.Add(route);
            Server.Context.SaveChanges();
            Server.FillRoute(route);
            Server.Context.SaveChanges();
        }

        private void buttonRefresh_Click(object sender, EventArgs e)
        {
            RefreshDataSources();
        }

        private void buttonExit_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void comboBoxTrains_SelectedValueChanged(object sender, EventArgs e)
        {
            var train = comboBoxTrains.SelectedItem as Train;
            if (train == null) return;

            var route = train.Routes.FirstOrDefault();
            if (route == null)
            {
                textBoxTrainRoute.Text = "Маршрут не задан";
            }
            else
            {
                textBoxTrainRoute.Text = route.ToString();
            }

            bindingSourceTrainWagons.DataSource = train.Wagons.ToList();
        }

        private void buttonRemoveTrainWagon_Click(object sender, EventArgs e)
        {
            var train = comboBoxTrains.SelectedItem as Train;
            if (train == null) return;
            var wagon = comboBoxTrainWagons.SelectedItem as Wagon;
            if (wagon == null) return;

            if (wagon.PassengerCount != 0)
            {
                MessageBox.Show("Нельзя удалить вагон с пассажирами");
                return;
            }

            train.Wagons.Remove(wagon);
            Server.Context.SaveChanges();
        }

        private void buttonAddTrainWagon_Click(object sender, EventArgs e)
        {
            var train = comboBoxTrains.SelectedItem as Train;
            if (train == null) return;
            var wagon = comboBoxFreeWagons.SelectedItem as Wagon;
            if (wagon == null) return;

            if (train.Wagons.Count >= train.MaxWagonCount)
            {
                MessageBox.Show("Нельзя добавить вагон в поезд. Достигнут максимум");
                return;
            }

            train.Wagons.Add(wagon);
            Server.Context.SaveChanges();
            
        }

        private void buttonAddTrain_Click(object sender, EventArgs e)
        {
            var name = textBoxNewTrainName.Text;
            if (String.IsNullOrWhiteSpace(name))
            {
                MessageBox.Show("Введите название поезда");
                return;
            }

            int maxWagons, velocity;
            try
            {
                maxWagons = Int32.Parse(textBoxMaxWagonCount.Text);
                velocity = Int32.Parse(textBoxVelocity.Text);
            }
            catch (Exception)
            {
                MessageBox.Show("Неверные данные");
                return;
            }

            var driver = comboBoxFreeDrivers.SelectedItem as Worker;
            if (driver == null) return;

            var startStation = comboBoxStartTrainStations.SelectedItem as Station;
            if (startStation == null) return;


            var train = new Train
            {
                Name = name,
                MaxWagonCount = maxWagons,
                Velocity = velocity,
                Driver = driver,
                CurrentStation = startStation
            };

            Server.Context.Trains.Add(train);
            Server.Context.SaveChanges();
        }

        private void buttonAddWagon_Click(object sender, EventArgs e)
        {
            int maxPassengerCount;
            try
            {
                maxPassengerCount = Int32.Parse(textBoxMaxPassengersCount.Text);
            }
            catch (Exception)
            {
                MessageBox.Show("Неверные данные");
                return;
            }

            var conductor = comboBoxFreeConductors.SelectedItem as Worker;
            if (conductor == null) return;

            var wagon = new Wagon
            {
                MaxPassengerCount = maxPassengerCount,
                Conductor = conductor
            };

            Server.Context.Wagons.Add(wagon);
            Server.Context.SaveChanges();
        }

        private void comboBoxWorkers_SelectedValueChanged(object sender, EventArgs e)
        {
            var worker = comboBoxWorkers.SelectedItem as Worker;
            if (worker == null) return;

            var workplace = "";
            if (worker.Trains.Count != 0)
            {
                workplace = "Поезд - " + worker.Trains.First().Name;
            }
            else if (worker.Wagons.Count != 0)
            {
                workplace = "Вагон - " + worker.Wagons.First();
            }

            textBoxWorkerWorkplace.Text = workplace;
        }

        private void comboBoxPassengers_SelectedValueChanged(object sender, EventArgs e)
        {
            var pass = comboBoxPassengers.SelectedItem as Passenger;
            if (pass == null) return;

            bindingSourcePassTickets.DataSource = pass.Tickets.ToList();
        }

        private void buttonAddWorker_Click(object sender, EventArgs e)
        {
            var lastName = textBoxLastName.Text;
            var firstName = textBoxFirstName.Text;
            var middleName = textBoxMiddleName.Text;

            if (String.IsNullOrWhiteSpace(lastName)
                || String.IsNullOrWhiteSpace(middleName)
                || String.IsNullOrWhiteSpace(firstName))
            {
                MessageBox.Show("Введите ФИО");
                return;
            }

            decimal salary;
            int los;
            try
            {
                salary = Decimal.Parse(textBoxSalary.Text);
                los = Int32.Parse(textBoxLoS.Text);
            }
            catch (Exception)
            {
                MessageBox.Show("Неверные данные");
                return;
            }

            var worker = new Worker
            {
                FirstName = firstName,
                MiddleName = middleName,
                LastName = lastName,
                Salary = salary,
                LengthOfService = los
            };
            Server.Context.Workers.Add(worker);
            Server.Context.SaveChanges();
        }

        private void buttonAddPassenger_Click(object sender, EventArgs e)
        {
            var lastName = textBoxLastName.Text;
            var firstName = textBoxFirstName.Text;
            var middleName = textBoxMiddleName.Text;

            if (String.IsNullOrWhiteSpace(lastName)
                || String.IsNullOrWhiteSpace(middleName)
                || String.IsNullOrWhiteSpace(firstName))
            {
                MessageBox.Show("Введите ФИО");
                return;
            }

            var ident = textBoxIdent.Text;
            var passenger = new Passenger
            {
                FirstName = firstName,
                MiddleName = middleName,
                LastName = lastName,
                IdentityNumber = ident
            };

            Server.Context.Passengers.Add(passenger);
            Server.Context.SaveChanges();
        }

        private void MainForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            Server.Context.Dispose();
        }

        private void comboBox1_SelectedValueChanged(object sender, EventArgs e)
        {
            var route = comboBox1.SelectedItem as Route;
            if (route == null) return;

            bindingSourceInStations.DataSource = bindingSourceOutStations.DataSource 
                = Server.GetStationsBetweenStations(route.StartStationId, route.EndStationId);

            bindingSourceTicketTrainWagons.DataSource = route.Train.Wagons.ToList();

        }

        private void buttonGetTicket_Click(object sender, EventArgs e)
        {
            var route = comboBox1.SelectedItem as Route;
            if (route == null) return;

            var inStation = comboBoxInTicketStations.SelectedItem as Station;
            if (inStation == null) return;


            var outStation = comboBoxOutTicketStations.SelectedItem as Station;
            if (outStation == null) return;

            var wagon = comboBoxTicketWagons.SelectedItem as Wagon;
            if (wagon == null) return;

            if (wagon.PassengerCount >= wagon.MaxPassengerCount)
            {
                MessageBox.Show("В вагоне больше нет места");
            }

            var pass = comboBoxTicketPassenger.SelectedItem as Passenger;
            if (pass == null) return;

            var ticket = new Ticket
            {
                Route = route,
                Passenger = pass,
                Price = Server.CalcCost(inStation.Id, outStation.Id),
                Length = Server.GetLengthsBetweenStations(inStation.Id, outStation.Id),
                InStation = inStation,
                OutStation = outStation,
                Wagon = wagon,
                BuyDate = DateTime.Now
            };

            Server.Context.Tickets.Add(ticket);
            Server.Context.SaveChanges();

            Server.FillTicket(ticket);

            wagon.PassengerCount++;
            Server.Context.SaveChanges();

            textBoxTicket.Text = ticket.ToLongString();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                var stream = File.OpenWrite("e:/report.pdf");
                var doc = new Document();
                var writer = PdfWriter.GetInstance(doc, stream);

                var font = BaseFont.CreateFont("c:/Windows/Fonts/arial.ttf", BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
                doc.Open();
                var para = new Paragraph(Server.GetStats(), new iTextSharp.text.Font(font));

                doc.Add(para);
                doc.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                return;
            }
            MessageBox.Show("Отчет успешно сгенерирован");
        }
    }
}
