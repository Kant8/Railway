using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
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
            bindingSourceStations.DataSource = Server.Context.Stations.ToList();
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
        }
    }
}
