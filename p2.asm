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
	.def portasBHabilitadas	=r25
	
	.def adcValue	=r20
 
INICIO:
	  call ledInit
      call adcInit ;inicia o conversor digital
	  rjmp LOOP
    
LOOP:
    call adcRead ;ler sinal analógico
    call adcWait ;resetar ADCSRA
    lds r18, ADCL  ; primeiro deve-se ler o ADCL, o valor low
	;apenas os dois primeiro bit são utilizados
    lds r19, ADCH  ; para obter o valor de ADCH em 8 bits, o valor high
	;oito bits utilizadso
	0000 0000 00       00 0000
	rjmp turnOnLed
    rjmp LOOP                
        
adcInit:
	;Admux Seleção de multeplexador do conversor analógico
    ldi r16, 0b01100000 
	;01100000
	;01 avcc usa como referencia ao aref
	;  1 ativa o adlar para ajustar o resultado para a esquerda
	;   0 reservado
	;    0000 para direcionar a porta analógica
	;0000 = adc0
    sts ADMUX, r16 ;setar configurações de acordo com o 0b01100000 no admux
                          
	;ADCSRA controlador do conversor analógico e do status do registro A
    ldi r16, 0b10000101   
	;10000101
	;1 ativa a conversão analógica - ADEN
	; 0 desabilitado ADSC para apenas uma conversão
	;  0 desabilitado ADATE para converter um sinal de disparo
	;   0 reservado para ADIF, enquanto 0 conversão ainda não completou
	;    0 não seta o SREG I, já que não tem necessidade para a interrupção
	;	  101  ADPS, determinamos o fator entre o clock do sistema e o clock do  adc em 32
    sts ADCSRA, r16 ;setar configurações de acordo com o 10000101 no ADCSRA   

    ret

adcRead:
    ldi r16, 0b01000000   ; conversão em  progresso
	;01000000
	; 1 habilitou o ADSC para apenas uma conversão

    lds r17, ADCSRA       ;seta  0b01000000 no r17
    or  r17, r16          ;0b10000101 or 0b01000000
    sts  ADCSRA, r17      ;0b11000101
    ret

adcWait:
    lds r17, ADCSRA       ; set  ADCSRA no r17
    sbrs r17, 4           ; verificando ADIF se foi setado pelo hardware

    jmp adcWait           ; Continua verificação enquanto o ADIF for 0, quando chegar em 1 continua

    ldi r16, 0b00010000   ; setamos o adif em 1 para mostrar que a
	;0b00010000
	;   1 reservado para ADIF, conversão completa, preparada para uma nova consulta
    lds r17, ADCSRA       ;
    or  r17, r16          ;
    sts  ADCSRA, r17      ;
    ret

ledInit:
	ldi safeLed,0b00000000 ; 00 = D0
	ldi warningLed,0b00000001; 01 = D1
	ldi dangerLed,0b00000010; 10 = D2

	ldi portasBHabilitadas,0b00000011

	out ddrb,portasBHabilitadas
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
	cpi r19, 0b01000000 ;< 64 1,25V
	brlo turnOnSafeLed
	cpi r19, 0b10001000; < 136 2.66V
	brlo turnOnwarningLed
	cpi r19, 0b10001000; >136 2.66V
	brge turnOnDangerLed
	ret
.EXIT 

