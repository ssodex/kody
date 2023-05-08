#include <stdio.h>
#include <dos.h>
#include <conio.h>

#define p1 0x300
#define p2 0x301
int i;
int pocet=0; // pocet zadanych cisel
int klav;
int zasobnikN [5]; //zasobnik pro numericky displej
int zasobnikA [4]; //zasobnik pro alfanumericky displej
//pole pro cisla na num. dis.
int num[10][7]=
{
//a,b,c,d,e,f,g
{1,1,1,1,1,1,0},//0
{0,1,1,0,0,0,0},//1
{1,1,0,1,1,0,1},//2
{1,1,1,1,0,0,1},//3
{0,1,1,0,0,1,1},//4
{1,0,1,1,0,1,1},//5
{1,0,1,1,1,1,1},//6
{1,1,1,0,0,0,0},//7
{1,1,1,1,1,1,1},//8
{1,1,1,0,0,1,1},//9
};
//pole pro písmena na alfa. Dis.
int alfanum[26][15] =
{/*
 a,b,c,d,e,f,g,h,j,k,l,m,n,p,dp  */
{1,1,1,0,1,1,0,0,1,0,0,0,1,0,0},//A
{1,1,1,1,0,0,1,0,1,0,1,0,0,0,0},//B
{1,0,0,1,1,1,0,0,0,0,0,0,0,0,0},//C
{1,1,1,1,0,0,1,0,0,0,1,0,0,0,0},//D
{1,0,0,1,1,1,0,0,1,0,0,0,1,0,0},//E
{1,0,0,0,1,1,0,0,1,0,0,0,1,0,0},//F
{1,0,1,1,1,1,0,0,1,0,0,0,0,0,0},//G
{0,1,1,0,1,1,0,0,1,0,0,0,1,0,0},//H
{1,0,0,1,0,0,1,0,0,0,1,0,0,0,0},//I
{0,1,1,1,1,0,0,0,0,0,0,0,0,0,0},//J
{0,0,0,0,1,1,0,1,0,1,0,0,1,0,0},//K
{0,0,0,1,1,1,0,0,0,0,0,0,0,0,0},//L
{0,1,1,0,1,1,0,1,0,0,0,0,0,1,0},//M
{0,1,1,0,1,1,0,0,0,1,0,0,0,1,0},//N
{1,1,1,1,1,1,0,0,0,0,0,0,0,0,0},//O
{1,1,0,0,1,1,0,0,1,0,0,0,1,0,0},//P
{1,1,1,1,1,1,0,0,0,1,0,0,0,0,0},//Q
{1,1,0,1,1,0,0,0,1,1,0,0,1,0,0},//R
{1,0,1,1,0,1,0,0,1,0,0,0,1,0,0},//S
{1,0,0,0,0,0,1,0,0,0,1,0,0,0,0},//T
{0,1,1,1,1,1,0,0,0,0,0,0,0,0,0},//U
{0,1,1,0,0,0,0,0,0,1,0,0,0,1,0},//V
{0,1,1,0,1,1,0,0,0,1,0,1,0,0,0},//W
{0,0,0,0,0,0,0,1,0,1,0,1,0,1,0},//X
{0,0,0,0,0,0,0,1,0,0,1,0,0,1,0},//Y
{1,0,0,1,0,0,0,1,1,0,0,1,1,0,0},//Z
};
void start(int dato) //funkce pro vyslani jednotliveho bitu
{
outportb(p1,0x00);//clk0
outportb(p1,dato);//dato1
outportb(p1,0x02);//clk1
}
//funkce pro 14 seg. displej
//cis1 a cis2 je pozice zobrazovaneho cisla ulozenehoho  v zasobniku
//A1(D1+D3) a A2(D0+D2) je vybrani dane dvojice segmentu
void alfa(int cis1,int cis2, int A1, int A2)
{
		start(0x01); //startovaci bit
		for (int i = 0; i < 15;i++)
		{
				outportb(p1,0x00);//clk 0
				outport(p1,alfanum[zasobnikA[cis1]][i]);//dato
				outportb(p1,0x02);//clock 1
		}
		for ( i = 0; i < 15;i++)
		{
				outportb(p1,0x00);//clk 0
				outport(p1,alfanum[zasobnikA[cis2]][i]);//dato
				outportb(p1,0x02);//clock 1
		}
		start(A1); //31. biut
		start(A2); //32. bit
		start(0x00); //33. bit
		start(0x00); //34. bit
		start(0x00); //35. bit
}

int main(void)
{
printf("vyberte displej\n");
printf("klavesa a = alfanumericky displej\n");
printf("klavesa n = alfanumericky displej\n");
while(1)
{
klav = getch();
switch(klav)
{
case 'n': //numericky displej
		pocet = 0;
		printf("Zvolili jste numericky displej\n");
		printf("Pokud jste neuèinili nastavte jumper\n");
		printf("Zadejte 5 cisel od 0-9 \n");
		while (pocet != 5)
		{
				klav = getch();
				if (klav >= '0' && klav <= '9') //kdyz zadana hodnota odpovida 0-9 zapis do zasobniku
				{
						printf("Zadali jste:%c\n",klav);
						zasobnikN[pocet] = klav - 48 ; //-48 abych dostal dany index v poli
						//ascii hodnota cisla 0 je 48 , 48 - 48 = 0 -> pozice v poli
						pocet++; //posunuti indexu v zasobniku
				}
		}
		pocet =0;
		start(0x01); //startovaci bit
		while (pocet != 5) //cyklus pro poslani jednotlivych dat
		{
            for (int i = 0; i < 7;i++)
            {
				outportb(p1,0x00);//clk 0
				outport(p1,num[zasobnikN[pocet]][i]);//dato
				outportb(p1,0x02);//clk 1
            }
            pocet++;
		}
        break;
case 'a':
		pocet = 0;
        printf("zvolili jste alfanumericky displej\n");
        printf("Pokud jste neuèinili nastavte jumper\n");
		printf("Zadejte 4 pismena a - z\n");
		while (pocet != 4)
		{
                klav = getch();
				if (klav >= 'a' && klav <= 'z') //kdyz zadana hodnota odpovida a-z zapis do zasobniku
				{
						printf("Zadali jste:%c\n",klav);
						zasobnikA[pocet] = klav - 97 ;//-97 abych dostal dany index v poli
						//ascii hodnota a je 97 , 97 – 97  = 0 -> pozice v poli
						pocet++;
				}
		}
		printf("Nove zadani nastane po zmacknuti k\n");
		while (1)
		{

        if (kbhit())
        {
			klav=getch();
			if (klav == 107 )
			{break;}
        }

		alfa(1,3,0x00,0x01);//pozice v zasobniku 1 a 3,  A1 =0, A2 =1
		delay(5);
		alfa(0,2,0x01,0x00); //pozice v zasobniku 0 a 2, A1 =1, A2 =0
		delay(5);
		}
}

}
}




