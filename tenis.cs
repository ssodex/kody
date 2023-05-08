using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ten
{
    public partial class Form1 : Form
    {
        int bodyp1 = 0;         //inicializace
        int bodyp2 = 0;
        int palka1y = 170;
        int palka1x = 10;
        int palka2y = 170;
        int palka2x = 865;
        int micekx = 420;
        int miceky = 200;
        int smerx = 0; //rychlost
        int smery = 0; //rychlost
        int hraniceprava = 875; 
        int hraniceleva = 0;     
        int hranicedole = 445;
        int hranicenahore = 0;
        void obnova() //funkce pro reset
        {
            groupBox1.Visible = true;
            micekx = 420;
            miceky = 200;
            smerx = 0; 
            smery = 0;
            bodyp1 = 0;
            bodyp2 = 0;
            label2.Text = "Hrac2: " + bodyp2;
            label1.Text = "Hrac1: " + bodyp1;
            timer2.Interval = 20;
            timer2.Enabled = false;
            timer1.Enabled = false;
        }
        void rychlost ()    //funkce pro zmenu rychlosti
        {
            if (smerx < 0)
            { smerx -= 2; }
            else
            {smerx += 2; }
        }
        public Form1()
        {
            InitializeComponent(); 
        }
        private void timer1_Tick(object sender, EventArgs e) //timer pro zobrazovani micku a palky
        {
            palka1.Location = new Point(palka1x, palka1y);
            palka2.Location = new Point(palka2x, palka2y);
            micek.Location = new Point(micekx, miceky);
            micekx = micekx + smerx; //pohyb micku
            miceky = miceky + smery;

            if (miceky == hranicedole)  //podminky pro zmenu smeru
            { smery = smery * -1; }
            if (miceky == hranicenahore)
            { smery = smery * -1; }
            if (micekx >= hraniceprava) //podminka pro pricteni bodu hraci1, vraceni micku na pocatecni pozici
            {
                bodyp1 += 1;
                micekx = 400;
                miceky = 200;
                smerx = 0;
                smery = 0;
                hraniceprava = 875;
                label1.Text = "Hrac1: " + bodyp1;
                timer2.Interval = 20;
                if (bodyp1 == 5)
                {
                   MessageBox.Show("Hrac1 vyhral!");
                   obnova();
                }
            }
            if (micekx <= hraniceleva)
            {
                bodyp2 += 1;
                micekx = 400;
                miceky = 200;
                smerx = 0;
                smery = 0;
                hraniceleva = 0;
                label2.Text = "Hrac2: " + bodyp2;
                timer2.Interval = 20;
                if (bodyp2 == 5)
                {
                    MessageBox.Show("Hrac2 vyhral!");
                    obnova();
                }
            }
            //podminka pro odrazeni od palky
            if ((micek.Location.X >= 855) && (micek.Location.Y >= palka2.Location.Y) && (micek.Location.X >= 855) && (micek.Location.Y <= palka2.Location.Y + 85))
            {
                micekx = 850;
                hraniceprava += 30;
                hraniceleva -= 30;
                rychlost();
                smerx = smerx * -1;
                if(radioButton4.Checked == true)//zpomaleni automatickeho hrace
                { timer2.Interval += 40; }
            }
            //podminka pro odrazeni od palky
            if ((micek.Location.X <=14) && (micek.Location.Y >= palka1.Location.Y - 10) && (micek.Location.X <= 14) && (micek.Location.Y <= palka1.Location.Y + 85))
            {
                micekx = 20;
                hraniceprava += 30;
                hraniceleva -= 30;
                rychlost();
                smerx = smerx * -1;
                if (radioButton3.Checked == true ) //zpomaleni automatickeho hrace
                {
                  timer2.Interval += 40 ; 
                }
            }
        }
        private void Form1_KeyDown(object sender, KeyEventArgs e) //reakce na klavesy
        {
            if (e.KeyCode == Keys.S) // pohyb palky dolu
            { if (radioButton4.Checked == true || radioButton1.Checked == true)
                {
                   if (palka1y < 370)
                   { palka1y += 25; }
                }
            }
            if (e.KeyCode == Keys.W) // pohyb palky nahoru
            {
                if (radioButton4.Checked == true || radioButton1.Checked == true)
                {
                    if (palka1y > 0)
                    {  palka1y -= 25;}
                }
            }
            if (e.KeyCode == Keys.Up)// pohyb palky nahoru
            {
                if (radioButton3.Checked == true || radioButton1.Checked == true)
                {
                    if (palka2y > 0)
                    { palka2y -= 25;}
                }
            }
            if (e.KeyCode == Keys.Down) // pohyb palky dolu
                if (radioButton3.Checked == true || radioButton1.Checked == true)
                {
                    if (palka2y < 370)
                    { palka2y += 25;}
                }
            if (e.KeyCode == Keys.Escape) //rozhybani micku
            {
                obnova();
            }
            if (e.KeyCode == Keys.Space) //stop hry a moznost zmeny nastaveni ci ukoncit
            {
                if (smerx == 0)
                {
                    int index = 0;
                    int index1 = 0;
                    Random rnd = new Random();
                    while (index == 0)
                    { index = rnd.Next(-1, 2);}
                    while (index1 == 0)
                    { index1 = rnd.Next(-1, 2); }
                    smerx = 5 * index;
                    smery = 5 * index1;
                }
                if (groupBox1.Visible == false)
                {
                    timer1.Enabled = true;
                    timer2.Enabled = true;
                }
            }

        }
        private void timer2_Tick(object sender, EventArgs e) //timer pro automatickeho hrace
        {
            if (radioButton3.Checked == true)
            { if (miceky < 370)
                {palka1y = miceky; }
            }
            if (radioButton4.Checked == true)
            {
                if (miceky < 370)
                { palka2y = miceky;  }
            }
        }
        private void button1_Click(object sender, EventArgs e) //schovani nastaveni hry
        {
            this.Focus();
            groupBox1.Visible = false;
            MessageBox.Show("Zmacknutim mezerniku rozhýbete micek." + Environment.NewLine + "Klávesa escape ukonci hru.");
        }
        private void button2_Click(object sender, EventArgs e) //ukonceni programu
        { this.Close(); }
        private void radioButton1_CheckedChanged(object sender, EventArgs e)
        {
            radioButton3.Enabled = false;
            radioButton4.Enabled = false;
            button1.Enabled = true;
        }
        private void radioButton2_CheckedChanged(object sender, EventArgs e)
        {
            radioButton3.Enabled = true;
            radioButton4.Enabled = true;
            button1.Enabled = false;
        }
        private void radioButton3_CheckedChanged(object sender, EventArgs e)
        {
            button1.Enabled = true;
        }
        private void radioButton4_CheckedChanged(object sender, EventArgs e)
        {
            button1.Enabled = true;
        }
    }
}
       
    

        
    
