extern cursor
extern caracter
extern cor
extern branco_intenso
extern cyan
extern vermelho
extern magenta

extern amarelo
extern preto
extern cinza
extern vida1
extern vida2
extern modoAtual
global printaTelaPause
global apagaTelaPause
global printaTelaGameOver
global apagaTelaGameOver
global printaTelaQuit
global apagaTelaQuit
global printaTelaVida
global printaTelaInicial
global deletaTelaInicial

global atualizaTelaVida
segment code

;Funcão genérica que usa uma variável linha atual e uma coluna atual para posicionar o cursor
;Posteriormente usa uma variável cor e um texto, também salvos em variáveis para imprimir
;uma string na posição demarcada pelo cursor
printaString:
    PUSH BX
    PUSH DX
        
    MOV     BL, [corTexto]
    MOV		byte[cor],BL

    MOV     BX,0
    MOV     DH,[lineAtual]				;linha 0-29
    MOV     DL,[colAtual]				;coluna 0-79
    mov si, [mensagemAtual]
    printaCaracter:
        CALL	cursor
        MOV     AL,[si+BX]
        CMP     AL, '$'
        JNE naoAcabouString
            JMP fimPrintString
        naoAcabouString:
        CALL	caracter
        INC     BX					;proximo caracter
        INC		DL					;avanca a coluna
        
        jmp    printaCaracter
    
    fimPrintString:

    POP DX
    POP BX
    RET


;Imprime a mensagem de tela pausada, com o botão de pause
printaTelaPause:
    push ax
        mov     ax, branco_intenso
        mov     byte[corTexto], al

    mov     word[lineAtual], midLine
    mov     word[colAtual], midCol


    mov  ax, mensagemPause  
    mov  word [mensagemAtual], ax

    pop ax
    call printaString
    ret

;Apaga a mensagem de tela pausada
apagaTelaPause:
    push ax
        mov     ax, preto
        mov     byte[corTexto], al

    mov     word[lineAtual], midLine
    mov     word[colAtual], midCol


    mov  ax, mensagemPause  
    mov  word [mensagemAtual], ax

    pop ax
    call printaString
    ret

;Imprime a mensagem de Game Over, com confirmação de restart
printaTelaGameOver:
    push ax
        mov     ax, vermelho
        mov     byte[corTexto], al

    mov     word[lineAtual], topLine
    mov     word[colAtual], midCol


    mov  ax, mensagemGameOver  
    mov  word [mensagemAtual], ax

    pop ax
    call printaString
    ret

;Apaga a mensagem de Game Over
apagaTelaGameOver:
    push ax
        mov     ax, preto
        mov     byte[corTexto], al

    mov     word[lineAtual], topLine
    mov     word[colAtual], midCol


    mov  ax, mensagemGameOver  
    mov  word [mensagemAtual], ax

    pop ax
    call printaString
    ret

;Imprime a mensagem de sair do jogo, com confirmação
printaTelaQuit:
    push ax
        mov     ax, amarelo
        mov     byte[corTexto], al

    mov     word[lineAtual], topLine
    mov     word[colAtual], midCol


    mov  ax, mensagemQuit  
    mov  word [mensagemAtual], ax

    pop ax
    call printaString
    ret

;Apaga a mensagem de sair do jogo
apagaTelaQuit:
    push ax
        mov     ax, preto
        mov     byte[corTexto], al

    mov     word[lineAtual], topLine
    mov     word[colAtual], midCol


    mov  ax, mensagemQuit  
    mov  word [mensagemAtual], ax

    pop ax
    call printaString
    ret

;Imprime apenas os textos "Vida:" de cada cobrinha
printaTelaVida:
    push ax
    
    mov     ax, vermelho
    mov     byte[corTexto], al

    mov     word[lineAtual], midLine
    mov     word[colAtual], leftCol

    mov  ax, mensagemVida  
    mov  word [mensagemAtual], ax

    
    call printaString

    mov     ax, cyan
    mov     byte[corTexto], al

    mov     word[colAtual], rightCol

    pop ax
    call printaString

    ret

;Imprime a tela inicial, mudando a cor da opção selecionada
printaTelaInicial:
    push ax
    
    mov     ax, magenta                                 ;Topo: imprime mensagem de escolher dificuldade
    mov     byte[corTexto], al

    mov     word[lineAtual], midLine
    mov     word[colAtual], midCol

    mov  ax, mensagemInicial  
    mov  word [mensagemAtual], ax       
    
    call printaString

    cmp word[modoAtual], 0                              ;Imprime os modos fácil, médio e difícil.
    je magenta1                                         ;A cor é definida pela seleção do modo atual nas setas para indicar a escolha
    mov     ax, cinza
    jmp cinza1
    magenta1:
    mov     ax, magenta
    cinza1:

    mov     byte[corTexto], al

    mov     word[lineAtual], centralTopLine

    mov  ax, mensagemFacil  
    mov  word [mensagemAtual], ax

    call printaString

    cmp word[modoAtual], 1
    je magenta2
    mov     ax, cinza
    jmp cinza2
    magenta2:
    mov     ax, magenta
    cinza2:
    
    mov     byte[corTexto], al

    mov     word[lineAtual], centralMidLine

    mov  ax, mensagemMedio  
    mov  word [mensagemAtual], ax

    call printaString

    cmp word[modoAtual], 2
    je magenta3
    mov     ax, cinza
    jmp cinza3
    magenta3:
    mov     ax, magenta
    cinza3:
    
    mov     byte[corTexto], al

    mov     word[lineAtual], centralBottomLine

    mov  ax, mensagemDificil  
    mov  word [mensagemAtual], ax

    call printaString

    cmp word[modoAtual], 3                                      ;Também imprime a mensagem de sair, em vermelho, caso selecionada
    je vermelho1
    mov     ax, cinza
    jmp cinza4
    vermelho1:
    mov     ax, vermelho
    cinza4:
    
    mov     byte[corTexto], al

    mov     word[lineAtual], centralUnderBottomLine

    mov  ax, mensagemSair  
    mov  word [mensagemAtual], ax

    call printaString

    pop ax

    ret

;Apaga a tela inicial
deletaTelaInicial:
    push ax
    
    mov     ax, preto
    mov     byte[corTexto], al

    mov     word[lineAtual], midLine
    mov     word[colAtual], midCol

    mov  ax, mensagemInicial  
    mov  word [mensagemAtual], ax
    
    call printaString

    mov     word[lineAtual], centralTopLine

    mov  ax, mensagemFacil  
    mov  word [mensagemAtual], ax

    call printaString

    mov     word[lineAtual], centralMidLine

    mov  ax, mensagemMedio  
    mov  word [mensagemAtual], ax

    call printaString

    mov     word[lineAtual], centralBottomLine

    mov  ax, mensagemDificil  
    mov  word [mensagemAtual], ax

    call printaString

    mov     word[lineAtual], centralUnderBottomLine

    mov  ax, mensagemSair  
    mov  word [mensagemAtual], ax

    call printaString
    pop ax

    ret


;Imprime a vida correspondente de cada cobra do lado a mensagem "Vida:"
atualizaTelaVida:
    push ax
    push dx

    
    mov     ax, vermelho
    mov     byte[cor], al

    mov     word[lineAtual], midLine
    mov     word[colAtual], vida1Col

    MOV     DH,[lineAtual]				;linha 0-29
    MOV     DL,[colAtual]				;coluna 0-79

    call cursor
    mov ax, '0'
    add ax, [vida1]

    call caracter

    mov     ax, cyan
    mov     byte[cor], al

    mov     word[colAtual], vida2Col

    MOV     DH,[lineAtual]				;linha 0-29
    MOV     DL,[colAtual]				;coluna 0-79
    
    call cursor
    mov ax, '0'
    add ax, [vida2]

    call caracter
    pop dx
    pop ax

    ret

segment data
    ; LINHAS 26,27,28
    topLine equ 1
    midLine equ 2
    bottomLine equ 3

    leftCol equ 5
    vida1Col equ 12
    
    midCol equ 24

    centralTopLine equ 7
    centralMidLine equ 8
    centralBottomLine equ 9
    centralUnderBottomLine equ 10
    
    rightCol equ 69
    vida2Col equ 76

    corTexto db 3

    mensagemAtual dw 0
    lineAtual dw midLine
    colAtual dw midCol
    
    ; MENSAGEM TELA PAUSE -> "Jogo Pausado"
    mensagemPause       db 'Jogo Pausado (P para retornar)$'
    mensagemGameOver    db 'Game Over (Y/N para reiniciar)$'
    mensagemJogo        db '       Jogo da Cobrinha       $'
    mensagemVida        db 'Vida: $'
    mensagemQuit        db 'Quer mesmo sair jogador? (Y/N)$'
    mensagemInicial     db 'Selecione seu nivel de resenha$'
    mensagemFacil       db '            -Facil            $'
    mensagemMedio       db '            -Medio            $'
    mensagemDificil     db '           -Dificil           $'
    mensagemSair        db '             Sair             $'