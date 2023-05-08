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

namespace seriovkaM
{
    public partial class Form1 : Form
    {
        static SerialPort SerPort;
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void TextBox1_TextChanged(object sender, EventArgs e)
        {
            string retezec = textBox1.Text;
            SerPort = new SerialPort("COM5", 9600, Parity.None, 8, StopBits.One);
            SerPort.Open();
            SerPort.Write(retezec); // poslani 8 znaku do AVR
            SerPort.Dispose(); // Pred skoncenim programu uvolnit port (zavrit ho)
        }
    }
}

