using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Diagnostics;
namespace Snímač
{
    public partial class Form1 : Form
    {
6/12
 public Form1()
        {
            InitializeComponent();
        }
        //Inicializace
        int pocet_polozek = 14; //Počet položek možných k prodeji v .csv souboru
        string kod; //Kód nahraný pomocí snímače čárových kódu nebo ručním
        zadáním
    string polozka_radek; //Pomocná proměnná pro jednotlivé celé řádky z .csv
        souboru
    int aktual_radek = 0; //Pomocná proměnná pro určení aktuálního řádku z .csv
        string[,] tabulka = new string[14, 5]; //Rozdělená tabulka (2D pole) celého souboru
        zbozi.csv(rozděleno na řádky a sloupce) - dále jen "tabulka"
 string[] zakaznik = new string[3]; //Rozdělený řádek (1D pole) načtené zákaznické
        karty
    string[] polozka = new string[4]; //Pomocné pole (1D pole) pro rozdělení sloupců a
        následné nahráni do tabulky
    double celkova_cena = 0; //Celková cena aktuálního nákupu bez slevy
        double sleva = 0; //Sleva daného zákazníka
                          //Manuální načtení kódu
        private void NacteniKoduBtnClick(object sender, EventArgs e)
        {
            kod = textBox1.Text;
            NacteniKodu();
        }
        //Načtení kódu pomocí snímače
        private void NacteniKoduSnimacClick(object sender, KeyEventArgs e)
        {
            kod = e.KeyCode.ToString();
            NacteniKodu();
        }
        //Porovnání jednotlivých kódů
        private void NacteniKodu()
        {
            //Otevření Zbozi.csv pro čtení
            StreamReader sr_zbozi = new StreamReader("Zbozi.csv");
            aktual_radek = 0;
            //Nahrání všech řádků do celé tabulky
            //Přečtení po jednotlivých řádcích
            while ((polozka_radek = sr_zbozi.ReadLine()) != null)
            {
                //Rozdělení řádku na jednotlivé sloupce
                7 / 12
            polozka = polozka_radek.Split(';');
                //Nahrání tohoto rozděleného řádku do společné tabulky
                for (int i = 0; i < 4; i++)
                {
                    tabulka[aktual_radek, i] = polozka[i];
                }
                aktual_radek++;
            }
            //Ukončení čtení Zbozi.csv
            sr_zbozi.Close();
            //Otevření Zakaznici.csv pro čtení
            StreamReader sr_zakaznici = new StreamReader("Zakaznici.csv");
            //Přečtení po jednotlivých řádcích
            while ((polozka_radek = sr_zakaznici.ReadLine()) != null)
            {
                //Rozdělení řádku na jednotlivé sloupce
                zakaznik = polozka_radek.Split(';');
                //TEST: Shoduje se kód s jednou ze zákaznických karet:
                //ANO - Načtení slevy
                // - Pokračování - viz. funkce NacteniCeny()
                if (zakaznik[0] == kod)
                {
                    NacteniSlevy();
                }
            }
            //Ukončení čtení Zakaznici.csv
            sr_zakaznici.Close();
            //TEST: Shoduje se kód s jedním z kódů zboží?
            //ANO - Odečtení složky ze skladu
            // - Pokračování - viz. funkce OdecteniZeSkladu()
            for (int i = 0; i < pocet_polozek; i++)
            {
                if (tabulka[i, 0] == kod)
                {
                    OdecteniZeSkladu(i);
                }
            }
        }
        //Přičtení právě naskenovaného zboží k aktuální ceně (bez slevy)
        //Pokračování - viz. funkce ZobrazeniCeny()
        private void ZmenaCeny(int i)
   8/12
 {
 celkova_cena += Double.Parse(tabulka[i, 2]);
 ZobrazeniCeny();
    }
    //Zobrazení ceny v textboxu (po slevě)
    private void ZobrazeniCeny()
    {
        double cena_po_sleve = celkova_cena * (1 - (sleva / 100));
        textBox2.Text = cena_po_sleve.ToString("0.00");
    }
    //Odečtení skenované položky ze skladu
    private void OdecteniZeSkladu(int i)
    {
        int pocet = Int32.Parse(tabulka[i, 3]);
        //TEST: Je daný počet větší než 0?
        //ANO - Zmenšit počet o 1
        // - Nahrát nový počet do tabulky
        // - Zneviditelnit chybovou zprávu
        // - Pokračování - viz. funkce PricteniPoctu
        // - viz. funkce ZmenaCeny
        // - viz. funkce ZobrazeniPolozky
        // - viz. funkce AktualizaceZbozi
        //NE - Zobrazit chybovou zprávu
        if (pocet > 0)
        {
            pocet--;
            tabulka[i, 3] = pocet.ToString();
            label3.Visible = false;
            PricteniPoctu(i);
            ZmenaCeny(i);
            ZobrazeniPolozky();
            AktualizaceZbozi();
        }
        else
        {
            label3.Visible = true;
        }
    }
    //Zobrazení všech položek v listBoxu
    private void ZobrazeniPolozky()
    {
        //Smazání všech položek
        NačtenéZboží.Items.Clear();
        9 / 12
    //TEST: Je položka alespoň jednou načtená?
    //ANO - Výpočet aktuální ceny za celý počet této položky
    // - Zobrazení této položky
        for (int i = 0; i < pocet_polozek; i++)
        {
            if (tabulka[i, 4] != null)
            {
                double cena = Double.Parse(tabulka[i, 2]) * Double.Parse(tabulka[i, 4]);
                NačtenéZboží.Items.Add($"{tabulka[i, 1]} {tabulka[i, 4]}
           { cena.ToString("0.00")}
                ");
            }
        }
    }
    //Přepsání souboru Zbozi.csv (aktualizace skladu)
    private void AktualizaceZbozi()
    {
        //Otevření Zbozi.csv pro zápis
        StreamWriter sw_zbozi = new StreamWriter("Zbozi.csv", false);
        //Zapsaní všech řádku a sloupců z tabulky do .csv souboru
        for (int i = 0; i < pocet_polozek; i++)
        {
            sw_zbozi.WriteLine($"{tabulka[i, 0]};{tabulka[i, 1]};{tabulka[i, 2]};{tabulka[i,
           3]}
        ");
    }
    //Ukončení zápisu Zbozi.csv
    sw_zbozi.Close();
 }
//Přičtení počtu aktuálně naskenované položky
private void PricteniPoctu(int i)
{
    int cislo;
    //TEST: Byla tato položka již alespoň jednou naskenována?
    //ANO - Načtení počtu z tabulky
    //NE - Nastav počet na 0
    if (tabulka[i, 4] == null)
    {
        cislo = 0;
    }
    else
    {
        cislo = Int32.Parse(tabulka[i, 4]);
        10 / 12
    }

    //Inkrementace tohoto počtu
    cislo++;
    //Uložení tohoto počtu zpět do tabulky
    tabulka[i, 4] = cislo.ToString();
}
//Načtení slevy právě naskenované zákaznické karty
private void NacteniSlevy()
{
    //Načtení slevy
    sleva = Double.Parse(zakaznik[2]);
    //Vypasání jména zákazníka a jeho slevy
    ZákaznickáKarta.Items.Add($"Jméno: {zakaznik[1]}");
    ZákaznickáKarta.Items.Add($"Sleva: {sleva}%");
    //Pokračovnání - viz. fuknce ZobrazeniCeny()
    ZobrazeniCeny();
}
//Ukončení nákupu - placení (tisk účtenky)
private void Button1_Click(object sender, EventArgs e)
{
    //Vytvoření nového souboru Uctenka.txt
    StreamWriter sw_uctenka = new StreamWriter("Uctenka.txt");
    //Zarovnání názvu obchodu
    Zarovnani(sw_uctenka, "SUK Jednota");
    sw_uctenka.WriteLine("========================================");
    //Vypsání všech naskenovaných položek
    for (int i = 0; i < pocet_polozek; i++)
    {
        if (tabulka[i, 4] != null)
        {
            sw_uctenka.Write(tabulka[i, 1]);
            double celkova_cena = (Double.Parse(tabulka[i, 2])) * (Double.Parse(tabulka[i,
           4]));
            Mezera(sw_uctenka, tabulka[i, 1], celkova_cena.ToString("0.00"));
            double cena = Double.Parse(tabulka[i, 2]);
            sw_uctenka.WriteLine($" {tabulka[i, 4]} x {cena.ToString("0.00")}");
        }
    }
    11 / 12
 sw_uctenka.WriteLine("========================================");
    //Celková cena bez slevy
    sw_uctenka.Write("SUMA");
    Mezera(sw_uctenka, "SUMA", celkova_cena.ToString("0.00"));
    //Hodnota slevy
    sw_uctenka.Write("SLEVA v %");
    Mezera(sw_uctenka, "SLEVA v %", sleva.ToString());
    sw_uctenka.WriteLine("========================================");
    //Celková cena se slevou
    sw_uctenka.Write("CELKOVA CENA");
    double cena_po_sleve = celkova_cena * (1 - (sleva / 100));
    Mezera(sw_uctenka, "CELKOVA CENA", cena_po_sleve.ToString("0.00"));
    sw_uctenka.Close();
    //Vynulování proměnných a vyčíštění polí
    for (int i = 0; i < pocet_polozek; i++)
    {
        tabulka[i, 4] = null;
    }
    celkova_cena = 0;
    sleva = 0;
    NačtenéZboží.Items.Clear();
    ZákaznickáKarta.Items.Clear();
    textBox1.Clear();
    textBox2.Clear();
    //Otevření účtenky
    Process.Start("Uctenka.txt");
}
//Funkce pro zarovnání textu na střed
private void Zarovnani(StreamWriter uctenka, string text)
{
    for (int i = 0; i < 40 / 2 - (text.Length / 2); i++)
    {
        uctenka.Write(" ");
    }
    uctenka.WriteLine(text);
}
//Funkce pro zarovnání textu na konec
private void Mezera(StreamWriter uctenka, string nazev, string cena)
12 / 12
 {
    int delka_nazev = nazev.Length;
    int delka_cena = cena.Length;
    for (int i = 0; i < 40 - (delka_nazev + delka_cena); i++)
    {
        uctenka.Write(" ");
    }
    uctenka.WriteLine(cena);
}
 }
} 