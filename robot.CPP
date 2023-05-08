#include <stdio.h>
#include <dos.h>
#include <conio.h>
//zapojeni
//outport1
//bit
//0 - takt
//1 - smer
//2 - hlavni rameno
//3 - otaceni
//4 - rameno s chapadlem
//5 - chapadlo
//inport1
//bit
//0 - hlavni rameno
//1 - rameno s chapadlem
//2 - otaceni
//3 - chapadlo

#define p1 0x300
#define p2 0x301

#define nahoruhlr 119//hlavni rameno w
#define doluhlr  115 //hlavni rameno s
#define protismeru 100 //zakladan d
#define posmeru  97  //zakladna a
#define nahorur 53  //rameno s chapadlem 5
#define dolur  50   //rameno s chapadlem 2
#define zavrit 51   //chapadlo 3
#define otevrit 49  //chapadlo 1

int input;
int test;
int hlrameno;//promena pro sw zavoru hlavniho ramena
int zakladna;//promena pro sw zavoru zakladny
int ramenoch;//promena pro sw zavoru ramena s chapadlem
int chapadlo;//promena pro sw zavoru chapadla

int ovladani(int hod1, int hod2) //funkce pro pohyb
{
    outportb(p1,hod1); //hod1 = takt 1
    delay(1);
    outportb(p1,hod2); //hod2 = takt 0
    delay(1);
    return 0;
}
int zavora (int maska) //funkce pro kontrolu zavor
{
    input = inportb(p1);
    test = input & maska;
    return test;
}

int main (void)
{
while (1)
{
	int kl = getch();
	if(kl == (doluhlr) && (hlrameno != 400))//pohyb dolu
	{
		printf("dolu hlavni rameno\n");
		ovladani(0xfb,0xfa);
		hlrameno++;
	}
	else
    {
        printf("hlavni rameno limit\n");
    }
	/*input = inportb (p1);
	test = input & 0x01;*/
	zavora (0x01);
	if ((kl == nahoruhlr) &&(test != 0)) //pohyb nahoru
	{
		printf("nahoru hlavni rameno\n");
		ovladani(0xf9,0xf8);
		hlrameno--;
	}
	else
    {
        printf("hlavni rameno limit\n");
        hlrameno = 0;
    }

    if((kl == posmeru) && (zakladna!= 400)) //pohyb posmeru
    {
		printf("zakladna posmeru\n");
		ovladani(0xf7,0xf6);
		zakladna++;
    }
    else
    {
        printf("zakladna limit\n");
    }
	/*input = inportb (p1);
	test = input & 0x04;*/
	zavora (0x04);
	if((kl == protismeru)  && (test !=0) ) //pohyb protismeru
    {
		printf("zakladna protismeru\n");
		ovladani(0xf5,0xf4);
		zakladna--;
    }
    else
    {
        printf("zakladna limit\n");
        zakladna = 0;
    }

 /*input = inportb(p1);
 test = input & 0x02;*/
 zavora (0x02);
    if((kl == nahorur)&& (test !=0)) //pohyb nahoru
    {
		printf("nahoru rameno s chapadlem\n");
		ovladani(0xef,0xee);
		ramenoch--;
    }
    else
    {
        printf("rameno s chapadlem limit\n");
        ramenoch = 0;
    }
	if((kl == dolur) && (ramenoch != 400)) //pohyb dolu
    {
		printf("dolu rameno s chapadlem\n");
		ovladani(0xed,0xec);
		ramenoch++;
    }
    else
    {
        printf("rameno s chapadlem limit\n");
    }

	if((kl == zavrit) && (chapadlo!= 100)) //pohyb zavrit
    {
		printf("chapadlo zavrit\n");
		ovladani(0xdf,0xde);
		chapadlo++;
    }
    else
    {
        printf("chapadlo limit\n");
    }
	/*input = inportb(p1);
	test = input &= 0x08;*/
	zavora (0x08);
	if((kl == otevrit )  && (test !=0)) //pohyb otevrit
    {
		printf("chapadlo otevrit\n");
		ovladani(0xdd,0xdc);
		chapadlo--;
    }
    else
    {
        printf("chapadlo limit\n");
        chapadlo = 0;
    }
}
}
