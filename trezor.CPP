
#include <stdio.h>
#include <dos.h>
#define port1 0x300
#define port2 0x301

//zapojeni
//out porty
//piny  8,9,10,11,20  -> pozice + zamek
//port2 0 1  2  3  7
//piny  1,2,3,4,5  -> cisla pro displej
//port1 0 1 2 3 4

//in porty
//piny 12,7
//port1 0,1

int pozice1 = 0xFE; //11111110
int pozice2 = 0xFD; //11111101
int pozice3 = 0xFB; //11111011
int pozice4 = 0xF7; //11110111
char mask_dv = 0x02; //maska pro dvirka

int cislo = 0;
int index =0;
int status = 0;
char dvi;
char dvirka;
int kod;
int hrana;
int j;
int i;

int znak[10] = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09}; //hodnoty pro cisla na displeji

int rizeni [4][6] =
{{pozice1,0,0,0,0,0},  //pozice, hodnota displeje (kod), kl. aktualni, kl. predchozi,hrana, kod zadaný
 {pozice2,0,0,0,0,0},
 {pozice3,0,0,0,0,0},
 {pozice4,0,0,0,0,0}};

int indexreset (int cislo_case) // funkce pro nulovani indexu
{
		if (index == 3)
		{
				index =0;
		}
		else
		{
				index++;
		}
				status = cislo_case;
		return index;
}
int nulovanidispleje (int pole) //funkce pro vynulovani displeje
{
   rizeni [0][pole] = 0;
   rizeni [1][pole] = 0;
   rizeni [2][pole] = 0;
   rizeni [3][pole] = 0;
    j = 0;
    cislo =0;
}

int main (void)
{
		while (1)
		{
		 switch (status)
		 {
//                      nastaveni kodu
//------------------------------------------------------------
		case 0 :
		 outportb (port2,rizeni[index][0]); //aktivace pozice
		 status =1;
		break;

		case 1:
		 outportb (port1,rizeni[index][1] ); //zobrazeni na displej
		 delay (5);
		 status = 2;
		break;

		case 2:
		 rizeni [index][2] = inportb (port1); //nacteni aktualni hodnoty tlacitka
		 status = 3;
		break;

		case 3:
		 if (rizeni[index][2] < rizeni[index][3]) //zjisteni hrany
		 {
				rizeni [index][4] = 1; //stisknuto
				status = 4;
		 }

		 else
		 {
				rizeni [index][4] = 0;  //nestisknuto
				status = 5;
		 }
		 rizeni [index][3] = rizeni [index][2]; //presun akt. hodnoty do predchozi
		 break;

		case 4 :
				if (rizeni [0][4] == 1) //mode -> nuluje zadane cislice
				{
						nulovanidispleje(1);
						status = 5;
				}
				else if (rizeni [1][4] == 1) //sipka nahoru -> +1 k cislici na displeji
				{   if (cislo != 9)
						{
                            cislo++;
                            rizeni [j][1] = znak [cislo];
						}
						else
						{
                            cislo =0;
						}
						status = 5;
				}
				else if (rizeni [2][4] == 1) //sipka dolu -> -1 k cislici na displeji
				{
						if (cislo!=0)
						{
                            cislo--;
                            rizeni [j][1] = znak [cislo];
						}
						else
						{
                            cislo =9;
						}
						status = 5;
				}
				else if (rizeni [3][4] == 1) //set -> potvrzeni jednotliveho cisla pro danou pozici
				{
						j++;
						cislo = 0;
						if (j==4)
						{
                            printf("kod nastaven\n");
                            nulovanidispleje (5);
                            outportb (port2,0x7F ); // odemceni zamku
                            status = 6;
						}
                        else
                        {
                            status = 5;
                        }
                }
                break;

		case 5 :// manipulace s indexem

				indexreset (0); //cislo v zavorce -> na jaky case pokracuje
        break;
//------------------------------------------------------------
//                  zadavani kodu
//------------------------------------------------------------
		case 6 :
		 outportb (port2,rizeni[index][0]); //aktivace pozice
		 status = 7;
		break;

		case 7:
		 outportb (port1,rizeni[index][5] ); //zobrazeni na displej
		 delay (5);
		 status = 8;
		break;

		case 8:
		 rizeni [index][2] = inportb (port1); //nacteni aktualni hodnoty tlacitka
		 status = 9;
		break;

		case 9:
		 if (rizeni[index][2] < rizeni[index][3]) //zjisteni hrany
		 {
				rizeni [index][4] = 1; //stisknuto
				//rizeni [index][3] = rizeni [index][2]; //presun akt. hodnoty do predchozi
				status = 10;
		 }

        else
        {
				rizeni [index][4] = 0;  //nestisknuto
				//rizeni [index][3] = rizeni [index][2]; //presun akt. hodnoty do predchozi
				status = 11;
        }
        rizeni [index][3] = rizeni [index][2]; //presun akt. hodnoty do predchozi
		 break;

		case 10 :
				if (rizeni [0][4] == 1) //mode
				{
					 dvi = inportb (port1); //kontrola otevrenych dvirek
					 dvirka = dvi && mask_dv;
					 if (dvirka == 1)
                     {
                         status = 0;    // nastaveni noveho kodu
                     }
                     else
                     {
                         status = 11;
                     }
				}
				else if (rizeni [1][4] == 1) //sipka nahoru -> +1 k cislici na displeji
				{   if (cislo != 9)
						{
                            cislo++;
                            rizeni [j][5] = znak [cislo];
						}
						else
						{
                            cislo =0;
						}
						status = 11;
				}
				else if (rizeni [2][4] == 1) //sipka dolu -> -1 k cislici na displeji
				{
						if (cislo!=0)
						{
                            cislo--;
                            rizeni [j][5] = znak [cislo];
						}
						else
						{
                            cislo = 9;
						}
                    status = 11;
				}
				else if (rizeni [3][4] == 1) //set -> potvrzeni jednotliveho cisla pro danou pozici + porovnavani cisel pro kod
				{
						if (rizeni[j][1] == rizeni [j][5])
                        {
                           kod++;
                        }
						j++;
						cislo = 0;
						if (j == 4)
                        {
                            printf("kod zadán\n");
                            status = 12;
                        }
                        else
                        {
                            status = 11;
                        }
				}
				break;
		case 11 : // manipulace s indexem
				indexreset (6);
				break;

//------------------------------------------------------------
//porovnani nastaveneho a zadaneho kodu
//------------------------------------------------------------
		case 12 :

				if(kod == 4)
                    {
                        printf("otevreno\n");
                        outportb (port2,0x7F ); // odemceni zamku (01111111) pin 20 na out port2 bit 7
                    }
				else
                    {
                        printf("spatne\n");
                    }
                    nulovanidispleje(5);
                    kod = 0;
                    status = 6;
				break;

    }
}
}
