extern setKeyINT
extern unsetKeyINT
extern p_i
extern p_t
extern tecla
extern tecla_u
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

extern dx1
extern dy1

extern dx2
extern dy2

extern step
extern topBorder

;------------
extern apagaCobra1
extern apagaCobra2
extern apagaTelaPause
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
extern setClockINT
extern unsetClockINT
extern pauseClock
extern setEasy
extern setMid
extern setHard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
extern line
extern full_circle
extern modo_anterior
extern cor
extern vermelho
extern preto
extern cyan
extern branco_intenso
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
extern enable
extern printaTelaInicial
extern deletaTelaInicial
extern printaTelaQuit
extern printaTelaVida
extern apagaTelaGameOver
extern apagaTelaQuit
extern atualizaTelaVida
extern restartCobrinhas
global modoAtual
global fruitX1
global fruitY1
global fruitX2
global fruitY2
global num_frutas
global val1
global val2
global estadoJogo

segment code
..start:

;Inicializa registradores
    MOV		AX,data
    MOV 	DS,AX
    MOV 	AX,stack
    MOV 	SS,AX
    MOV 	SP,stacktop

;seta interrupção de clock
   call setKeyINT

;Salvar modo corrente de video(vendo como está o modo de video da maquina)
    MOV  	AH,0Fh
    INT  	10h
    MOV  	[modo_anterior],AL

	;Alterar modo de video para gráfico 640x480 16 cores
    MOV     	AL,12h
    MOV     	AH,0
    INT     	10h

	call printaTelaInicial
	
;Loop principal
direcao:

	;Pega a última tecla pressionada do buffer do teclado
    MOV     AX,[p_i]
	CMP     AX,[p_t]
	JE      direcao
	INC     word[p_t]
	AND     word[p_t],7 ;TALVEZ REMOVER
	MOV     BX,[p_t]
	XOR     AX, AX
    MOV byte AL, [BX+tecla]
	MOV     [tecla_u],AL
	

	;Cada um dos trechos de código subsequente chama o tratamento de sua tecla correspondente
	CMP AL,0x11			;apertou W
	JNE naoW
	JMP set_W
	naoW:

	CMP AL,0x1E			;apertou A
	JNE naoA
	JMP set_A
	naoA:
	
	CMP AL,0x1F			;apertou S
	JNE naoS
	JMP set_S
	naoS:
	
	CMP AL,0x20			;apertou D
	JNE naoD
	JMP set_D
	naoD:

	CMP AL,0x48			;apertou seta para cima
	JNE naoUP
	JMP set_arrowUP
	naoUP:

	CMP AL,0x4B			;apertou seta para a esquerda
	JNE naoLEFT
	JMP set_arrowLEFT
	naoLEFT:

	CMP AL,0x50			;apertou seta para baixo
	JNE naoDOWN
	JMP set_arrowDOWN
	naoDOWN:

	CMP AL,0x4D         ;apertou seta para a direita
	JNE naoRIGHT
	JMP set_arrowRIGHT
	naoRIGHT:

	CMP AL,0x19			; apertou p
	JNE naoPAUSE
		cmp byte [estadoJogo], 0
		jne naoPAUSE
		call pauseClock
	naoPAUSE:

	CMP AL,0x10			; apertou q
	JNE naoQ
    	JMP set_Q
	naoQ:

	; tratamento y/n
	;Y 15
	;N 31
	CMP AL, 0x15		; apertou y
	jne naoY
		jmp set_Y
	naoY:

	CMP AL, 0x31		; apertou n
	jne naoN
		jmp set_N
	naoN:
	
	CMP AL, 0x1C		;apertou Enter
	jne naoEnter
		jmp set_enter
	naoEnter:

	jmp direcao


set_enter:
;Usado para startar o jogo
	cmp byte [estadoJogo], 3	; se jogo não está na tela inicial, ignora
	je telaInicial
		jmp direcao
	telaInicial:
	
	cmp word[modoAtual], 3		; se modo é de saída, sai (clockINT é feito para ser desativado na hora de sair)
	jne naoSai
		call setClockINT
		call sai
	naoSai:
	
	push BX

	cmp word[modoAtual], 0		; se modo é 0 (easy), seta o clock para o mais baixo
	jne naoEasy
		call setEasy
	naoEasy:

	cmp word[modoAtual], 1		; se modo é 1 (mid), seta o clock para o médio
	jne naoMid
		call setMid
	naoMid:

	cmp word[modoAtual], 2		; se modo é 2 (dificil), seta o clock para o mais alto
	jne naoHard
		call setHard
	naoHard:
	
	pop BX

	call deletaTelaInicial	
	mov word[estadoJogo], 0
	call startGame
	
	jmp direcao

set_Q:
	cmp byte [estadoJogo], 0
	je running
		jmp direcao
	running:
	mov byte [estadoJogo], 2
	mov byte [enable], 0
	call printaTelaQuit
	jmp direcao
	
set_Y:
	cmp byte [estadoJogo], 0		; se jogo = 0 (live), feijoada
	jne naoLiveY
		jmp direcao
	naoLiveY:			
	
	cmp byte [estadoJogo], 1		; se jogo = 1 (game over), reiniciar
	jne naoOverY
		call restart
	naoOverY:

	
	jmp sai
	
restart:
	call apagaTelaGameOver				; apaga a tela de game over, as cobrinhas e reimprime as cobrinhas
	call apagaCobra1
	call apagaCobra2
	call printaFrutas					; retorna as frutinhas
	call restartCobrinhas
	call atualizaTelaVida
	mov byte[enable], 1
	mov byte[estadoJogo], 0
	jmp direcao

set_N:
	cmp byte [estadoJogo], 0		; se jogo = 0 (live), feijoada
	jne naoLiveN
		jmp direcao
	naoLiveN:	

	cmp byte [estadoJogo], 2		; se jogo = 2 (quit), apaga a tela de saída, volta estado jogo e enable
	jne naoQuitN
		call apagaTelaQuit
		call apagaTelaPause
		mov byte [estadoJogo], 0
		mov byte [enable], 1
		jmp direcao
	naoQuitN:
	
	jmp sai							; se jogo = 1 (game over), sair
	
	

set_W:
;Move a cobra 1 para cima
	push ax
	cmp word[dy1], 0
	jl blockW
	mov ax, step
	MOV word[dx1], 0
	MOV word[dy1], ax
	blockW:
	pop ax
	JMP direcao

set_A:
;Move a cobra 1 para esquerda
	push ax
	cmp word[dx1], 0
	jg blockA
	mov ax, 0
	sub ax, step
	MOV word[dx1], ax
	MOV word[dy1], 0
	blockA:
	JMP direcao
	pop ax

set_S:
;Move a cobra 1 para baixo
	push ax
	cmp word[dy1], 0
	jg blockS
	mov ax, 0
	sub ax, step
	MOV word[dx1], 0
	MOV word[dy1], ax
	blockS:
	JMP direcao
	pop ax

set_D:
;Move a cobra 1 para direita
	push ax
	cmp word[dx1], 0
	jl blockD
	mov ax, step
	MOV word[dx1], ax
	MOV word[dy1], 0
	blockD:
	JMP direcao
	pop ax

set_arrowUP:
;Move a cobra 2 para cima, se live, se no menu inicial, troca a opção
	cmp byte [estadoJogo], 3
	
	jne naoLiveUp
	mov ax, [modoAtual]
	cmp ax, 0
	je pulaSomaUp
	dec ax
	pulaSomaUp:
	mov [modoAtual], ax
	call printaTelaInicial

	jmp direcao

	naoLiveUp:
	push ax
	cmp word[dy2], 0
	jl blockUP
	mov ax, step
	MOV word[dx2], 0
	MOV word[dy2], ax
	blockUP:
	JMP direcao
	pop ax

set_arrowLEFT:
;Move a cobra 2 para esquerda
	push ax
	cmp word[dx2], 0
	jg blockLEFT
	mov ax, 0
	sub ax, step
	MOV word[dx2], ax
	MOV word[dy2], 0
	blockLEFT:
	JMP direcao
	pop ax

set_arrowDOWN:
;Move a cobra 2 para baixo, se live, se no menu inicial, troca a opção
	push ax
	cmp byte [estadoJogo], 3
	jne naoLiveDown
	mov ax, [modoAtual]
	cmp ax, 3
	je pulaSomaDown
	inc ax
	pulaSomaDown:
	mov [modoAtual], ax
	call printaTelaInicial

	jmp direcao

	naoLiveDown:
	cmp word[dy2], 0
	jg blockDOWN
	mov ax, 0
	sub ax, step
	MOV word[dx2], 0
	MOV word[dy2], ax
	blockDOWN:
	JMP direcao
	pop ax

set_arrowRIGHT:
;Move a cobra 2 para direita
	push ax

	cmp word[dx2], 0
	jl blockRIGHT
	mov ax, step
	MOV word[dx2], ax
	MOV word[dy2], 0
	blockRIGHT:
	JMP direcao
	pop ax

sai:
	;Chama as funcões de unset de cada interrupção ativada
	;Nomeadamente interrupção de clock e de teclado
	CALL unsetKeyINT
	CALL unsetClockINT

	mov ax, 0003h      ; AH=00h set video mode, AL=03h text 80x25
    int 10h            ; set video mode clears screen e volta pro texto
                       ; (BIOS INT 10h serviço 00h) [web:38][web:46]

    ; (opcional) garante página ativa 0
    mov ax, 0500h      ; AH=05h select active display page, AL=0
    int 10h

    mov ax, 4C00h
    int 21h


; Função principal para início do programa: Gera paredes, 
;printa a tela de vidas, as frutas e dá set clock int
startGame:
	mov bx, branco_intenso
    MOV		byte[cor],bl	;Printa as paredes do jogo
	MOV		AX,0
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	MOV		AX,639
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	CALL	line
	
	MOV		byte[cor],bl	
	MOV		AX,0
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	MOV		AX,topBorder
	PUSH	AX
	CALL	line


	MOV		byte[cor],bl	
	MOV		AX,639
	PUSH	AX
	MOV		AX,topBorder
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	MOV		AX,topBorder
	PUSH	AX
	CALL	line


	MOV		byte[cor],bl	
	MOV		AX,639
	PUSH	AX
	MOV		AX,topBorder
	PUSH	AX
	MOV		AX,639
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	CALL	line

	call printaTelaVida
	call printaFrutas
	call atualizaTelaVida

	call setClockINT
	ret


;Funcção que printa na tela todas as frutas contidas em num_frutas
;Utilizada tanto para restart quanto para começo de jogo
printaFrutas:
	push si
	push ax
	push cx
	
	mov ax, vermelho
	mov byte[cor],al
	mov cx, [num_frutas]
	imprime_frutas1:
	
		mov si, cx
		shl si, 1

		mov word[val1 + si], 1
		mov ax, [fruitX1 + si]
		push ax
		mov ax, [fruitY1 + si]
		push ax
		mov		AX, 3
		PUSH 	AX
    	CALL	full_circle

		loop imprime_frutas1

	mov ax, cyan
	mov byte[cor],al
	mov cx, [num_frutas]
	imprime_frutas2:
	
		mov si, cx
		shl si, 1
		
		mov word[val2 + si], 1
		mov ax, [fruitX2 + si]
		push ax
		mov ax, [fruitY2 + si]
		push ax
		mov		AX, 3
		PUSH 	AX
    	CALL	full_circle

		loop imprime_frutas2
	pop cx
	pop ax
	pop si
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
segment data
	maxFrutas equ 100
	num_frutas dw 40
	fruitX1 dw 347, 499, 298, 356, 173, 453, 617, 168, 221, 134, 545, 252, 377, 454, 602, 322, 462, 356, 170, 223, 326, 561, 489, 321, 170, 224, 27, 619, 462, 88, 199, 532, 215, 156, 502, 561, 61, 147, 230, 222, 104, 234, 427, 174, 353, 95, 384, 153, 374, 272, 450, 270, 442, 347, 211, 363, 125, 189, 64, 78, 391, 370, 514, 521, 82, 581, 202, 289, 197, 307, 519, 593, 269, 182, 166, 326, 98, 450, 289, 244, 180, 500, 299, 254, 352, 567, 220, 394, 469, 326, 437, 20, 387, 384, 472, 525, 148, 162, 216, 383
	fruitY1 dw 32, 34, 190, 261, 358, 383, 48, 347, 313, 131, 156, 381, 115, 225, 306, 87, 26, 121, 236, 44, 21, 206, 294, 24, 301, 306, 312, 261, 202, 52, 33, 89, 86, 243, 30, 215, 109, 231, 280, 315, 128, 336, 35, 48, 250, 78, 355, 272, 77, 284, 305, 206, 115, 125, 102, 269, 230, 172, 50, 297, 26, 124, 150, 260, 352, 93, 296, 365, 353, 301, 244, 87, 20, 236, 181, 133, 334, 171, 107, 98, 232, 21, 46, 166, 92, 231, 313, 25, 335, 316, 135, 331, 306, 123, 148, 271, 215, 47, 217, 228
	fruitX2 dw 533, 542, 33, 300, 606, 400, 508, 29, 531, 509, 437, 558, 464, 487, 260, 37, 414, 252, 508, 71, 183, 511, 397, 498, 146, 239, 548, 150, 101, 223, 402, 595, 202, 471, 186, 427, 452, 519, 525, 514, 193, 506, 181, 20, 180, 53, 521, 296, 291, 283, 600, 479, 613, 412, 408, 575, 107, 101, 573, 265, 609, 487, 188, 113, 502, 531, 439, 121, 199, 364, 355, 616, 105, 196, 384, 90, 464, 336, 244, 407, 71, 437, 338, 96, 222, 353, 68, 550, 400, 614, 165, 300, 583, 188, 206, 191, 494, 612, 433, 497
	fruitY2 dw 208, 283, 254, 225, 84, 282, 151, 80, 92, 109, 128, 43, 81, 201, 180, 23, 273, 256, 397, 25, 151, 51, 101, 355, 73, 286, 56, 292, 30, 137, 334, 73, 194, 64, 294, 56, 90, 156, 220, 357, 26, 189, 148, 230, 337, 195, 186, 82, 226, 366, 245, 83, 57, 299, 180, 247, 231, 340, 248, 69, 297, 240, 334, 184, 243, 185, 389, 183, 323, 64, 182, 301, 54, 196, 303, 198, 336, 90, 91, 302, 340, 227, 321, 142, 349, 49, 274, 384, 127, 228, 368, 231, 213, 158, 152, 276, 199, 213, 30, 59

	val1 times maxFrutas dw 1
	val2 times maxFrutas dw 1


	estadoJogo db 3 ; 0 (live), 1 (game over), 2 (quit), 3(menu inicial)
	modoAtual db 0 

segment stack stack
	resb	512
stacktop: