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
            ((System.ComponentModel.ISupportInitialize)(this.bindingSourceStations)).BeginInit();
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
            this.comboBoxStations.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(34, 25);
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
            this.textBoxNewStationName.TabIndex = 2;
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
            this.buttonDeleteStation.TabIndex = 6;
            this.buttonDeleteStation.Text = "Удалить";
            this.buttonDeleteStation.UseVisualStyleBackColor = true;
            this.buttonDeleteStation.Click += new System.EventHandler(this.buttonDeleteStation_Click);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(979, 553);
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
    }
}

