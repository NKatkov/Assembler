.device ATmega128
.include	"m128def.inc"
;===================================================================
;Определения регистров и битов
;===================================================================
.def	temp		=r16
.def	dig			=r17
.def	SYM			=r18
.def	SYM_temp	=r19
.def	deley		=r20
.def	deley1		=r21
.def	deley2		=r22
.def	scan_kbd	=r23

.equ	razr1		=PE4
.equ 	kbd			=PIND
.equ 	row1		=PD0
;===================================================================
;********* Вектор сброса ********************
;===================================================================
.CSEG
.org	$0000	;начальный адpес пpогpаммы

	rjmp	RESET
;===================================================================
.MACRO OUTP
	ldi R16,@1 			
	OUT @0,R16 	
.ENDM
;===================================================================
;Подпрограмма сканирования клавиатуры
;===================================================================
Keyboard:
	cbi	PORTD,row1
	rcall	del_key
	in	temp, kbd
	sbi	PORTD, row1
	com	temp

	cbr	temp,$8F
	breq _no_key
	sbr	temp,(1<<row1)

	cp	temp,scan_kbd
	breq _no_key

	mov	scan_kbd,temp
	rcall	key_det
	mov	dig,temp
	ret
_no_key:
	ret
;===================================================================
;Подпрограмма определения нажатой клавиши
;===================================================================
key_det:
	cpi	temp,0b00010001
	brne	_key2
	rjmp snake1
_key2:
	cpi	temp,0b00100001
	brne	_key3
	rjmp snake2
_key3:
	cpi	temp,0b01000001
	brne	_err_key
	rjmp	main
_err_key:
	ret
;===================================================================
;Подпрограмма задержки для клавиатуры
;===================================================================
del_key:
	ldi	deley,1
_del_key1:
	dec	deley
	brne	_del_key1
	ret
;===================================================================
;Подпрограмма задержки для индикатора
;===================================================================
_deley:
    ldi deley,4
_deley1:
    ldi deley1,165
_deley2:
    ldi deley2,254
_deley3:
    dec deley2
    brne _deley3
    dec deley1
	brne _deley2
    dec deley
    brne _deley1
ret
;===================================================================

snake1:
	mov SYM,SYM_temp
	back1:
		rcall Disp
		INC SYM
		cpi	SYM,7
	brne back1
	ldi SYM_temp,1
	call snake1
ret

snake2:
	mov SYM,SYM_temp
	back2:
		rcall Disp
		dec SYM
		cpi	SYM,0
	brne back2
	ldi SYM_temp,6
	call snake2
ret


Disp:
	
	ldi ZL, LOW (2*sym_table)
	ldi ZH, HIGH(2*sym_table)
	ADD ZL, SYM
	LPM
	SBRC R0, 0
	OUTP PORTE,(0<<razr1)
	out PORTC, r0
	
	OUTP PORTE,(1<<razr1)
	rcall	_deley
	rcall	Keyboard
	
	mov SYM_temp,SYM
ret

;===================================================================
RESET:
;инициализация стека
	ldi	temp,High(RAMEND)	
	out	SPH,temp	;устанавливаем указатель стека
	ldi	temp,Low(RAMEND)	;на конечный адрес ОЗУ контроллера
	out	SPL,temp       	
;очищаем регистры
	clr	dig
	clr	scan_kbd
	clr SYM
;настройка выходных линий разрядов и их выключение
	in	temp,DDRE
	sbr	temp,(1<<razr1)
	out	DDRE,temp
	in	temp,PORTE
	sbr	temp,(1<<razr1)
	out	PORTE,temp
;настройка выходных линий сегментов и их выключение
	ldi	temp,$FF
	out	DDRC,temp
	out	PORTC,temp
;настройка выходных линий клавиатуры
	in	temp,DDRD
	sbr	temp,(1<<row1)
	out	DDRD,temp
	ldi	temp,$FF
	out	PORTD,temp
	ldi SYM_temp, 6
;===================================================================
;Основная программа
;===================================================================
main:
	rcall	Keyboard

	rjmp	main
;===================================================================
;Таблица констант в памяти программ
;===================================================================
sym_table:
 .DB 255, 254, 253, 251, 247, 239, 223
.EXIT
