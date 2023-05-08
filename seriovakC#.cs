using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO.Ports;
namespace WindowsFormsApp4
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                serialPort1.PortName = textBox1.Text;
                serialPort1.Open();
                timer1.Enabled = true;
                button1.Enabled = false;
            }
            catch { MessageBox.Show("spatne"); }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            serialPort1.Close();
            button1.Enabled = true;
        }

        private void Timer1_Tick(object sender, EventArgs e)
        {
            string p = serialPort1.ReadExisting();
            textBox2.Text += p;

        }

        private void Form1_Load(object sender, EventArgs e)
        {
            string a = "COM1";
            textBox1.Text = a;
            
        }
    }
}
