global startSize
global size1
global startX1
global x1
global dx1
global y1
global dy1
global size2
global startX2
global x2
global dx2
global y2
global dy2
global startY
global step
global topBorder
extern cor
extern vermelho
extern preto
extern cyan
extern xPlot
extern yPlot
global vida1
global vida2
extern fruitX1
extern fruitY1
extern fruitX2
extern fruitY2
extern val1
extern val2
extern estadoJogo
extern enable
extern num_frutas
;------------------------

extern plot
extern atualizaTelaVida
extern full_circle
extern printaTelaGameOver
global atualizaPos
global apagaCobra1
global apagaCobra2
global restartCobrinhas
segment code
;Atualiza a posição das duas cobras

restartCobrinhas:
    mov word[size1], startSize	
	mov word[size2], startSize
	mov cx, startSize					; move todas as partes das cobrinhas para as posições iniciais
	loopRestartCobrinhas:
		mov si, cx
		shl si, 1
		mov word [x1 + si], startX1
		mov word [x2 + si], startX2
		mov word [y1 + si], startY	
		mov word [y2 + si], startY
		loop loopRestartCobrinhas

	mov word[x1], startX1	
	mov word[x2], startX2
	mov word[y1], startY	
	mov word[y2], startY

	mov word[vida1], 3					;reinicia as vidas e atualiza a tela de vida
	mov word[vida2], 3

	mov word[dx1], step					; reinicia a direção das cobrinhas, ativa o clock pausado pelo game over e coloca o jogo em estado vivo
	mov word[dy1], 0
	mov word[dx2], step
	mov word[dy2], 0
    ret

atualizaPos:
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	PUSH SI

	call atualizaCobra1

	call atualizaCobra2	


	;Trata colisões da cobra com o próprio corpo, captura de frutas e plotagem das cobras
	mov cx, [size1]
	dec cx

	cmp cx, 0
	je fim_loopColisaoCobra1
	
	;trata colisão da cabeça com um pedaço do corpo
	loopColisaoCobra1:
		call colisao_cobra1
	loop loopColisaoCobra1

	fim_loopColisaoCobra1:

	mov cx, [size2]
	dec cx

	cmp cx, 0 
	je fim_loopColisaoCobra2

	loopColisaoCobra2:
		call colisao_cobra2
	loop loopColisaoCobra2

	fim_loopColisaoCobra2:

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

;Trata colisão da cobra 1, da cabeça dela com uma parte específica do corpo
;se ocorreu colisão chama a função de decrementar vida

atualizaCobra1:
;cobra 1

	mov CX, [size1] 
	cmp cx, 0 ;pula se o tamanho ja zerou
	je fim_atualizaVetor1

	;Muda as posições da cobra 1 enquanto vetor, sem correspondência visual
	atualizaVetor1:
		mov si, cx
		shl si, 1			; SI = CX * 2

		mov ax, [x1 + si - 2]	; x[i] = x[i-1]
		mov [x1 + si], ax

		mov ax, [y1 + si - 2]	; y[i] = y[i-1]
		mov [y1 + si], ax
	loop atualizaVetor1

	fim_atualizaVetor1:

	;tratamento das colisões com as paredes
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

	cmp ax, dx					; borda baixo: se y <= meio step, vira topBorder - meio step
	jg nBordaBaixo1
		mov word ax, topBorder
		sub ax, dx
		jmp fimVertical1
	nBordaBaixo1:

	mov bx, topBorder					; borda cima: se y >= topBorder - meio step, vira meio step
	sub bx, dx
	cmp ax,bx
	jl fimVertical1
		mov word ax, dx
	fimVertical1:

	mov [y1], ax
	ret

atualizaCobra2:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cobra 2
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

	cmp ax, dx					; borda baixo: se y <= meio step, vira topBorder - meio step
	jg nBordaBaixo2
		mov word ax, topBorder
		sub ax, dx
		jmp fimVertical2
	nBordaBaixo2:

	mov bx, topBorder					; borda cima: se y >= topBorder - meio step, vira meio step
	sub bx, dx
	cmp ax,bx
	jl fimVertical2
		mov word ax, dx
	fimVertical2:

	mov [y2], ax
	ret
colisao_cobra1:
	mov si, cx
	shl si, 1

	;verifica se a cabeça da cobra está dentro do centro de uma parte do seu corpo, 
	;com mais uma margem de erro (5 nesse caso)
	mov ax, [x1 + si]						
	add ax, 5
	
	cmp [x1], ax
	jng missColisaoDireitaC1					
		jmp sem_colisao_cobra1
	missColisaoDireitaC1:

	sub ax, 5
	sub ax, 5
	cmp [x1], ax
	jnl missColisaoEsquerdaC1							; se x1 < hitbox esquerda, nao encostou
		jmp sem_colisao_cobra1
	missColisaoEsquerdaC1:

	mov ax, [y1 + si]						; -- -- -- y da fruta
	add ax, 5
	cmp [y1], ax
	jng missColisaoCimaC1							
		jmp sem_colisao_cobra1					; se y1 > hitbox cima, nao encostou
	missColisaoCimaC1:

	sub ax, 5								; se y1 < hitbox baixo, nao encostou
	sub ax, 5
	cmp [y1], ax
	jnl missColisaoBaixoC1
		jmp sem_colisao_cobra1
	missColisaoBaixoC1:

	call perdeVida1
	call atualizaTelaVida

	sem_colisao_cobra1:
	ret
	
colisao_cobra2:
	mov si, cx
	shl si, 1

	mov ax, [x2 + si]						
	add ax, 5
	cmp [x2], ax
	jng missColisaoDireitaC2							
		jmp sem_colisao_cobra2
	missColisaoDireitaC2:

	sub ax, 5
	sub ax, 5
	cmp [x2], ax
	jnl missColisaoEsquerdaC2							; se x2 < hitbox esquerda, nao encostou
		jmp sem_colisao_cobra2
	missColisaoEsquerdaC2:

	mov ax, [y2 + si]						; -- -- -- y da fruta
	add ax, 5
	cmp [y2], ax
	jng missColisaoCimaC2							
		jmp sem_colisao_cobra2					; se y2 > hitbox cima, nao encostou
	missColisaoCimaC2:

	sub ax, 5								; se y2 < hitbox baixo, nao encostou
	sub ax, 5
	cmp [y2], ax
	jnl missColisaoBaixoC2
		jmp sem_colisao_cobra2
	missColisaoBaixoC2:

	call perdeVida2
	call atualizaTelaVida

	sem_colisao_cobra2:
	ret

;Trata colisão da cobra 1, da cabeça dela com uma fruta
;se ocorreu colisão com uma fruta de sua cor: chama a função aumentar tamanho
;se ocorreu colisão com uma fruta de outra cor: chama a função diminuir tamanho para si e aumenta  outra
colisao_fruta1:					
	;verifica se a cabeça da cobra está dentro do centro de uma fruta, 
	;com mais uma margem de erro (o step nesse caso)
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


;Diminui o size da cobra 1, retirando vida se necessário
diminuiCobra1:
	PUSH AX				; pinta a cauda a ser removida de preto
	PUSH SI
	
	mov ax, [size1]		; se tamanho da cobra for = 1, perde vida ao invés de perder tamanho
	cmp ax, 1
	jne naoPerdeVida1
		call perdeVida1
		call atualizaTelaVida
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

;Diminui uma vida da cobra
perdeVida1:
	push ax
	mov ax, [vida1]
	dec ax
	mov [vida1], ax
	cmp ax, 0
	jne naoExterminio1
		mov byte [estadoJogo], 1
	    mov byte [enable], 0
		call printaTelaGameOver
	naoExterminio1:
	pop ax
	ret
diminuiCobra2:
	PUSH AX				; pinta a cauda a ser removida de preto
	PUSH SI
	
	mov ax, [size2]		; se tamanho da cobra for = 2, perde vida ao invés de perder tamanho
	cmp ax, 1
	jne naoPerdeVida2
		call perdeVida2
		call atualizaTelaVida
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
		mov byte [estadoJogo], 1
	    mov byte [enable], 0
		call printaTelaGameOver				; aqui vai chamar game over
	naoExterminio2:
	pop ax
	ret

;Efetivamente plota na tela o correspondente visual do vetor de posições da cobra 1
plotCobra1:
	mov ax, preto				; pinta a cauda de preto
	mov byte[cor], al
	mov si, [size1]
	shl si, 1
	mov ax, [x1 + si]
	mov [xPlot], ax
	mov ax, [y1 + si]
	mov [yPlot], ax
	call plot
	
	mov cx, [size1]				; pega o tamanho
	dec cx
	
	mov ax, vermelho
	mov byte[cor], al

	cmp cx, 0
	je fim_loopPlotCobra1
	
	loopPlotCobra1:			
		mov si, cx
		shl si, 1
		mov ax, [x1 + si]
		mov [xPlot], ax
		mov ax, [y1 + si]
		mov [yPlot], ax
		call plot
	loop loopPlotCobra1

	fim_loopPlotCobra1:

	mov ax, [x1]
	mov [xPlot], ax
	mov ax, [y1]
	mov [yPlot], ax
	call plot
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
	
	cmp cx, 0
	je fim_loopPlotCobra2

	loopPlotCobra2:
		mov si, cx
		shl si, 1
		mov ax, [x2 + si]
		mov [xPlot], ax
		mov ax, [y2 + si]
		mov [yPlot], ax
		call plot
	loop loopPlotCobra2

	fim_loopPlotCobra2:

	mov ax, [x2]
	mov [xPlot], ax
	mov ax, [y2]
	mov [yPlot], ax
	call plot
	RET

;Remove completamente a cobra 1 da tela, cobrindo a inteiramente de preto
;Utilizado para dar restart no jogo
apagaCobra1:
	mov ax, preto				; pinta a cauda de preto
	mov byte[cor], al
	mov si, [size1]
	shl si, 1
	mov ax, [x1 + si]
	mov [xPlot], ax
	mov ax, [y1 + si]
	mov [yPlot], ax
	call plot
	
	mov cx, [size1]				; pega o tamanho
	dec cx
	
	mov ax, preto
	mov byte[cor], al

	cmp cx, 0
	je fim_loopDeletaCobra1
	loopDeletaCobra1:			
		mov si, cx
		shl si, 1
		mov ax, [x1 + si]
		mov [xPlot], ax
		mov ax, [y1 + si]
		mov [yPlot], ax
		call plot
	loop loopDeletaCobra1

	fim_loopDeletaCobra1:


	mov ax, [x1]
	mov [xPlot], ax
	mov ax, [y1]
	mov [yPlot], ax
	call plot
	RET

apagaCobra2:
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
	
	cmp cx, 0
	mov ax, preto
	mov byte[cor], al
	
	je fim_loopDeletaCobra2

	loopDeletaCobra2:
		mov si, cx
		shl si, 1
		mov ax, [x2 + si]
		mov [xPlot], ax
		mov ax, [y2 + si]
		mov [yPlot], ax
		call plot
	loop loopDeletaCobra2

	fim_loopDeletaCobra2:

	mov ax, [x2]
	mov [xPlot], ax
	mov ax, [y2]
	
	mov [yPlot], ax
	call plot
	RET


segment data
	topBorder equ 419
	maxSize equ 100
    step equ 10
	startSize equ 4
    startX1 equ step
	startX2 equ topBorder-step
	startY equ step
	
	x1 times maxSize dw startX1
	y1 times maxSize dw startY
	size1 dw startSize
	dx1 dw step
	dy1 dw 0
	
	x2 times maxSize dw startX2
	y2 times maxSize dw startY
	
	size2 dw startSize
	dx2 dw step
	dy2 dw 0

    vida1 dw 3
	vida2 dw 3