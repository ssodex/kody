.nolist 
.include "m128def.inc" 
.list 

.dseg
data : .byte 15  	;rezervuji 15 bytu 

.cseg 
.org 0x0000
RJMP RESET


;.org 0x001C 		;vektro preteceni casovac 1 
;JMP ISR_OVF1
;.org 0x0020 		; vektor preteceni casovace 0
;JMP ISR_OVF0 		; skok na INTERRUPT SUB ROUTINE pro zpracovani



RESET:
	LDI r16, low(ramend) 	;inicializace
	OUT SPL, R16
	LDI r16, high(ramend)
	OUT SPH,R16

	ldi r16,0xff
	out ddre, r16 			;nastavení displeje jako vystup

	ldi r16,0x0f 			;kl. sloupce vystup, radky vstup
	out ddrb, r16
 
	ldi r16,0b0000_0000
	sts UCSR1A,r16
	ldi r16,0b0000_1000
	sts UCSR1B, r16
	ldi r16,0b0000_0110
	sts UCSR1C, r16
	
	ldi r16,95
	sts UBRR1L,r16
	ldi r16,0x00
	sts UBRR1H,r16

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
	ldi r23, 49	
	ldi r17,0b00001111		;"pozice zacatku hodnot v programove pameti pro cislo 1"
	out porte, r17
	rcall uloz			
	rcall zpozdeni2			;zavolame zpozdeni 200ms   
	ret
cis4:
	ldi r23, 52
	rcall uloz
	rcall zpozdeni2
	ret
cis7:
	ldi r23, 55
	rcall uloz
	rcall zpozdeni2
	ret
cis2:
	ldi r23, 50
	ldi r17,0b11110000		;"pozice zacatku hodnot v programove pameti pro cislo 1"
	out porte, r17
	rcall uloz
	rcall zpozdeni2
	ret
cis5:
	ldi r23, 53
	rcall uloz
	rcall zpozdeni2 
	ret
cis8:
	ldi r23, 56
	rcall uloz
	rcall zpozdeni2 
	ret
cis0:
	ldi r23, 48
	rcall uloz
	rcall zpozdeni2
	ret
cis9:
	ldi r23, 57
	rcall uloz
	rcall zpozdeni2
    ret
cis6:
	ldi r23, 54
	rcall uloz
	rcall zpozdeni2
	ret
cis3:
	ldi r23, 51
	rcall uloz
	rcall zpozdeni2
	ret
cisH:
	ret

uloz :
	sts UDR1, r23
	ret


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


