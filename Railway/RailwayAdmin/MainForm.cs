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
            var station = (Station)comboBoxStations.SelectedItem;
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

            using (var reader = new StreamReader(file))
            {
                do
                {
                    string segmentString = reader.ReadLine();
                    if (segmentString == null) break;

                    var stationNames = segmentString.Split(',');

                    var stations = new List<Station>();
                    foreach (var name in stationNames)
                    {
                        var station = Server.Context.Stations.FirstOrDefault(s => s.Name == name);
                        if (station == null) throw new InvalidDataException("Нет станции с именем "+name);
                        stations.Add(station);
                    }
                    var waypoints = Server.CreateNetSegment(stations);

                    string lengthString = reader.ReadLine();
                    if (lengthString == null) throw new InvalidDataException("Нет данных о расстоянии между станциями");
                    var lengths = segmentString.Split(',').Select(Int32.Parse).ToList();
                    if (lengths.Count != stations.Count - 1) throw new InvalidDataException("Количество длин не совпадает с количеством станций");
                    Server.CreateSegmentLengths(waypoints, lengths);
                } while (!reader.EndOfStream);
            }
        }

        private void comboBoxStations_SelectedValueChanged(object sender, EventArgs e)
        {
            var station = (Station)comboBoxStations.SelectedItem;
            if (station == null) return;
            bindingSourceSegmentStations.DataSource =
                Server.GetStationsFromSegments(Server.GetStationsOnSegmentsByStationId(station.Id));
        }

        private void button1_Click(object sender, EventArgs e)
        {
            var js = Server.GetJunktionStations();
            var jspairs = Server.GetJunktionStationPairs(js.First());
        }

        private void comboBoxJunkStationsStart_SelectedValueChanged(object sender, EventArgs e)
        {
            var station = (Station)comboBoxJunkStationsStart.SelectedItem;
            if (station == null) return;
            bindingSourceJunkStationPairs.DataSource = Server.GetJunktionStationPairs(station);
        }
    }
}
