namespace RailwayAdmin
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.bindingSourceStations = new System.Windows.Forms.BindingSource(this.components);
            this.comboBoxStations = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.textBoxNewStationName = new System.Windows.Forms.TextBox();
            this.labelStationName = new System.Windows.Forms.Label();
            this.buttonAddStation = new System.Windows.Forms.Button();
            this.buttonDeleteStation = new System.Windows.Forms.Button();
            this.buttonLoadSegments = new System.Windows.Forms.Button();
            this.openFileDialogCSV = new System.Windows.Forms.OpenFileDialog();
            this.comboBoxSegmentStations = new System.Windows.Forms.ComboBox();
            this.bindingSourceSegmentStations = new System.Windows.Forms.BindingSource(this.components);
            this.label2 = new System.Windows.Forms.Label();
            this.button1 = new System.Windows.Forms.Button();
            this.bindingSourceJunkStations = new System.Windows.Forms.BindingSource(this.components);
            this.bindingSourceJunkStationPairs = new System.Windows.Forms.BindingSource(this.components);
            this.comboBoxJunkStationsStart = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.comboBoxJunkStationsEnd = new System.Windows.Forms.ComboBox();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.buttonAddRoute = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceStations)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceSegmentStations)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceJunkStations)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceJunkStationPairs)).BeginInit();
            this.SuspendLayout();
            // 
            // bindingSourceStations
            // 
            this.bindingSourceStations.DataSource = typeof(RailwayCore.Station);
            // 
            // comboBoxStations
            // 
            this.comboBoxStations.DataSource = this.bindingSourceStations;
            this.comboBoxStations.DisplayMember = "Name";
            this.comboBoxStations.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxStations.FormattingEnabled = true;
            this.comboBoxStations.Location = new System.Drawing.Point(37, 54);
            this.comboBoxStations.Name = "comboBoxStations";
            this.comboBoxStations.Size = new System.Drawing.Size(253, 21);
            this.comboBoxStations.TabIndex = 1;
            this.comboBoxStations.SelectedValueChanged += new System.EventHandler(this.comboBoxStations_SelectedValueChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(34, 38);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(52, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Станции:";
            // 
            // textBoxNewStationName
            // 
            this.textBoxNewStationName.Location = new System.Drawing.Point(37, 117);
            this.textBoxNewStationName.Name = "textBoxNewStationName";
            this.textBoxNewStationName.Size = new System.Drawing.Size(253, 20);
            this.textBoxNewStationName.TabIndex = 3;
            // 
            // labelStationName
            // 
            this.labelStationName.AutoSize = true;
            this.labelStationName.Location = new System.Drawing.Point(34, 101);
            this.labelStationName.Name = "labelStationName";
            this.labelStationName.Size = new System.Drawing.Size(86, 13);
            this.labelStationName.TabIndex = 3;
            this.labelStationName.Text = "Новая станция:";
            // 
            // buttonAddStation
            // 
            this.buttonAddStation.Location = new System.Drawing.Point(305, 114);
            this.buttonAddStation.Name = "buttonAddStation";
            this.buttonAddStation.Size = new System.Drawing.Size(75, 23);
            this.buttonAddStation.TabIndex = 4;
            this.buttonAddStation.Text = "Добавить";
            this.buttonAddStation.UseVisualStyleBackColor = true;
            this.buttonAddStation.Click += new System.EventHandler(this.buttonAddStation_Click);
            // 
            // buttonDeleteStation
            // 
            this.buttonDeleteStation.Location = new System.Drawing.Point(305, 52);
            this.buttonDeleteStation.Name = "buttonDeleteStation";
            this.buttonDeleteStation.Size = new System.Drawing.Size(75, 23);
            this.buttonDeleteStation.TabIndex = 2;
            this.buttonDeleteStation.Text = "Удалить";
            this.buttonDeleteStation.UseVisualStyleBackColor = true;
            this.buttonDeleteStation.Click += new System.EventHandler(this.buttonDeleteStation_Click);
            // 
            // buttonLoadSegments
            // 
            this.buttonLoadSegments.Location = new System.Drawing.Point(37, 447);
            this.buttonLoadSegments.Name = "buttonLoadSegments";
            this.buttonLoadSegments.Size = new System.Drawing.Size(249, 23);
            this.buttonLoadSegments.TabIndex = 0;
            this.buttonLoadSegments.Text = "Загрузка сегментов из CSV";
            this.buttonLoadSegments.UseVisualStyleBackColor = true;
            this.buttonLoadSegments.Click += new System.EventHandler(this.buttonLoadSegments_Click);
            // 
            // openFileDialogCSV
            // 
            this.openFileDialogCSV.DefaultExt = "csv";
            this.openFileDialogCSV.Filter = "CSV files|*.csv";
            // 
            // comboBoxSegmentStations
            // 
            this.comboBoxSegmentStations.DataSource = this.bindingSourceSegmentStations;
            this.comboBoxSegmentStations.DisplayMember = "Name";
            this.comboBoxSegmentStations.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxSegmentStations.FormattingEnabled = true;
            this.comboBoxSegmentStations.Location = new System.Drawing.Point(407, 54);
            this.comboBoxSegmentStations.Name = "comboBoxSegmentStations";
            this.comboBoxSegmentStations.Size = new System.Drawing.Size(253, 21);
            this.comboBoxSegmentStations.TabIndex = 5;
            // 
            // bindingSourceSegmentStations
            // 
            this.bindingSourceSegmentStations.DataSource = typeof(RailwayCore.Station);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(404, 38);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(167, 13);
            this.label2.TabIndex = 9;
            this.label2.Text = "Станции в соседних сегментах:";
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(465, 316);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 10;
            this.button1.Text = "button1";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // bindingSourceJunkStations
            // 
            this.bindingSourceJunkStations.DataSource = typeof(RailwayCore.Station);
            // 
            // bindingSourceJunkStationPairs
            // 
            this.bindingSourceJunkStationPairs.DataSource = typeof(RailwayCore.Station);
            // 
            // comboBoxJunkStationsStart
            // 
            this.comboBoxJunkStationsStart.DataSource = this.bindingSourceJunkStations;
            this.comboBoxJunkStationsStart.DisplayMember = "Name";
            this.comboBoxJunkStationsStart.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxJunkStationsStart.FormattingEnabled = true;
            this.comboBoxJunkStationsStart.Location = new System.Drawing.Point(37, 221);
            this.comboBoxJunkStationsStart.Name = "comboBoxJunkStationsStart";
            this.comboBoxJunkStationsStart.Size = new System.Drawing.Size(253, 21);
            this.comboBoxJunkStationsStart.TabIndex = 11;
            this.comboBoxJunkStationsStart.SelectedValueChanged += new System.EventHandler(this.comboBoxJunkStationsStart_SelectedValueChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(34, 205);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(109, 13);
            this.label3.TabIndex = 12;
            this.label3.Text = "Начальная станция:";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(315, 205);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(102, 13);
            this.label4.TabIndex = 14;
            this.label4.Text = "Конечная станция:";
            // 
            // comboBoxJunkStationsEnd
            // 
            this.comboBoxJunkStationsEnd.DataSource = this.bindingSourceJunkStationPairs;
            this.comboBoxJunkStationsEnd.DisplayMember = "Name";
            this.comboBoxJunkStationsEnd.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxJunkStationsEnd.FormattingEnabled = true;
            this.comboBoxJunkStationsEnd.Location = new System.Drawing.Point(318, 221);
            this.comboBoxJunkStationsEnd.Name = "comboBoxJunkStationsEnd";
            this.comboBoxJunkStationsEnd.Size = new System.Drawing.Size(253, 21);
            this.comboBoxJunkStationsEnd.TabIndex = 13;
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(606, 222);
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(100, 20);
            this.textBox1.TabIndex = 15;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(603, 206);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(111, 13);
            this.label5.TabIndex = 16;
            this.label5.Text = "Время отправления:";
            // 
            // buttonAddRoute
            // 
            this.buttonAddRoute.Location = new System.Drawing.Point(750, 220);
            this.buttonAddRoute.Name = "buttonAddRoute";
            this.buttonAddRoute.Size = new System.Drawing.Size(177, 23);
            this.buttonAddRoute.TabIndex = 17;
            this.buttonAddRoute.Text = "Добавить маршрут";
            this.buttonAddRoute.UseVisualStyleBackColor = true;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(979, 553);
            this.Controls.Add(this.buttonAddRoute);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.textBox1);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.comboBoxJunkStationsEnd);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.comboBoxJunkStationsStart);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.comboBoxSegmentStations);
            this.Controls.Add(this.buttonLoadSegments);
            this.Controls.Add(this.buttonDeleteStation);
            this.Controls.Add(this.buttonAddStation);
            this.Controls.Add(this.labelStationName);
            this.Controls.Add(this.textBoxNewStationName);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.comboBoxStations);
            this.Name = "MainForm";
            this.Text = "Railway Admin";
            this.Load += new System.EventHandler(this.MainForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceStations)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceSegmentStations)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceJunkStations)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceJunkStationPairs)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.BindingSource bindingSourceStations;
        private System.Windows.Forms.ComboBox comboBoxStations;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox textBoxNewStationName;
        private System.Windows.Forms.Label labelStationName;
        private System.Windows.Forms.Button buttonAddStation;
        private System.Windows.Forms.Button buttonDeleteStation;
        private System.Windows.Forms.Button buttonLoadSegments;
        private System.Windows.Forms.OpenFileDialog openFileDialogCSV;
        private System.Windows.Forms.ComboBox comboBoxSegmentStations;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.BindingSource bindingSourceSegmentStations;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.BindingSource bindingSourceJunkStations;
        private System.Windows.Forms.BindingSource bindingSourceJunkStationPairs;
        private System.Windows.Forms.ComboBox comboBoxJunkStationsStart;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.ComboBox comboBoxJunkStationsEnd;
        private System.Windows.Forms.TextBox textBox1;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button buttonAddRoute;
    }
}

