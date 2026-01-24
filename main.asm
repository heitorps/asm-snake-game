extern setKeyINT
extern keyINT
extern unsetKeyINT
extern p_i
extern p_t
extern tecla
extern tecla_u
extern teclasc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
extern setClockINT
extern unsetClockINT
extern ClockINT
extern pauseClock
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
extern line
extern full_circle
extern plot_xy
extern modo_anterior
extern cor
extern vermelho
extern preto
extern cyan
extern amarelo
extern branco_intenso
extern preto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

global atualizaPos

segment code
..start:
;Inicializa registradores
    MOV		AX,data
    MOV 	DS,AX
    MOV 	AX,stack
    MOV 	SS,AX
    MOV 	SP,stacktop

   call setKeyINT

;Salvar modo corrente de video(vendo como está o modo de video da maquina)
    MOV  	AH,0Fh
    INT  	10h
    MOV  	[modo_anterior],AL   


;Configurar interrupção de teclado
;Configurar interrupção de clock
    ; CLI									; Deshabilita INTerrupções por harDWare - pin INTR NÃO atende INTerrupções externas
    ; XOR 	AX, AX						; Limpa o registrador AX, é equivALente a fazer "MOV AX,0"
    ; MOV 	ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
    ; MOV     AX, [ES:INTr*4]				; Carrega em AX o vALor do IP do vector de INTerrupção 8
    ; MOV     [offset_dos_clock], AX    		; Salva na variável offset_dos o vALor do IP do vector de INTerrupção 8
    ; MOV     AX, [ES:INTr*4+2]   		; Carrega em AX o vALor do CS do vector de INTerrupção 8
    ; MOV     [cs_dos_clock], AX  				; Salva na variável cs_dos o vALor do CS do vector de INTerrupção 8   
    ; MOV     [ES:INTr*4+2], CS			; Atualiza o valor do CS do vector de INTerrupção 8 com o CS do programa atuAL
    ; MOV     WORD [ES:INTr*4],ClockINT	; Atualiza o valor do IP do vector de INTerrupção 8 com o offset "ClockINT" do programa atuAL
    ; STI									; Habilita INTerrupções por harDWare - pin INTR SIM atende INTerrupções externas

	;Alterar modo de video para gráfico 640x480 16 cores
    MOV     	AL,12h
    MOV     	AH,0
    INT     	10h

	mov bx, branco_intenso
    MOV		byte[cor],bl	;antenas
	MOV		AX,0
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	MOV		AX,639
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	CALL	line
	
	MOV		byte[cor],bl	;antenas
	MOV		AX,0
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	MOV		AX,479
	PUSH	AX
	CALL	line


	MOV		byte[cor],bl	;antenas
	MOV		AX,639
	PUSH	AX
	MOV		AX,479
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	MOV		AX,479
	PUSH	AX
	CALL	line


	MOV		byte[cor],bl	;antenas
	MOV		AX,639
	PUSH	AX
	MOV		AX,479
	PUSH	AX
	MOV		AX,639
	PUSH	AX
	MOV		AX,0
	PUSH	AX
	CALL	line

	push cx
	push ax
	push si

	mov ax, vermelho
	mov byte[cor],al
	mov cx, [num_frutas]
	imprime_frutas1:
	
		mov si, cx
		shl si, 1
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
		mov ax, [fruitX2 + si]
		push ax
		mov ax, [fruitY2 + si]
		push ax
		mov		AX, 3
		PUSH 	AX
    	CALL	full_circle

		loop imprime_frutas2

	pop si
	pop ax
	pop cx

	call setClockINT
;Loop bizarramente infinito
direcao:

    MOV     AX,[p_i]
	CMP     AX,[p_t]
	JE      direcao
	INC     word[p_t]
	AND     word[p_t],7   ; TALVEZ REMOVER
	MOV     BX,[p_t]
	XOR     AX, AX
    MOV byte AL, [BX+tecla]
	MOV     [tecla_u],AL
	
	CMP AL,0x11
	JNE naoW
	JMP set_W
	naoW:

	CMP AL,0x1E
	JNE naoA
	JMP set_A
	naoA:
	
	CMP AL,0x1F
	JNE naoS
	JMP set_S
	naoS:
	
	CMP AL,0x20
	JNE naoD
	JMP set_D
	naoD:

	CMP AL,0x48
	JNE naoUP
	JMP set_arrowUP
	naoUP:

	CMP AL,0x4B
	JNE naoLEFT
	JMP set_arrowLEFT
	naoLEFT:

	CMP AL,0x50
	JNE naoDOWN
	JMP set_arrowDOWN
	naoDOWN:

	CMP AL,0x4D
	JNE naoRIGHT
	JMP set_arrowRIGHT
	naoRIGHT:

	CMP AL,0x19
	JNE naoPAUSE
		call pauseClock
	naoPAUSE:

	CMP AL,0x10
	JNE naoSAI
    JMP sai
	naoSAI:

	jmp direcao
;  ^ E0
;  | 48

; <--E0
;    4B

; | E0
; V 50

; --> E0
;     4D
; fim_direcao:
	; mov bx, vermelho
	; MOV		byte[cor],bl	;antenas
	; pull bx
	; mov al, x1

    ; MOV		AX,
    ; PUSH	AX
    ; MOV		AX,240
    ; PUSH	AX
    ; CALL	plot_xy
set_W:
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
	push ax
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
	CALL unsetKeyINT
	CALL unsetClockINT

    ; CLI									; Deshabilita Interrupções por harDWare - pin INTR NÃO atende Interrupções externas							
    ; XOR     AX, AX						; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"
    ; MOV     ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
    ; MOV     AX, [cs_dos_clock]				; Carrega em AX o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos -> linha 16
    ; MOV     [ES:INTr*4+2], AX			; Atualiza o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos
    ; MOV     AX, [offset_dos_clock]			; Carrega em AX o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos				
    ; MOV     [ES:INTr*4], AX 			; Atualiza o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos
	; ; INT     21h							; Chama Interrupção 21h para RETornar o controle ao sistema operacional -> sai de forma segura da execução do programa
	; sti

	mov ax, 0003h      ; AH=00h set video mode, AL=03h text 80x25
    int 10h            ; set video mode clears screen e volta pro texto
                       ; (BIOS INT 10h serviço 00h) [web:38][web:46]

    ; (opcional) garante página ativa 0
    mov ax, 0500h      ; AH=05h select active display page, AL=0
    int 10h

    mov ax, 4C00h
    int 21h

	; MOV    	AH,08h
	; INT     21h
    ; MOV AH,0 ; set video mode
    ; MOV AL,[modo_anterior] ; recupera o modo anterior
    ; INT 10h
    ; MOV AX,4Ch
    ; INT 21h

;	int xPlot, yPlot, step
;	meioQuadrado = step >> 1
;	for(int y = yPlot + meioQuadrado; y >= yPlot - meioQuadrado)
;
;
;
;
plot:
	PUSH AX
    MOV		AX,[xPlot]
    PUSH	AX
    MOV		AX,[yPlot]
    PUSH	AX
	mov		AX, step
	shr		AX, 1
	PUSH 	AX
    CALL	full_circle
	POP AX
	RET


; int x[max_size]
; int y[max_size]
; int size, dx, dy
; for i = size; i > 0; i--;
;   x[i] = x[i-1]
;   y[i] = y[i-1]
; 
; x[0], y[0] = soma o delta e atravessa a tela se precisar
; de x/y[0] ate x/y[size-1] pintar vermelho
; x/y[size] pintar preto
;
atualizaPos:
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	PUSH SI


	;cobra 1

	mov CX, [size1]
	cmp cx, 0
	je fim_atualizaVetor1

	atualizaVetor1:
		mov si, cx
		shl si, 1			; SI = CX * 2

		mov ax, [x1 + si - 2]	; x[i] = x[i-1]
		mov [x1 + si], ax

		mov ax, [y1 + si - 2]	; y[i] = y[i-1]
		mov [y1 + si], ax
	loop atualizaVetor1

	fim_atualizaVetor1:

	mov dx, step
	shr dx,1		;	DX = meio step (+1 pela beirada)
	inc dx

	mov ax, [x1]
		cmp word [dx1], 0
		je fimHorizontal1
	add ax, [dx1]
	
	
	cmp ax, dx					; borda esquerda: se x <= meio step, passa p/ 639 - meio step
	jg nBordaEsq1
		mov word ax, 639
		sub ax, dx
		jmp fimHorizontal1
	nBordaEsq1:

	mov bx, 639					; borda direita: se x >= 639 - meio step, passa p/ meio step
	sub bx, dx
	cmp ax, bx
	jl fimHorizontal1
		mov word ax, dx
	fimHorizontal1:	

	mov [x1], ax
	
	mov ax, [y1]
		cmp word [dy1], 0
		je fimVertical1
	add ax, [dy1]

	cmp ax, dx					; borda baixo: se y <= meio step, vira 479 - meio step
	jg nBordaBaixo1
		mov word ax, 479
		sub ax, dx
		jmp fimVertical1
	nBordaBaixo1:

	mov bx, 479					; borda cima: se y >= 479 - meio step, vira meio step
	sub bx, dx
	cmp ax,bx
	jl fimVertical1
		mov word ax, dx
	fimVertical1:

	mov [y1], ax



	;cobra 2
	mov CX, [size2]
	cmp cx, 0
	je fim_atualizaVetor2

	atualizaVetor2:
		mov si, cx
		shl si, 1			; SI = CX * 2

		mov ax, [x2 + si - 2]	; x[i] = x[i-1]
		mov [x2 + si], ax

		mov ax, [y2 + si - 2]	; y[i] = y[i-1]
		mov [y2 + si], ax
	loop atualizaVetor2

	fim_atualizaVetor2:

	mov ax, [x2]
		cmp word [dx2], 0
		je fimHorizontal2
	add ax, [dx2]

	cmp ax, dx					; borda esquerda: se x <= meio step, passa p/ 639 - meio step
	jg nBordaEsq2
		mov word ax, 639
		sub ax, dx
		jmp fimHorizontal2
	nBordaEsq2:

	mov bx, 639					; borda direita: se x >= 639 - meio step, passa p/ meio step
	sub bx, dx
	cmp ax, bx
	jl fimHorizontal2
		mov word ax, dx
	fimHorizontal2:	

	mov [x2], ax
	
	mov ax, [y2]
		cmp word [dy2], 0
		je fimVertical2
	add ax, [dy2]

	cmp ax, dx					; borda baixo: se y <= meio step, vira 479 - meio step
	jg nBordaBaixo2
		mov word ax, 479
		sub ax, dx
		jmp fimVertical2
	nBordaBaixo2:

	mov bx, 479					; borda cima: se y >= 479 - meio step, vira meio step
	sub bx, dx
	cmp ax,bx
	jl fimVertical2
		mov word ax, dx
	fimVertical2:

	mov [y2], ax


	; eh

	mov cx, [size1]
	dec cx
	loopColisaoCobra1:
		call colisao_cobra1
	loop loopColisaoCobra1

	mov cx, [num_frutas]
	loopColisaoFrutinhas1:
		call colisao_fruta1
	loop loopColisaoFrutinhas1

	mov cx, [num_frutas]
	loopColisaoFrutinhas2:
		call colisao_fruta2
	loop loopColisaoFrutinhas2
	
	call plotCobra1
	call plotCobra2

	POP SI
	POP AX
	POP BX
	POP CX
	POP DX
	RET
colisao_cobra1:
	mov si, cx
	shl si, 1

	mov ax, [x1 + si]						
	add ax, 5
	cmp [x1], ax
	jng missColisaoDireita1c1							
		jmp sem_colisao_cobra1
	missColisaoDireita1c1:

	sub ax, 5
	sub ax, 5
	cmp [x1], ax
	jnl missColisaoEsquerda1c1							; se x1 < hitbox esquerda, nao encostou
		jmp sem_colisao_cobra1
	missColisaoEsquerda1c1:

	mov ax, [y1 + si]						; -- -- -- y da fruta
	add ax, 5
	cmp [y1], ax
	jng missColisaoCima1c1							
		jmp sem_colisao_cobra1					; se y1 > hitbox cima, nao encostou
	missColisaoCima1c1:

	sub ax, 5								; se y1 < hitbox baixo, nao encostou
	sub ax, 5
	cmp [y1], ax
	jnl missColisaoBaixo1c1
		jmp sem_colisao_cobra1
	missColisaoBaixo1c1:

	call perdeVida1

	sem_colisao_cobra1:
	ret
colisao_fruta1:					
	;frutinha 1 cobra 1	
		mov si, cx
		shl si, 1

		cmp word[val1 + si], 0						; se fruta valida 1 = 0, termina verificacao
		jne fruta_existe1c1 	
			jmp fim_colisao_fruta1
		fruta_existe1c1:


		mov ax, [fruitX1 + si]						; ax recebe posicao x da fruta
		add ax, step
		cmp [x1], ax
		jng missDireita1c1							; se x1 > hitbox direita, nao encostou
			jmp frutinha1_cobra2
		missDireita1c1:

		sub ax, step
		sub ax, step
		cmp [x1], ax
		jnl missEsquerda1c1							; se x1 < hitbox esquerda, nao encostou
			jmp frutinha1_cobra2
		missEsquerda1c1:

		mov ax, [fruitY1 + si]						; -- -- -- y da fruta
		add ax, step
		cmp [y1], ax
		jng missCima1c1							
			jmp frutinha1_cobra2					; se y1 > hitbox cima, nao encostou
		missCima1c1:

		sub ax, step								; se y1 < hitbox baixo, nao encostou
		sub ax, step
		cmp [y1], ax
		jnl missBaixo1c1
			jmp frutinha1_cobra2
		missBaixo1c1:

		; cobrinha 1 pegou fruta 1
			mov word[val1 + si], 0						; desativa a frutinha
			
			
			mov ax, preto								; apaga a frutinha	
			MOV		byte[cor],al
			mov ax, [fruitX1 + si]
			push ax
			mov ax, [fruitY1 + si]
			push ax
			mov		AX, 3
			PUSH 	AX
			CALL	full_circle

			mov ax, [size1]								; aumenta a cobrinha 1
			inc ax
			mov [size1], ax

		jmp fim_colisao_fruta1						; se cobrinha 1 pegou, não precisa checar cobrinha 2
	; frutinha 1 cobra 2
	frutinha1_cobra2:

		mov ax, [fruitX1 + si]						; ax recebe posicao x da fruta
		add ax, step
		cmp [x2], ax
		jng missDireita1c2							; se x2 > hitbox direita, nao encostou
			jmp fim_colisao_fruta1
		missDireita1c2:

		sub ax, step
		sub ax, step
		cmp [x2], ax
		jnl missEsquerda1c2							; se x2 < hitbox esquerda, nao encostou
			jmp fim_colisao_fruta1
		missEsquerda1c2:

		mov ax, [fruitY1 + si]						; -- -- -- y da fruta
		add ax, step
		cmp [y2], ax
		jng missCima1c2							
			jmp fim_colisao_fruta1					; se y2 > hitbox cima, nao encostou
		missCima1c2:

		sub ax, step
		sub ax, step								; se y2 < hitbox baixo, nao encostou
		cmp [y2], ax
		jnl missBaixo1c2
			jmp fim_colisao_fruta1
		missBaixo1c2:

		; cobrinha 2 pegou fruta 1
		mov word[val1 + si], 0						; desativa a frutinha

		mov ax, preto								; apaga a frutinha	
		MOV		byte[cor],al
		mov ax, [fruitX1 + si]
		push ax
		mov ax, [fruitY1 + si]
		push ax
		mov		AX, 3
		PUSH 	AX
		CALL	full_circle

		mov ax, [size1]								; aumenta a cobrinha 1
		inc ax
		mov [size1], ax

		call diminuiCobra2							; diminui cobrinha 2

	fim_colisao_fruta1:
	ret

colisao_fruta2:					
	;frutinha 2 cobra 2	
		mov si, cx
		shl si, 1

		cmp word[val2 + si], 0						; se fruta valida 2 = 0, termina verificacao
		jne fruta_existe2c2 	
			jmp fim_colisao_fruta2
		fruta_existe2c2:


		mov ax, [fruitX2 + si]						; ax recebe posicao x da fruta
		add ax, step
		cmp [x2], ax
		jng missDireita2c2							; se x2 > hitbox direita, nao encostou
			jmp frutinha2_cobra1
		missDireita2c2:

		sub ax, step
		sub ax, step
		cmp [x2], ax
		jnl missEsquerda2c2							; se x2 < hitbox esquerda, nao encostou
			jmp frutinha2_cobra1
		missEsquerda2c2:

		mov ax, [fruitY2 + si]						; -- -- -- y da fruta
		add ax, step
		cmp [y2], ax
		jng missCima2c2							
			jmp frutinha2_cobra1					; se y1 > hitbox cima, nao encostou
		missCima2c2:

		sub ax, step								; se y1 < hitbox baixo, nao encostou
		sub ax, step
		cmp [y2], ax
		jnl missBaixo2c2
			jmp frutinha2_cobra1
		missBaixo2c2:

		; cobrinha 2 pegou fruta 2
			mov word[val2 + si], 0						; desativa a frutinha
			
			
			mov ax, preto								; apaga a frutinha	
			MOV		byte[cor],al
			mov ax, [fruitX2 + si]
			push ax
			mov ax, [fruitY2 + si]
			push ax
			mov		AX, 3
			PUSH 	AX
			CALL	full_circle

			mov ax, [size2]								; aumenta a cobrinha 2
			inc ax
			mov [size2], ax

		jmp fim_colisao_fruta2						; se cobrinha 2 pegou, não precisa checar cobrinha 1
	; frutinha 2 cobra 1
	frutinha2_cobra1:

		mov ax, [fruitX2 + si]						; ax recebe posicao x da fruta 2
		add ax, step
		cmp [x1], ax
		jng missDireita2c1							; se x1 > hitbox direita, nao encostou
			jmp fim_colisao_fruta2
		missDireita2c1:

		sub ax, step
		sub ax, step
		cmp [x1], ax
		jnl missEsquerda2c1							; se x1 < hitbox esquerda, nao encostou
			jmp fim_colisao_fruta2
		missEsquerda2c1:

		mov ax, [fruitY2 + si]						; -- -- -- y da fruta 2
		add ax, step
		cmp [y1], ax
		jng missCima2c1							
			jmp fim_colisao_fruta2					; se y1 > hitbox cima, nao encostou
		missCima2c1:

		sub ax, step
		sub ax, step								; se y1 < hitbox baixo, nao encostou
		cmp [y1], ax
		jnl missBaixo2c1
			jmp fim_colisao_fruta2
		missBaixo2c1:

		; cobrinha 1 pegou fruta 2
		mov word[val2 + si], 0						; desativa a frutinha

		mov ax, preto								; apaga a frutinha	
		MOV		byte[cor],al
		mov ax, [fruitX2 + si]
		push ax
		mov ax, [fruitY2 + si]
		push ax
		mov		AX, 3
		PUSH 	AX
		CALL	full_circle

		mov ax, [size2]								; aumenta a cobrinha 2
		inc ax
		mov [size2], ax

		call diminuiCobra1							; diminui cobrinha 1

	fim_colisao_fruta2:
	ret


diminuiCobra1:
	PUSH AX				; pinta a cauda a ser removida de preto
	PUSH SI
	
	mov ax, [size1]		; se tamanho da cobra for = 2, perde vida ao invés de perder tamanho
	cmp ax, 2
	jne naoPerdeVida1
		call perdeVida1
		jmp naoPerdeTamanho1
	naoPerdeVida1:
		mov ax, preto
		mov byte[cor], al
		mov si, [size1]
		shl si, 1
		mov ax, [x1 + si]
		mov [xPlot], ax
		mov ax, [y1 + si]
		mov [yPlot], ax
		call plot

		mov ax, [size1]
		dec ax
		mov [size1], ax
	naoPerdeTamanho1:

	POP SI
	POP AX
	RET

perdeVida1:
	push ax
	mov ax, [vida1]
	dec ax
	mov [vida1], ax
	cmp ax, 0
	jne naoExterminio1
		mov word[size1], 30			; aqui vai chamar game over
	naoExterminio1:
	pop ax
	ret
diminuiCobra2:
	PUSH AX				; pinta a cauda a ser removida de preto
	PUSH SI
	
	mov ax, [size2]		; se tamanho da cobra for = 2, perde vida ao invés de perder tamanho
	cmp ax, 2
	jne naoPerdeVida2
		call perdeVida2
		jmp naoPerdeTamanho2
	naoPerdeVida2:
		mov ax, preto
		mov byte[cor], al
		mov si, [size2]
		shl si, 1
		mov ax, [x2 + si]
		mov [xPlot], ax
		mov ax, [y2 + si]
		mov [yPlot], ax
		call plot

		mov ax, [size2]
		dec ax
		mov [size2], ax
	naoPerdeTamanho2:

	POP SI
	POP AX
	RET

perdeVida2:
	push ax
	mov ax, [vida2]
	dec ax
	mov [vida2], ax
	cmp ax, 0
	jne naoExterminio2
		mov word[size2], 10			; aqui vai chamar game over
	naoExterminio2:
	pop ax
	ret

plotCobra1:
	mov ax, preto
	mov byte[cor], al
	mov si, [size1]
	shl si, 1
	mov ax, [x1 + si]
	mov [xPlot], ax
	mov ax, [y1 + si]
	mov [yPlot], ax
	call plot
	
	mov cx, [size1]
	dec cx
	
	mov ax, vermelho
	mov byte[cor], al
	pinta_vermelho1:
		mov si, cx
		shl si, 1
		mov ax, [x1 + si]
		mov [xPlot], ax
		mov ax, [y1 + si]
		mov [yPlot], ax
		call plot
	loop pinta_vermelho1
	RET

plotCobra2:
	mov ax, preto
	mov byte[cor], al
	mov si, [size2]
	shl si, 1
	mov ax, [x2 + si]
	mov [xPlot], ax
	mov ax, [y2 + si]
	mov [yPlot], ax
	call plot
	
	mov cx, [size2]
	dec cx
	
	mov ax, cyan
	mov byte[cor], al
	pinta_azul2:
		mov si, cx
		shl si, 1
		mov ax, [x2 + si]
		mov [xPlot], ax
		mov ax, [y2 + si]
		mov [yPlot], ax
		call plot
	loop pinta_azul2
	RET

	; mov AX, preto
	; MOV	byte[cor],al
	
	; MOV AX, [x1]
	; MOV [xPlot], AX

	; MOV DX, [y1]
	; MOV [yPlot], DX

	; CALL plot

	; ADD AX, [dx1]
	; ADD DX, [dy1]

	; MOV [xPlot], AX
	; MOV [yPlot], DX
	; MOV [x1], AX
	; MOV [y1], DX

	; mov AX, vermelho
	; MOV	byte[cor],al

	; CALL plot
;FUNCOES GRAFICAS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;função plot_xy
; Parametros:
;	PUSH x; PUSH y; CALL plot_xy;  (x<639, y<479)
; 	cor definida na variavel cor
;-----------------------------------------------------------------------------
;função cursor
; Parametros:
; 	DH = linha (0-29) e  DL = coluna  (0-79)

;*******************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;TECBUF



; ClockINT:									; Este segmento de código só será executado se um pulso de relojio está ativo, ou seja, se a INT 8h for acionada!
; 		PUSH	AX							; Salva contexto na pilha							
; 		PUSH	DS
; 		MOV     AX,data						; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data"
; 		MOV     DS,AX						; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!	
    
; 		INC		byte [tique]				; Incremente variável tique toda vez que entra na interrupção
; 		CMP		byte[tique], 5				; Compara variável "teique" com 18, isso para alterar os valores do relogio a cada segundo -> 18/18.2 ~1 segundo!
; 		JB		Fimrel						; Se for menor que 18 pula para Fimrel
; 		MOV 	byte [tique], 0				; Se não, limpa variável tique e  

;        ;CALL clock_jogo 
;     	dec cx
; Fimrel:
; 		MOV		AL,eoiC						; Carrega o AL com a byte de End of Interruption, -> 20h por default						
; 		OUT		20h,AL						; Livera o PIC que está na porta 20h
; 		POP		DS							; Reestablece os registradores salvos na pilha na linha 46
; 		POP		AX
; 		IRET								; Retorna da interrupção
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


segment data
	step equ 10
	maxSize equ 100
    ; eoiC     EQU 20h					; Byte de final de interrupção PIC - resgistrador

    ; offset_dos_clock  DW 1				; Variável de 2 bytes para armacenar o IP da INT 9
    ; cs_dos_clock  DW  1					; Variável de 2 bytes para armacenar o CS da INT 9

	; INTr	   	EQU 08h					; Interrupção por hardware do tick
    ; tique		DB  0					; Variável de 2 bytes que é incrementada a cada tick do clock ~54.9 ms 
    xPlot dw 0
	yPlot dw 0
	
	x1 times maxSize dw step
	y1 times maxSize dw step
	size1 dw 4
	dx1 dw step
	dy1 dw 0
	
	x2 times maxSize dw 479-step
	y2 times maxSize dw step
	
	size2 dw 4
	dx2 dw step
	dy2 dw 0

	maxFrutas equ 100
	fruitX1 dw 347, 499, 298, 356, 173, 453, 617, 168, 221, 134, 545, 252, 377, 454, 602, 322, 462, 356, 170, 223, 326, 561, 489, 321, 170, 224, 27, 619, 462, 88, 199, 532, 215, 156, 502, 561, 61, 147, 230, 222, 104, 234, 427, 174, 353, 95, 384, 153, 374, 272, 450, 270, 442, 347, 211, 363, 125, 189, 64, 78, 391, 370, 514, 521, 82, 581, 202, 289, 197, 307, 519, 593, 269, 182, 166, 326, 98, 450, 289, 244, 180, 500, 299, 254, 352, 567, 220, 394, 469, 326, 437, 20, 387, 384, 472, 525, 148, 162, 216, 383
	fruitY1 dw 382, 161, 25, 46, 340, 60, 443, 239, 215, 107, 293, 219, 111, 398, 85, 321, 24, 94, 243, 227, 236, 77, 259, 392, 61, 68, 226, 320, 194, 279, 343, 275, 412, 343, 84, 316, 451, 351, 56, 143, 172, 219, 207, 24, 157, 208, 312, 234, 221, 125, 84, 187, 402, 421, 226, 180, 20, 432, 365, 324, 154, 148, 312, 24, 345, 99, 391, 125, 301, 372, 153, 384, 259, 247, 308, 274, 427, 151, 261, 52, 23, 47, 440, 240, 286, 372, 424, 111, 257, 440, 323, 314, 202, 134, 210, 369, 207, 159, 274, 252
	fruitX2 dw 533, 542, 33, 300, 606, 400, 508, 29, 531, 509, 437, 558, 464, 487, 260, 37, 414, 252, 508, 71, 183, 511, 397, 498, 146, 239, 548, 150, 101, 223, 402, 595, 202, 471, 186, 427, 452, 519, 525, 514, 193, 506, 181, 20, 180, 53, 521, 296, 291, 283, 600, 479, 613, 412, 408, 575, 107, 101, 573, 265, 609, 487, 188, 113, 502, 531, 439, 121, 199, 364, 355, 616, 105, 196, 384, 90, 464, 336, 244, 407, 71, 437, 338, 96, 222, 353, 68, 550, 400, 614, 165, 300, 583, 188, 206, 191, 494, 612, 433, 497
	fruitY2 dw 352, 35, 227, 25, 84, 165, 142, 338, 277, 117, 144, 414, 133, 381, 171, 207, 292, 53, 457, 239, 455, 281, 430, 234, 268, 304, 457, 339, 25, 70, 354, 279, 448, 277, 336, 177, 258, 387, 271, 412, 83, 339, 425, 182, 134, 217, 207, 110, 70, 159, 453, 302, 191, 274, 288, 345, 216, 242, 294, 174, 80, 220, 90, 38, 252, 348, 177, 317, 382, 290, 344, 353, 368, 93, 314, 282, 129, 231, 148, 185, 246, 316, 365, 361, 254, 211, 248, 416, 76, 289, 225, 118, 144, 20, 458, 154, 240, 31, 281, 61
	;fruitX1 dw 264, 563, 574, 397, 305, 165, 404, 532, 146, 125, 366, 42, 585, 574, 315, 481, 228, 464, 176, 434, 337, 374, 347, 279, 347, 466, 78, 6, 212, 390, 339, 491, 541, 476, 29, 289, 166, 316, 285, 214, 63, 27, 194, 403, 384, 283, 353, 177, 464, 569, 379, 36, 167, 303, 502, 389, 225, 495, 128, 519, 588, 98, 278, 358, 225, 590, 143, 525, 443, 145, 398, 253, 539, 498, 181, 550, 73, 478, 383, 605, 355, 610, 164, 349, 271, 480, 164, 131, 543, 64, 260, 264, 142, 11, 156, 239, 27, 229, 623, 579
	;fruitY1 dw 23, 49, 250, 49, 345, 248, 99, 237, 464, 262, 417, 364, 91, 272, 378, 345, 326, 269, 16, 456, 295, 99, 120, 251, 57, 27, 110, 454, 386, 139, 47, 54, 418, 319, 345, 182, 311, 174, 164, 104, 333, 202, 426, 7, 160, 461, 280, 132, 18, 408, 402, 84, 280, 282, 251, 322, 297, 455, 331, 88, 367, 189, 218, 281, 331, 52, 369, 84, 180, 13, 276, 264, 127, 343, 449, 300, 167, 454, 173, 255, 117, 178, 230, 473, 414, 437, 25, 268, 302, 208, 194, 244, 13, 148, 367, 213, 191, 316, 176, 111
	;fruitX2 dw 271, 367, 444, 89, 334, 307, 335, 84, 244, 129, 439, 599, 334, 170, 260, 130, 365, 635, 394, 384, 287, 35, 154, 59, 597, 148, 573, 632, 36, 50, 376, 13, 253, 162, 394, 114, 296, 100, 354, 203, 430, 306, 560, 427, 287, 461, 223, 299, 499, 551, 289, 190, 100, 368, 619, 573, 255, 186, 568, 277, 189, 185, 572, 134, 191, 484, 222, 634, 510, 350, 594, 96, 401, 372, 257, 345, 619, 38, 432, 308, 7, 453, 180, 406, 26, 220, 565, 605, 528, 534, 576, 111, 534, 312, 208, 108, 350, 485, 122, 272
	;fruitY2 dw 392, 148, 249, 205, 34, 324, 74, 50, 192, 319, 190, 30, 54, 182, 27, 96, 354, 139, 220, 305, 461, 6, 401, 357, 405, 245, 241, 458, 104, 403, 412, 221, 446, 460, 133, 103, 378, 171, 229, 130, 144, 67, 388, 342, 18, 162, 180, 437, 188, 170, 262, 466, 49, 112, 148, 458, 286, 174, 459, 243, 429, 117, 180, 417, 119, 110, 230, 355, 356, 271, 151, 387, 44, 44, 362, 234, 418, 346, 464, 148, 59, 192, 107, 396, 73, 404, 206, 202, 60, 141, 11, 249, 170, 163, 98, 356, 302, 392, 297, 109
	vida1 dw 3
	vida2 dw 3
	
	val1 times maxFrutas dw 1
	val2 times maxFrutas dw 1
	num_frutas dw 40

segment stack stack
	resb	512
stacktop: