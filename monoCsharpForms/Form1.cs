using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace __change__
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();

            this.FormBorderStyle = FormBorderStyle.None;
            this.WindowState = FormWindowState.Maximized;

            // laod the image
            this.pictureBox1.ImageLocation = "./assets/torizon-logo.png";
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Console.WriteLine("Hello Torizon!");
            label1.Text = "YEAHHHH!";
        }
    }
}
