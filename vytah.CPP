#include <conio.h>
#include <stdio.h>
#include <dos.h>

#define p1 0x300
#define p2 0x301

//zapojeni
//out1 bit 0 1 2
//         A B C
//out2 bit 0  1  2
//         MS MZ SK
//in1  bit 0 1 2 3
//         1 2 3 4 (patra)
//     bit 4 5 6 7
//         1 2 3 4 (kabina)
//in2  bit 0 1 2 3        4  5
//         1 2 3 4(cidla) DS PS
int cidla [4] =
{{0x01,0x02,0x04,0x08}
};
int cisla [4] =
{{0x01,0x02,0x03,0x04}
};

int input;
int testc; //kontrola zda vytah je v zadanem patre
int testd; //test pro zmenu cisel pater na displeji
int testdv; //dvirka
int testps; //podlahovy spinac
int zadane;
int aktualni= 0;
int index_smer;
int status = 4; // zacatek case 4
int cidlo;
int smer;

int snimace() //kontrola snimacu pater vytahu
{
	cidlo = inportb(p2);
	testc = cidlo & cidla[zadane];
	testd = cidlo & cidla[aktualni];
	return 0;
}

int main (void)
{
while(1)
{
    switch(status)
    {
    case 0: //zadani patra
	cidlo = inport(p2);
	testps = cidlo & 0x20;
	if((inport(p2) & 0x01 == 0 && testps != 0 )||(inport(p2) & 0x10 == 0 && testps == 0 ))//patro1
	{   zadane = 0;
	    status =1;
	}
	else if((inport(p2) & 0x02 == 0 && testps != 0 )||(inport(p2) & 0x20== 0 && testps == 0))//patro2
	{   zadane = 1;
	    status =1;
	}
	else if((inport(p2) & 0x04 && testps != 0)||(inport(p2) & 0x40== 0 && testps == 0))//patro3
	{   zadane = 2;
	    status =1;
	}
	else if((inport(p2) & 0x08 == 0 && testps != 0)||(inport(p2) & 0x80== 0 && testps == 0))//patro4
	{   zadane =3 ;
	    status =1;
	}
    break;

    case 1: //porovnani jestli nahoru nebo dolu
	cidlo = inportb(p2);
	testps = cidlo & 0x20;
	if (aktualni < zadane) //nahoru
	{
	  if (testps == 0)
	  {
	      smer = 0xF9;//se svetlem
	  }
	  else
	  {
	      smer = 0xFD; //bez svetla
	  }
	  index_smer =0;
	}
	else if (aktualni > zadane) //dolu
	{
	  if (testps == 0)
	  {
	      smer = 0xF8; //se svetlem
	  }
	  else
	  {
	      smer = 0xFC; //bez svetla
	  }
	   index_smer =1;
	}
	else if (aktualni == zadane)
	{
	  status=0;
	  break;
	}
	status = 2;
	break;

    case 2: //kontrola dvirek + zapnuti pohonu
	cidlo = inportb(p2);
	testdv = cidlo & 0x10;
	if (testdv == 0) //test zda jsou zavrena dvirka
	{
	outportb(p2,smer); //zapnuti motoru
	status =3;
	}
	break;

    case 3:
	snimace();//kontrola snimacu
    while (testc != 0) //vytah jede dokud neni v zadanem patre
    {
	snimace();
    if ((testd == 0) && (index_smer == 0)) //zobrazeni aktualnich pater ve smeru nahoru
	{
	  outportb(p1,cisla[aktualni]);
	  aktualni++;
	}
    else if ((testd == 0) && (index_smer == 1)) //zobrazeni aktualnich pater ve smeru nahoru
    {
	  outportb(p1,cisla[aktualni]);
	  aktualni--;
    }
    testdv = cidlo & 0x10; // kontrola dvirek zda jsou otevrena
    if (testdv == 0)
    {
	 outportb(p2,smer); // nejsou otevrena vytah jede
    }
    else
    {
	outportb(p2,0xFF); //jsou otevrena vytah se zastavi a ceka na zavreni
    }
    }
	outportb(p2,0xFF); //zastaveni vytahu po dojeti na dane patro
	aktualni = zadane;
	status = 0;
	break;

    case 4: //nastaveni vytahu na zacatecni polohu 1 patro
	cidlo = inportb(p2);
	testc = cidlo & 0x01;
	while (testc != 0)
    {
	outportb(p2,0xFC);
	cidlo = inportb(p2);
	testc = cidlo & 0x01;
    }
    outportb(p2,0xFF);
    aktualni = 0;
    status = 0;
    outportb(p1,0x01);
	break;
}
}

}
