global setClockINT
global unsetClockINT
global pauseClock
global enable
global setEasy
global setMid
global setHard
extern atualizaPos
extern printaTelaPause
extern apagaTelaPause


segment code
setClockINT:
    CLI									; Deshabilita INTerrupções por harDWare - pin INTR NÃO atende INTerrupções externas
    XOR 	AX, AX						; Limpa o registrador AX, é equivALente a fazer "MOV AX,0"
    MOV 	ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
    MOV     AX, [ES:INTr*4]				; Carrega em AX o vALor do IP do vector de INTerrupção 8
    MOV     [offset_dos], AX    		; Salva na variável offset_dos o vALor do IP do vector de INTerrupção 8
    MOV     AX, [ES:INTr*4+2]   		; Carrega em AX o vALor do CS do vector de INTerrupção 8
    MOV     [cs_dos], AX  				; Salva na variável cs_dos o vALor do CS do vector de INTerrupção 8   
    MOV     [ES:INTr*4+2], CS			; Atualiza o valor do CS do vector de INTerrupção 8 com o CS do programa atuAL
    MOV     WORD [ES:INTr*4],ClockINT	; Atualiza o valor do IP do vector de INTerrupção 8 com o offset "ClockINT" do programa atuAL
    STI									; Habilita INTerrupções por harDWare - pin INTR SIM atende INTerrupções externas
	ret

unsetClockINT:
        CLI									; Deshabilita Interrupções por harDWare - pin INTR NÃO atende Interrupções externas							
		XOR     AX, AX						; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"
		MOV     ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
		MOV     AX, [cs_dos]				; Carrega em AX o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos -> linha 16
		MOV     [ES:INTr*4+2], AX			; Atualiza o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos
		MOV     AX, [offset_dos]			; Carrega em AX o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos				
		MOV     [ES:INTr*4], AX 			; Atualiza o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos
        sti
        ret

ClockINT:									; Este segmento de código só será executado se um pulso de relojio está ativo, ou seja, se a INT 8h for acionada!
		PUSH	AX							; Salva contexto na pilha							
		PUSH	DS
		MOV     AX,data						; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data"
		MOV     DS,AX						; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!	
    
		mov AL, [tick]						; AL recebe o valor de tick da dificuldade atual do jogo, ou 0 caso o jogo esteja pausado
		cmp byte [enable], 0
		jne naoPausado
			mov AL, 0
		naoPausado:

		add		byte [tique], AL			; Soma AL à variável tique toda vez que entra na interrupção
		CMP		byte[tique], maxTick		; Compara variável com o número máximo de ticks
		JB		Fimrel						; Se for menor que o maxTick, continua
		MOV 	byte [tique], 0				; Se não, limpa variável tique e chama a função principal de movimentação das cobrinhas

       	CALL atualizaPos					
Fimrel:
		MOV		AL,eoi						; Carrega o AL com a byte de End of Interruption, -> 20h por default						
		OUT		20h,AL						; Livera o PIC que está na porta 20h
		POP		DS							; Reestablece os registradores salvos na pilha na linha 46
		POP		AX
		IRET								; Retorna da interrupção

pauseClock:
	push ax
	mov al, 1
	sub al, [enable]
	mov [enable], al		; enable = 1-enable

	cmp al, 0
	pop ax
	jne despausou				; se enable = 0, printa tela pause
		CALL printaTelaPause
		ret
	despausou:
	CALL apagaTelaPause		; caso contrario tira a tela pause
	ret

setEasy:								; as funções setEasy, setMid e setHard definem o número de ticks que são incrementados para regular a velocidade do jogo
	mov byte[tick], easyTick
	ret
setMid:
	mov byte[tick], midTick
	ret
setHard:
	mov byte[tick], hardTick			; quando maior a dificuldade, mais ticks são somados e mais rápido o jogo anda
	ret

segment data
		maxTick equ 48					; constantes de tick para as dificuldades do jogo (easyTick atualiza o jogo a cada 8 ticks, midTick a cada 6 e hardTick a cada 4)
		easyTick equ 6
		midTick equ 8
		hardTick equ 12

		tick db hardTick

		eoi     	EQU 20h					; Byte de final de interrupção PIC - resgistrador OCW2 do 8259A
		pictrl  	EQU 20h					; Porta do PIC do Clock -> tick de ~54.9 ms 
		INTr	   	EQU 08h					; Interrupção por hardware do tick
		enable 		db 	1
		offset_dos	DW	0					; Variável de 2 bytes para armacenar o IP da INT 8
		cs_dos		DW	0					; Variável de 2 bytes para armacenar o CS da INT 8
		tique		DB  0					; Variável de 2 bytes que é incrementada a cada tick do clock ~54.9 ms 