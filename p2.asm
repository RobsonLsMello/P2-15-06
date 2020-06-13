.INCLUDE "atmega328p.inc"  ; seu arquivo principal de mapeamento das vari?veis   
.device		atmega328P
.nolist
.list

;============
;Declara??es:



.ORG 0x0000              
    rjmp INICIO

	.def safeLed	=r22
	.def warningLed =r23
	.def dangerLed	=r24
	.def allLeds	=r25
 
INICIO:
	  call ledInit

	  rjmp LOOP
    
LOOP:

	rjmp turnOnLed
    rjmp LOOP                

ledInit:
	ldi safeLed,0b00000000
	ldi warningLed,0b00000001
	ldi dangerLed,0b00000010
	ldi allLeds,0b00000111
	out ddrb,allLeds
	ret
	
turnOnSafeLed:
	out portb, safeLed
    rjmp INICIO

turnOnwarningLed:
	out portb, warningLed
    rjmp INICIO

turnOnDangerLed:
	out portb, dangerLed
    rjmp INICIO

turnOnLed:
	cpi r19, 0b01000000
	brlo turnOnSafeLed
	cpi r19, 0b10001000
	brlo turnOnwarningLed
	cpi r19, 0b10001000
	brge turnOnDangerLed
	ret
.EXIT 

