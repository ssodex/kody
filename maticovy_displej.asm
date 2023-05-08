.nolist 
.include "m128def.inc" 
.list 

.dseg
data : .byte 15  	;rezervuji 15 bytu 

.cseg 
.org 0x0000
RJMP RESET


.org 0x001C 		;vektro preteceni casovac 1 
JMP ISR_OVF1
.org 0x0020 		; vektor preteceni casovace 0
JMP ISR_OVF0 		; skok na INTERRUPT SUB ROUTINE pro zpracovani



RESET:
	LDI r16, low(ramend) 	;inicializace
	OUT SPL, R16
	LDI r16, high(ramend)
	OUT SPH,R16

	ldi r16,0xff
	out ddre, r16 			;nastavení displeje jako vystup

	ldi r16,0x0f 			;kl. sloupce vystup, radky vstup
	out ddrb, r16
 

	LDI R16,0b00000101 		;hodnota preddelicky pro casovac 0 
	OUT TCCR0,R16
	
	LDI R16,0x00
	OUT TCCR1A,R16

	ldi R16,0b00000100		;hodnota pro preddelicku pro casovac 1
	out TCCR1B , r16
	
	LDI R16,0x05 			;povolime preruseni od preteceni casovace TOIE0 a T0IE1
	OUT TIMSK,R16
	
	ldi r16,0x00 			;zde hodnota z datove pameti, kterou pricitam k Z pointeru
	ldi r17,0x00			;zde hodnota pro aktivaci sloupce
	ldi r18,0x00
	ldi r20,0x08			;pocitadlo pozice Z pointeru
	ldi r21,0x00			;zde hodnota, kterou zobrazuji
	ldi r22,0x00			;pocitadlo pozice X pointeru
	ldi r23,0x00			;zde hodnota, kterou ukladam do datove pameti (hleda zacatek hodnot v prog. pameti pro dane cislo)
	ldi r24,0x00			;pocitadlo poctu zadanych cisel
	

loop_m:
	ldi r17,0b11111110  	;hodnota pro kontrolu 1. sloupece ->cekam na hvezdicku
	out portb, r17	    	
	rcall zpozdeni			;zavolame programove zpozdeni 0,1ms
	in r18,pinB				;z pinu B nacteme hodnotu do r18
	cpi r18, 0b01111110		;kdyz se r18 = s hodnotou pro dane tlacitko => tlacitko stlaceno
	breq kont1 				
	rjmp loop_m

kont1: 						;reset pointeru, nastaveni pocitadla na 0 , vypnuti casovacu
	ldi XL,low(data)
	ldi XH,high(data)
	ldi r24, 0x00
	cli

kont:						
	rcall sl1  				
	rcall sl2
	rcall sl3
rjmp kont

sl1:
	ldi r17,0b11111110  	;hodnota pro kontrolu 1. sloupece
	out portb, r17	    	;poslu na portb
	rcall zpozdeni			;zavolame programove zpozdeni 0,1ms
	in r18,pinB				;z pinu B nacteme hodnotu do r18

	cpi r18, 0b11101110		;kdyz se r18 rovna s hodnotou pro dane tlacitko => tlacitko stlaceno
	breq cis1				
	cpi r18, 0b11011110		
	breq cis4				
	cpi r18, 0b10111110 	
	breq cis7				
	ret						;vratim se zpet do hlavniho cyklu

sl2:
	ldi r17,0b11111101  	;hodnota pro kontrolu 2. sloupece
	out portb, r17
	rcall zpozdeni
	in r18,pinB

	cpi r18, 0b11101101
	breq cis2
	cpi r18, 0b11011101
	breq cis5
	cpi r18, 0b10111101
	breq cis8
	cpi r18, 0b01111101
	breq cis0
	ret

sl3:
	ldi r17,0b11111011 		;hodnota pro kontrolu 3. sloupece
	out portb, r17
	rcall zpozdeni
	in r18,pinB

	cpi r18, 0b11101011
	breq cis3
	cpi r18, 0b11011011
	breq cis6
	cpi r18, 0b10111011
	breq cis9
	cpi r18, 0b01111011
	breq cisH
	ret

cis1:
	ldi r23, 0x08			;"pozice zacatku hodnot v programove pameti pro cislo 1"
	rcall uloz			
	rcall zpozdeni2			;zavolame zpozdeni 200ms   
	ret
cis4:
	ldi r23, 0x20
	rcall uloz
	rcall zpozdeni2
	ret
cis7:
	ldi r23, 0x38
	rcall uloz
	rcall zpozdeni2
	ret
cis2:
	ldi r23, 0x10
	rcall uloz
	rcall zpozdeni2
	ret
cis5:
	ldi r23, 0x28
	rcall uloz
	rcall zpozdeni2 
	ret
cis8:
	ldi r23, 0x40
	rcall uloz
	rcall zpozdeni2 
	ret
cis0:
	ldi r23, 0x00
	rcall uloz
	rcall zpozdeni2
	ret
cis9:
	ldi r23, 0x48
	rcall uloz
	rcall zpozdeni2
    ret
cis6:
	ldi r23, 0x30
	rcall uloz
	rcall zpozdeni2
	ret
cis3:
	ldi r23, 0x18
	rcall uloz
	rcall zpozdeni2
	ret
cisH:
	ldi XL,low(data)	;reset pointeru
	ldi XH,high(data)	;
	sei					;povolime preruseni
	rjmp loop_m

uloz :
	st X+, r23			;hodnotu z r23 ulozi do datove pameti a posunu X pointer
	inc r24 			;+1 k pocctu zadanych cisel
	ret


ISR_OVF0:				;zobrazeni daneho cisla na displeji
	cpi r20, 0x08		;kdyz se r20 = s 0x08 =>Z pointer je na konci hodnot
	breq zac			
	lpm R21, Z+			;z programove pameti do r21 nactu hodnotu na kterou ukazuje Z pointer
	out porte, r21
	inc r20				;+1 k pocitadlu (jedno cislo ma 8 hodnot v programove pameti)
	reti 	
zac:					;najdu zacatek hodnot pro zobrazovane cislo
	ldi r20, 0x00		;vynuluji pocitadlo
	ldi ZL,low(2*tab)	;reset Z pointeru
	ldi ZH,high(2*tab)
	add ZL, r16         ;posunuti na zacatek hodnot v programove pameti (tab) pro dane zobrazovane cislo
	ldi r23, 0x00
	adc ZH, r23		    ;pricteni zybytku k hornimu bajtu (kdyby byl)
	reti
		

ISR_OVF1:				;zmena cisla							
	cp r24, r22			;kdyz se r24 = r22 => zobrazil jsem vsechny cisla
	breq srov			
	ld r16,X+ 			;do r16 hodnotu na kterou ukazuje X pointer 
 	inc r22				;+1 k pocitadlu poctu posunuti X pointeru
	reti
srov :  				;reset X pointeru
	ldi XL,low(data)
	ldi XH,high(data)
	ldi r22,0x00		;vynulovani pocitadla
	reti
	

zpozdeni:				;zpozdeni 0,1ms
	ldi  r28, 3
    ldi  r29, 19
opak:
	dec r28
	brne opak
	dec r29
	brne opak
	ret

zpozdeni2:				;zpozdeni 200ms
	ldi  r25, 17
    ldi  r28, 60
    ldi  r29, 204
L1: 
	dec  r29
    brne L1
    dec  r28
    brne L1
    dec  r25
    brne L1
	ret



tab :
.db 0b10001_000, 0b01110_100, 0b01110_010, 0b01110_110, 0b01110_001 ,0b01110_101, 0b10001_011, 0xFF ;0
.db 0b11101_000, 0b11001_100, 0b10101_010, 0b11101_110, 0b11101_001 ,0b11101_101, 0b11101_011, 0xFF ;1
.db	0b10001_000, 0b01110_100, 0b11110_010, 0b11101_110, 0b11011_001 ,0b10111_101, 0b00000_011, 0xFF ;2
.db 0b10001_000, 0b01110_100, 0b11110_010, 0b11001_110, 0b11110_001 ,0b01110_101, 0b10001_011, 0xFF ;3
.db 0b11101_000, 0b11001_100, 0b10101_010, 0b01101_110, 0b00000_001 ,0b11101_101, 0b11101_011, 0xFF ;4
.db 0b00000_000, 0b01111_100, 0b00001_010, 0b11110_110, 0b11110_001 ,0b01110_101, 0b10001_011, 0xFF ;5
.db 0b10001_000, 0b01110_100, 0b01111_010, 0b00001_110, 0b01110_001 ,0b01110_101, 0b10001_011, 0xFF ;6
.db 0b00000_000, 0b11110_100, 0b11101_010, 0b11011_110, 0b11011_001 ,0b11011_101, 0b11011_011, 0xFF ;7
.db 0b10001_000, 0b01110_100, 0b01110_010, 0b10001_110, 0b01110_001 ,0b01110_101, 0b10001_011, 0xFF ;8
.db 0b10001_000, 0b01110_100, 0b01110_010, 0b10000_110, 0b11110_001 ,0b01110_101, 0b10001_011, 0xFF ;9







	

