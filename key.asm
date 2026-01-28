global setKeyINT
global unsetKeyINT

global p_i
global p_t
global tecla
global tecla_u

segment code
setKeyINT:
        CLI						; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas	
        XOR     AX, AX					; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"
        MOV     ES, AX					; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
        MOV     AX, [ES:INT9*4]			        ; Carrega em AX o valor do IP do vector de INTerrupção 9 
        MOV     [offset_dos], AX    	                ; Salva na variável offset_dos o valor do IP do vector de INTerrupção 9
        MOV     AX, [ES:INT9*4+2]   	                ; Carrega em AX o valor do CS do vector de INTerrupção 9
        MOV     [cs_dos], AX			        ; Salva na variável cs_dos o valor do CS do vector de INTerrupção 9     
        MOV     [ES:INT9*4+2], CS		        ; Atualiza o valor do CS do vector de INTerrupção 9 com o CS do programa atual 
        MOV     WORD [ES:INT9*4],keyINT	                ; Atualiza o valor do IP do vector de INTerrupção 9 com o offset "keyINT" do programa atual
        STI						; Habilita INTerrupções por hardware - pin INTR SIM atende INTerrupções externas
        RET

unsetKeyINT:
        CLI						; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas
        XOR     AX, AX					; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"				
        MOV     ES, AX					; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
        MOV     AX, [cs_dos]			        ; Carrega em AX o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos -> linha 25
        MOV     [ES:INT9*4+2], AX		        ; Atualiza o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos
        MOV     AX, [offset_dos]		        ; Carrega em AX o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos -> linha 23
        MOV     [ES:INT9*4], AX 		        ; Atualiza o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos
        sti
        RET
keyINT:							; Este segmento de código só será executado se uma tecla for presionada, ou seja, se a INT 9h for acionada!
        PUSH    AX					; Salva contexto na pilha
        PUSH    BX
        PUSH    DS
        MOV     AX,data				        ; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data" 			
        MOV     DS,AX					; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!
        IN      AL, kb_data				; Le a porta 60h, que é onde está o byte do Make/Break da tecla. Esse valor é fornecido pelo chip "8255 PPI"
        INC     WORD [p_i]				; Incrementa p_i para indicar no loop principal que uma tecla foi acionada!
        AND     WORD [p_i],7			
        MOV     BX,[p_i]				; Carrega p_i em BX
        MOV     [BX+tecla],al			        ; Transfere o valor Make/Break da tecla armacenado em AL "linha 84" para o segmento de dados com offset DX, na variável "tecla"
        IN      AL, kb_ctl				; Le porta 61h, pois o bit mais significativo "bit 7" 
        OR      AL, 80h					; Faz operação lógica OR com o bit mais significativo do registrador AL (1XXXXXXX) -> Valor lido da porta 61h 
        OUT     kb_ctl, AL				; Seta o bit mais significativo da porta 61h
        AND     AL, 7Fh					; Restablece o valor do bit mais significativo do registrador AL (0XXXXXXX), alterado na linha 90 	
        OUT     kb_ctl, AL				; Reinicia o registrador de dislocamento 74LS322 e Livera a interrupção "CLR do flip-flop 7474". O 8255 - Programmable Peripheral Interface (PPI) fica pronto para recever um outro código da tecla https://es.wikipedia.org/wiki/INTel_8255
        MOV     AL, eoi					; Carrega o AL com a byte de End of Interruption, -> 20h por default
        OUT     pictrl, AL				; Livera o PIC
        
        POP     DS					; Reestablece os registradores salvos na linha 79 
        POP     BX
        POP     AX
        IRET						; Retorna da interrupção

segment data
    kb_data EQU 60h  				; PORTA DE LEITURA DE TECLADO
    kb_ctl  EQU 61h  				; PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
    pictrl  EQU 20h                             ; PORTA DO PIC DE TECLADO
    eoi     EQU 20h				; Byte de final de interrupção PIC - resgistrador
    INT9    EQU 9h				; Interrupção por hardware do teclado
    cs_dos  DW  1				; Variável de 2 bytes para armacenar o CS da INT 9
    offset_dos  DW 1			        ; Variável de 2 bytes para armacenar o IP da INT 9
    tecla_u db 0
    tecla   resb  8				; Variável de 8 bytes para armacenar a tecla presionada. Só precisa de 2 bytes!	 
    p_i     dw  0   			        ; Indice p/ Interrupcao (Incrementa na ISR quando pressiona/solta qualquer tecla)  
    p_t     dw  0   			        ; Indice p/ Interrupcao (Incrementa após retornar da ISR quando pressiona/solta qualquer tecla)    
