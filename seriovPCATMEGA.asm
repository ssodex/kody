.NOLIST
.INCLUDE "m128def.inc"				; ATMEGA128 - Skolni pripravek
.LIST

.DEF TMP=R16						; Docasny registr R16
.DEF SEND=R17						; Registr pro odeslani znaku
.DEF REC=R18						; Registr pro prijem znaku
.DEF DIS_PTR=R19					; Registr pro udrzeni pozice na displeji
.DEF DSP_VAL_REG=R20				; Registr pro udrzeni prave vykreslovane hodnoty
.DEF POLE_POS_REG=R21				; Registr pro udrzeni pozice v poli
.DEF POLE_VAL_REG=R22				; Registr pro udrzeni hodnoty pole
.DSEG

POLE: .BYTE 10					; Pole pro znaky na displeji

.CSEG
.ORG 0x0000
		JMP RESET			; Vektor preruseni RESET
.ORG 0x0020
		JMP TIM0_OVF_ISR		; Vektor preruseni casovace TIMER 0 Overflow
		
RESET:			LDI TMP,HIGH(RAMEND)
				OUT SPH,TMP
				LDI TMP,LOW(RAMEND)
				OUT SPL,TMP		; Zalozeni zasobniku
		
                LDI TMP,0
                STS UBRR0H,TMP		; STS muselo být použito, protože OUT už nedokáže "tak vysoko do pamìti" psát
                LDI TMP,95                 ; Hodnota pro 9600Bd a 14.745600 MHz krystal
                STS UBRR0L,TMP		; Nastaveni baudove rychlosti na 9600
                
                LDI TMP,0b00011000		; Nahozeni TXEN, RXEN, zadne preruseni 8-data bits
                STS UCSR0B,TMP
                
                LDI TMP,0b10000110		; ASYNC, NO parity, 8-data bits, 1-stopbit    Výsledek je 9600 Bd, 8N1
                STS UCSR0C,TMP
                
                LDI TMP,255
                OUT OCR0,TMP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;OCR0A
                LDI TMP,0x02
                OUT TCCR0,TMP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TCCR0A
                LDI TMP,0x03
                OUT TCCR1A,TMP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TCCR0B
                LDI TMP,0x02
                STS TIMSK,TMP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TIMSK0
                
                LDI TMP,0xFF		
                OUT DDRB,TMP        ; Port B nastaveny na vystup  - ZNAKY  DISPLEJE
                OUT DDRD,TMP		; Port C nastaveny na vystup  - POZICE DISPLEJE
                
                LDI TMP,0x00
                MOV DSP_VAL_REG,TMP
                MOV DIS_PTR,TMP
                MOV POLE_VAL_REG,TMP
                MOV POLE_POS_REG,TMP	; Vynulovani registru (inicializace promennych)
                
                SEI				; Povoleni preruseni
                

MAIN_LOOP:      CALL UART_RX
                MOV SEND,REC		; Zpetne echo, abychom na seriove lince videli zadany znak
                CALL UART_TX
				;=================================================dolu
                CPI REC,0
                BRNE NEXT_1

        LDI POLE_VAL_REG,0x3F		; Znak 0
NEXT_1:		CPI REC,1
		BRNE NEXT_2
		LDI POLE_VAL_REG,0x06		; Znak 1
NEXT_2:		CPI REC,2
		BRNE NEXT_3
		LDI POLE_VAL_REG,0x5B		; Znak 2
NEXT_3:		CPI REC,3
		BRNE NEXT_4
		LDI POLE_VAL_REG,0x4F		; Znak 3
NEXT_4:		CPI REC,4
		BRNE NEXT_5
		LDI POLE_VAL_REG,0x66		; Znak 4
NEXT_5:		CPI REC,5
		BRNE NEXT_6
		LDI POLE_VAL_REG,0x6D		; Znak 5
NEXT_6:		CPI REC,6
		BRNE NEXT_7
		LDI POLE_VAL_REG,0x7D		; Znak 6
NEXT_7:		CPI REC,7
		BRNE NEXT_8
		LDI POLE_VAL_REG,0x07		; Znak 7
NEXT_8:		CPI REC,8
		BRNE NEXT_9
		LDI POLE_VAL_REG,0x7F		; Znak 8
NEXT_9:		CPI REC,9
		BRNE NEXT_UNKNOWN
		LDI POLE_VAL_REG,0x6F       ; Znak 9

NEXT_UNKNOWN:   LDI POLE_VAL_REG,0x40		; Znak -
                LDI ZH,HIGH(POLE)
                LDI ZL,LOW(POLE)
                ADD ZL,POLE_POS_REG
                ST Z,POLE_VAL_REG		; Ulozeni prijateho znaku do pole
                INC POLE_POS_REG		; Inkrement pozicniho registru
                CPI POLE_POS_REG,0x08		; Pokud je pozicni registr >7 potom nastav 0
                BRNE MAIN_LOOP
                LDI POLE_POS_REG,0x00		
				RJMP MAIN_LOOP
                

UART_RX:		LDS TMP,UCSR0A              ; Dokud neni bit RXC0 v registru UCSR0A log. 0
                SBRC TMP,RXC0               ; zustan ve smycce, pokud je log. 1, tak je znak	****************SBRS
                RJMP UART_RX                    ; prijat a ulozen do REC
                LDS REC,UDR0
                RET
                
UART_TX:        LDS TMP,UCSR0A              ; Dokud neni vyprazdnen odesilaci buffer UDRE0=Log.0
                SBRC TMP,UDRE0              ; zustan ve smycce, pokud je UDRE0=Log. 1 ******************SBRS
                RJMP UART_TX
                STS UDR0,SEND                 ; Odesli znak z SEND
                RET

TIM0_OVF_ISR:	CLI				; Na chvilku pøerušení vypnu, aby nebylo vyvolané znovu, døív než se zpracuje
                LDI ZH,HIGH(POLE)
                LDI ZL,LOW(POLE)		; Ukazatel na zacatek pole, kde jsou hodnoty
                ADD ZL,DIS_PTR		; Posun na pozici, kterou zobrazujeme
                LD  DSP_VAL_REG,Z		; Nacteni zobrazovane hodnoty z pole znaku
                OUT PORTB,DSP_VAL_REG		; Zobrazeni znaku na PORT B (Zmenit pokud je potreba) /////////////  
                OUT PORTD,DIS_PTR		; Sepnuti patricne pozice (PORT C)
                ;///////////////////////////////////////////////////////////////////// Tohle musite pridat ///////////////////
                ORI DIS_PTR,0b00001000      ; Jednièka na signál ENABLE
                OUT PORTD,DIS_PTR           ; PORT UPRAVIT PODLE TOHO, na jakem portu mate kontrolni registr vyberu pozice displeje
                NOP
                NOP
                NOP
                NOP
                NOP				; Malinké zpoždìní
                ANDI DIS_PTR,0b11110111     ; Nula na signál ENABLE
                OUT PORTD,DIS_PTR          ; PORT UPRAVIT PODLE TOHO, na jakem portu mate kontrolni registr vyberu pozice displeje
                ;////////////////////////////////////////////////////////////////////////////////////////////////////////////
                INC DIS_PTR
                CPI DIS_PTR,0x08		; Pokud je registr pozice vetsi nez 7 ... >
                BRNE ISR_RETURN
                LDI DIS_PTR,0x00		; Nastavime nulu
ISR_RETURN:     SEI
			RETI
