.INCLUDE "M16aDEF.inc"
.EQU RS = 0
.EQU RW = 1
.EQU EN = 2
.org 0x00
	jmp start
.org 0x02
	jmp BEGIN
.org 0x100
start:
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	LDI R21,LOW(RAMEND)
	OUT SPL, R16

	SEI
	LDI R16,1<<INT0  ;int0=6
	OUT GICR,R16
	LDI R16,0x01
	OUT MCUCR,R16

	SBI DDRA,RS ; RS 0 for command
	SBI DDRA,RW ;RW = 0 for write
	SBI DDRA,EN
	SBI DDRA,4
	SBI DDRA,5
	SBI DDRA,6
	SBI DDRA,7

	CBI DDRD,2
	SBI DDRA,3
	CBI PORTA,3

	LDI R20,0x33
	CALL CMNDWRT
	CALL DELAY_2ms
	
	LDI R20,0x32
	CALL CMNDWRT
	CALL DELAY_2ms

	LDI R20,0x28 ;init LCD 2 lines,5x7 matrix
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms ;wait 2 ms

	LDI R20,0x0E ;display on, cursor on
	CALL CMNDWRT ;call command function
	CALL DELAY_2ms

	LDI R20,0x01 ;clear LCD
	CALL CMNDWRT
	CALL DELAY_2ms
	
	LDI R20,0x02
	CALL CMNDWRT
	CALL DELAY_2ms

	LDI R20,'D'
	CALL DATAWRT
	CALL DELAY_2ms

	LDI R20,'I'
	CALL DATAWRT
	CALL DELAY_2ms

	LDI R20,'S'
	CALL DATAWRT
	CALL DELAY_2ms
	
	LDI R20,'='
	CALL DATAWRT
	CALL DELAY_2ms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loop:

	CBI PORTA,3
	call DELAY10
	SBI PORTA,3
	call DELAY10
	CBI PORTA,3
	call writing
	call delay1s
	rjmp loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BEGIN:
	;R31,R30
	SBIC PIND,2
	CALL onn
	SBIS PIND,2
	CALL offf		
	RETI

onn:
	LDI R31,0x00
	OUT TCNT1L,R31 
	OUT TCCR1A,R31 
	LDI R31,0x03
	OUT TCCR1B,R31
	RET
offf:
	LDI R31,0x00
	OUT TCCR1B,R31
	IN R30,TCNT1L
	RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;LCD;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R20,R21,R22
CMNDWRT:
	mov R21,R20
	ANDI R21,0xf0
	call write
	CBI PORTA,RS ; RS 0 for command
	CBI PORTA,RW ;RW = 0 for write
	SBI PORTA,EN ;EN = 1
	CALL SDELAY ;make a wide EN pulse
	CBI PORTA,EN ;EN=O for H-to-L pulse
	CALL DELAY_lOOus ;wait 100 us
	
	mov R21,R20
	swap R21
	ANDI R21,0xf0
	call write
	CBI PORTA,RS ; RS 0 for command
	CBI PORTA,RW ;RW = 0 for write
	SBI PORTA,EN ;EN = 1
	CALL SDELAY ;make a wide EN pulse
	CBI PORTA,EN ;EN=O for H-to-L pulse
	CALL DELAY_lOOus ;wait 100 us
	RET

DATAWRT:
	mov R21,R20
	ANDI R21,0xF0
	call write
	SBI PORTA,RS ;RS 1 for data
	CBI PORTA,RW ;RW = 0 for write
	SBI PORTA,EN ;EN = 1	
	CALL SDELAY ;make a wide EN pulse
	CBI PORTA,EN ;EN=O for H-to-L pulse

	mov R21,R20
	swap R21
	ANDI R21,0xF0
	call write
	SBI PORTA,RS ;RS 1 for data
	CBI PORTA,RW ;RW = 0 for write
	SBI PORTA,EN ;EN = 1	
	CALL SDELAY ;make a wide EN pulse
	CBI PORTA,EN ;EN=O for H-to-L pulse
	CALL DELAY_lOOus ;wait 100 us

	RET

	write:
	mov R22,R21
	
	SBRC R22,4
	SBI PORTA,4
	SBRS R22,4
	CBI PORTA,4

	SBRC R22,5
	SBI PORTA,5
	SBRS R22,5
	CBI PORTA,5

	SBRC R22,6
	SBI PORTA,6
	SBRS R22,6
	CBI PORTA,6

	SBRC R22,7
	SBI PORTA,7
	SBRS R22,7
	CBI PORTA,7
	
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DELAY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DELAY10:
	LDI R16,6
DR0: 
	NOP
	NOP
	DEC R16
	BRNE DR0
	RET

delay1s:
	LDI R16,255
daf0:
	LDI R17,255
daf1:
	LDI R18,6
daf2:
	dec R18
	BRNE daf2
	dec R17
	BRNE daf1
	dec R16
	BRNE daf0
	ret

SDELAY: 
	NOP
	NOP
	RET


DELAY_lOOus:
	LDI R18,60
DRO: 
	CALL SDELAY
	DEC R18
	BRNE DRO
	RET


DELAY_2ms:
	LDI R17,20
LDRO: 
	CALL DELAY_lOOus
	DEC R17
	BRNE LDRO
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writing:
	LDI R28,10
	LDI R27,10
	LDI R26,48
		
	CP R30, R28
	BRLO w00

	ADD R28,R27
	CP R30, R28
	BRLO w10

	ADD R28,R27
	CP R30, R28
	BRLO w20

	ADD R28,R27
	CP R30, R28
	BRLO w30

	

w00:
	LDI R20,0x84
	CALL CMNDWRT
	CALL DELAY_2ms
	
	LDI R20,'0'
	CALL DATAWRT
	CALL DELAY_2ms
	
	ADD R26,R30
	MOV R20,R26
	CALL DATAWRT
	CALL DELAY_2ms
	RET

w10:
	LDI R20,0x84
	CALL CMNDWRT
	CALL DELAY_2ms
	
	 
	LDI R20,'1'
	CALL DATAWRT
	CALL DELAY_2ms
	SUBI R30,10
	ADD R26,R30
	MOV R20,R26
	CALL DATAWRT
	CALL DELAY_2ms


	RET
w20:
	LDI R20,0x84
	CALL CMNDWRT
	CALL DELAY_2ms

	LDI R20,'2'
	CALL DATAWRT
	CALL DELAY_2ms

	SUBI R30,20
	ADD R26,R30
	MOV R20,R26
	CALL DATAWRT
	CALL DELAY_2ms

	RET
w30:
	LDI R20,0x84
	CALL CMNDWRT
	CALL DELAY_2ms

	LDI R20,'3'
	CALL DATAWRT
	CALL DELAY_2ms
	SUBI R30,30
	ADD R26,R30
	MOV R20,R26
	CALL DATAWRT
	CALL DELAY_2ms

	RET
