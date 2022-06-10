; *********************************************************************************
; * IST-UL
; * Cadeira:   IAC
; * Descrição: WIP - Jogo que copia o Space Invaders
;
; * Trabalho realizado por:
;
; * - Afonso Resendes ist1103972
; * - Lourenço Calhau ist1103396
; * - Pedro Gomes ist1103468
;
; *********************************************************************************
; * Constantes
; *********************************************************************************

; ----------- * Endereços * -----------

DISPLAYS			EQU 	0A000H		; endereço do display que mostra os outputs do telcado
TEC_LIN				EQU 	0C000H		; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 	0E000H		; endereço das colunas do teclado (periférico PIN)

; ----------- * Constantes * -----------

LINHA_INICIAL       		EQU  	28        	; linha incial da nave (fim do ecrã)
COLUNA_INICIAL			EQU  	30        	; coluna inicial da nave (meio do ecrã)
LINHA_MET			EQU  	-1		; linha inicial do meteoro (topo do ecrã)
COLUNA_MET			EQU  	30		; coluna iniucial do meteoro (a meio do ecrã)
MIN_COLUNA			EQU  	0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA			EQU 	62        	; número da coluna mais à direita que o objeto pode ocupar

LINHA_TECLADO			EQU 	10H		; prepara a primeira linha a ser testada (Vai haver um SHR)    
MASCARA				EQU 	0FH		; isola os 4 bits de menor peso, ao ler as colunas do teclado

TECLA_ESQUERDA			EQU 	0000H		; valor da tecla 0 	
TELCA_DISPARO			EQU 	0001H		; valor da tecla 1										
TECLA_DIREITA			EQU 	0002H		; valor da tecla 2 

TECLA_START			EQU 	000CH      	; valor da tecla C
TECLA_PAUSA         		EQU 	000DH      	; valor da tecla D
TECLA_METEORO			EQU 	0005H      	; valor da tecla 5
	
TECLA_AUMENTA			EQU 	0003H		; valor da tecla 3										
TECLA_DIMINUI			EQU 	00007		; valor da tecla 7 

LARGURA				EQU	5		; largura da nave
ALTURA				EQU  	4         	; altura da nave
LARGURA_METEORO			EQU  	5         	; largura do meteoro
ALTURA_METEORO			EQU  	5         	; altura do meteoro
COR_NADA			EQU  	00000H		; cor do vazio: Transparente (Estética)
COR_YLW				EQU	0FFF0H		; cor da nave: Amarelo
COR_RED				EQU	0FF00H		; cor da nave: Amarelo
ATRASO				EQU	0400H		; atraso para limitar a velocidade de movimento da nave



DEFINE_LINHA    		EQU 	600AH      	; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 	600CH      	; endereço do comando para definir a coluna
SELECIONA_ECRA			EQU 	6004H      	; endereço do comando para selecionar o ecrã
MOSTRA_ECRA 			EQU 	6006H	   	; endereço do comando para mostrar ecrã selecionado
ESCONDE_ECRA			EQU 	6008H		; endereço do comando para esconder ecrã selecionado
DEFINE_PIXEL   			EQU 	6012H      	; endereço do comando para escrever um pixel
APAGA_AVISO    			EQU 	6040H      	; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 	6002H      	; endereço do comando para apagar todos os pixels já desenhados
SC_FUNDO  			EQU 	6042H      	; endereço do comando para selecionar uma imagem de fundo	
TOCA_SOM			EQU 	605AH      	; endereço do comando para tocar um som

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H					; espaço reservado para a pilha (100H WORDS, 200H BYTES)
SP_inicial:						; inicializa SP com o endereço do fim da pilha (1200H). 
							; O 1º end. de retorno será armazenado em 11FEH (1200H-2)
							
DEF_NAVE:									; tabela que guarda as inf. da nave
	WORD		ALTURA 							; guarda a altura da nave								
	WORD 		LARGURA							; guarda a largura da nave
	WORD		COR_NADA, COR_NADA, COR_YLW, COR_NADA, COR_NADA		; guarda a info. da primeira linha
	WORD		COR_YLW, COR_NADA, COR_YLW, COR_NADA, COR_YLW  		; guarda a info. da segunda linha
	WORD		COR_YLW, COR_YLW, COR_YLW, COR_YLW, COR_YLW  		; guarda a info. da terceira linha
	WORD		COR_NADA, COR_YLW, COR_NADA, COR_YLW, COR_NADA  	; guarda a info. da quarta linha

DEF_METEORO:									; tabela que guarda as inf. do meteoro max
	WORD		ALTURA_METEORO						; guarda a altura do meteoro
	WORD		LARGURA_METEORO						; guarda a largura do meteoro
		WORD	COR_RED, COR_NADA, COR_NADA, COR_NADA, COR_RED		; guarda a info. da primeira linha
	WORD		COR_RED, COR_NADA, COR_RED, COR_NADA, COR_RED  		; guarda a info. da segunda linha
	WORD		COR_NADA, COR_RED, COR_RED, COR_RED, COR_NADA  		; guarda a info. da terceira linha
	WORD		COR_RED, COR_NADA, COR_RED, COR_NADA, COR_RED		; guarda a info. da QUARTA linha
	WORD		COR_RED, COR_NADA, COR_NADA, COR_NADA, COR_RED  	; guarda a info. da quinta linha
     

; *********************************************************************************
; *
; * -------------------------------- Código Geral --------------------------------
; *
; *********************************************************************************
	PLACE   0                     	; o código tem de começar em 0000H
inicio:
	MOV  	SP, SP_inicial		; inicializa SP        
    	MOV  	[APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    	MOV  	[APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
    	MOV  	[SC_FUNDO], R1		; seleciona o cenário de fundo

    	MOV  	R1, LINHA_INICIAL	; linha da nave
   	MOV  	R2, COLUNA_INICIAL	; coluna da nave
    	MOV  	R3, 0             	; valor inicial do display
	MOV	R4, DEF_NAVE		; endereço da tabela que define a nave
	MOV  	R5, LINHA_MET      	; linha do meteoro
	MOV  	R6, COLUNA_MET     	; coluna do meteoro
	MOV	R7, 1			; valor a somar à coluna da nave, para o movimentar
	MOV  	R10, 0             	; inicia o jogo sem pausa (1 = Jogo pausado, 0 = Jogo resumido)
	CALL 	escreve_display		; inicia o dislay a 0

espera_start:
	CALL	teclado			; leitura das teclas
	PUSH 	R11			; guarda o valor de R11
	MOV  	R11, TECLA_START	; passa para R11 o valor da tecla start (C)
	CMP	R0, R11 		; verifica se é a tecla start (C)
	POP  	R11 			; retorna o valor original de R11
	JNZ	espera_start		; caso a tecla primida não a C, repete o ciclo

	PUSH 	R1                 	; guarda o valor de R1
	MOV	R1, 1			; cenário de fundo número 1
   	 MOV  	[SC_FUNDO], R1		; seleciona o cenário de fundo
    	POP  	R1			; retorna o valor original de R1
    	CALL 	desenha_obj_atraso	; chama a rotina que se encarrega de desenhar a nave

espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	CALL	teclado			; leitura das teclas
	JZ 	testa_pausa		; testa qual tecla foi primida
	JMP  	espera_tecla   		; espera até haver um input de tecla

espera_tecla_press:			; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	CALL	teclado			; leitura das teclas
	CMP	R0, 0FFFFH		; verifica se a tecla deixou de ser carregada
	JNZ	espera_tecla_press	; espera, enquanto houver tecla uma tecla carregada
	JZ   	espera_tecla		; volta a ficar à espera de um input de tecla

; *********************************************************************************
; * -------------------------------- Testa Teclas --------------------------------
; *********************************************************************************

testa_pausa:				; verifica se o jogador está a tentar meter pausa
	PUSH 	R11			; guarda o valor do registo 11
	MOV  	R11, TECLA_PAUSA	; passa para o registo 11 o valor da tecla de pausa
	CMP	R0, R11 		; verifica se a tecla pressionada é a de pausa
	POP  	R11 			; retorna o valor inicial do registo R11 
	JNZ	testa_tira_pausa	; se a tecla pressionada não for a de pausa vai saltar para um teste
	CALL 	pausa_toggle		; chama a rotina que muda o estado de pausa do jogo
	JMP 	espera_tecla_press  	; salta e fica à espera de um novo input de tecla

testa_tira_pausa:           		; verifica se o jogador está em pausa para bloquear qualquer outra tecla
	CMP 	R10, 1             	; verifica se o jogador está em pausa
	JZ 	espera_tecla       	; se estiver fica à espera de um novo input de tecla
	
testa_esquerda: 			; verifica se o jogador está a tentar andar para a esquerda
	CMP	R0, TECLA_ESQUERDA  	; verifica se é a tecla da esquerda
	JNZ	testa_direita		; se não for salta para testar a direita
	MOV	R7, -1			; se for vai deslocar para a esquerda
	CALL	ve_limites		; e vai ver os limites
	JMP 	espera_tecla    	; fica à espera de um novo input de tecla


testa_direita:				; verifica se o jogador está a tentar andar para a direita
	CMP	R0, TECLA_DIREITA	; verifica se é a tecla da direita
	JNZ	testa_meteoro		; se não for salta para testar meteoro 
	MOV	R7, +1			; se for vai deslocar para a direita
	CALL	ve_limites		; e vai ver os limites
	JMP 	espera_tecla    	; fica à espera de um novo input de tecla

testa_meteoro:				; verifica se o jogador está a tentar mover o meteoro
	CMP	R0, TECLA_METEORO	; verifica se é a tecla do meteoro
	JNZ  	testa_aumenta		; se não for salta para testar a tecla de aumentar
	CALL 	prepara_meteoro    	; chama a rotina que trata de desenhar o meteoro
	JMP	espera_tecla_press	; salta para o loop que trata dos presses 

testa_aumenta:				; verifica se o jogador está a tentar aumentar o display
	CMP	R0, TECLA_AUMENTA	; verifica se é a tecla de aumentar o display
	JNZ	testa_desce		; se não for salta para testar a tecla de descer 
	ADD  	R3, 1              	; adiciona 1 ao registo que guarda o valor do display
	CALL  	escreve_display		; chama a rotina que atualiza o display
	JMP	espera_tecla_press	; chama a rotina que trata dos presses 

testa_desce:				; verifica se o jogador está a tentar diminuir o display
	CMP	R0, TECLA_DIMINUI	; verifica se é a tecla de diminuir o display
	JNZ	espera_tecla		; se não for nada volta a pedir um input de tecla 
	SUB 	R3, 1           	; subtrai 1 ao registo que guarda o valor do display
	CALL  	escreve_display		; chama a rotina que atualiza o display
	JMP	espera_tecla_press  	; chama a rotina que trata dos presses 
	
; *********************************************************************************
; *
; * ---------------------------------- Rotinas ----------------------------------
; *
; *********************************************************************************
;
; 
;
;
; **********************************************************************
; escreve_display: 	- Atualiza o valor no output dos displays.
; Argumentos:   	R3 - valor atualizado para os displays
;
; Retorna: 
; **********************************************************************

escreve_display:			; atualiza o valor no output do display
	PUSH 	R11			; guarda o valor do registo 11
	MOV  	R11, DISPLAYS 		; guarda em R11 o valor do enderço do output
	MOV 	[R11], R3		; atualiza o valor no output dos displays
	POP 	R11			; retorna o valor original do registo 1
	RET				; retorna


; **********************************************************************
; escreve_pixel - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; Retorna: NADA
; **********************************************************************

escreve_pixel:				; comandos que desenham o pixel
	MOV  	[DEFINE_LINHA], R1	; seleciona a linha
	MOV  	[DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  	[DEFINE_PIXEL], R3	; altera a cor do pixel na coordenada (R1,R2)
	RET                   		; retorna


; **********************************************************************
; atraso 	- Executa um ciclo para implementar um atraso.
; Argumentos:  	R11 - valor que define o atraso
;
; Retorna: 	NADA 
; **********************************************************************

atraso:					; prepara o registo para começar o ciclo
	PUSH	R11			; guarda o valor de R11
ciclo_atraso:				; ciclo que gera o atraso
	SUB	R11, 1			; subtrai uma unidado ao valor em R11
	JNZ	ciclo_atraso		; volta ao ciclo até chegar a zero
	POP	R11			; retorna o valor original de R11
	RET				; retorna


; **********************************************************************
; pausa_toggle	- Coloca e tira o jogo de pausa
; Argumentos:	R10 - Valor que indica se o jogo está ou não pausado
;			(0 Não está pausado, 1 Está pausado)
;
;
; Retorna: 	R10 - Valor que representa o estado da pausa atualizado
; **********************************************************************

pausa_toggle: 				; verifica se o jogo está ou não pausado 
	CMP 	R10, 0			; verifica se o jogo está não pausado
	JZ  	mete_pausa		; pausa o jogo
	CMP 	R10, 1			; verifica se o jogo está pausado
	JZ  	tira_pausa		; tira a pausa do jogo

mete_pausa:				; pausa o jogo
	PUSH 	R1			; guarda o valor de R1
	MOV  	R1, 0			; seleciona o ecrã a ser escondido
	MOV  	[ESCONDE_ECRA], R1	; esconde o ecrã selecionado
	MOV	R1, 2			; cenário de fundo número 2
    	MOV  	[SC_FUNDO], R1		; seleciona o cenário de fundo
    	POP  	R1   			; retorna o valor original de R1
	MOV  	R10, 1			; atualiza o valor que representa a pausa (1 = Pausado)
	RET                      	; retorna 

tira_pausa:    				; tira a pausa do jogo
	PUSH 	R1     			; guarda o valor de R1
	MOV	R1, 1			; cenário de fundo número 1
    	MOV  	[SC_FUNDO], R1		; seleciona o cenário de fundo
    	MOV  	R1, 0     		; seleciona o ecrã a ser mostrado
	MOV  	[MOSTRA_ECRA], R1   	; mostra o ecrã selecionado
    	POP  	R1   			; retorna o valor original de R1
	MOV  	R10, 0 			; atualiza o valor que representa a pausa (0 = Não Pausado)
	RET       			; retorna


; **********************************************************************
; prepara_meteoro  	- Toca um som e simultaneamnete guarda o valor dos registos
;                   	que guardam a informação da nave e coloca lá as do metoerito.
; Argumentos:   	R5 - Verifica se está a ser desenha pela primeira vez ou não
;
; Retorna: 
; **********************************************************************

prepara_meteoro:                	; guarda o valor do registo 1 
	PUSH 	R1    	   		; guarda o valor do registo 1 
	PUSH 	R2   	   		; guarda o valor do registo 2 
	PUSH 	R3    	   		; guarda o valor do registo 3 
	PUSH 	R4   	   		; guarda o valor do registo 4 
	MOV  	R2, R6		   	; coloca no registo das colunas a coluna do meteoro
	MOV  	R4, DEF_METEORO		; coloca no registo da tabela a tabela do meteoro
	MOV  	R3, 0               	; passa o valor 0 para R1 para selecionar o primeiro som
	MOV  	[TOCA_SOM], R3       	; comando para fazer o som numero 0
	CMP  	R5, -1      	   	; verifica se é a primeira vez que é desenha (não precisa de apagar)
	JZ   	desenha_meteoro		; salta o passo de apagar se ainda não tiver sido desenhado
	MOV  	R1, R5                 	; atualiza o valor das linhas usadas no desenho
	CALL 	apaga_objetos		; chama a rotina que apaga objetos
desenha_meteoro:	        	; prepara o desenho do meteoro
	ADD  	R5, 1	   		; atualiza a linha onde se encontra o meteoro
	MOV  	R1, R5                 	; atualiza o valor das linhas usadas no desenho
	CALL 	desenha_obj_atraso	; chama a rotina a que desenha obejtos
	POP  	R4			; devolve o valor original do registo 4
	POP  	R3			; devolve o valor original do registo 3
	POP  	R2			; devolve o valor original do registo 2
	POP  	R1			; devolve o valor original do registo 1
	RET 				; retorna

; **********************************************************************
; desenha_objetos 	- Desenha objetos atraves da linha e coluna indicadas
;			    	com a forma e cor definidas na tabela indicada.
; Argumentos:   	R1 - linha
;               	R2 - coluna
;               	R4 - tabela que define o objeto
; Retorna:
; **********************************************************************

desenha_objeto: 				
desenha_obj_atraso:			; primeira chamada feita automaticamente
	CALL	desenha_objetos_aux	; desenha a nave a partir da tabela
	PUSH 	R11			; guarda valores R11 anteriores 
	MOV 	R11, ATRASO 		; guarda em R11 o valor do atraso
	CALL	atraso              	; chama a rotina atraso
	POP 	R11                	; retorna o valor inicial do registo R11
desenha_objetos_aux:			; prepara os registos para começar a desenhar a nave
	PUSH 	R1			; guarda o valor do registo 1 (Linha)
	PUSH 	R3			; guarda o valor do registo 3 (Coluna)
	PUSH 	R4			; guarda o valor do registo 4 (Tabela)
	PUSH 	R5			; guarda o valor do registo 5 (Altura)
	PUSH 	R6			; guarda o valor do registo 6 (Largura)
	MOV  	R5, [R4]		; guarda a altura no registo 5
	ADD  	R4, 2			; passa para R4 o valor da largura
	MOV  	R6, [R4]		; guarda a largura no registo 6
	ADD  	R4, 2			; prepara o registo 4 para receber as cores
desenha_pixels: 			; guarda valores que serão iterados nos ciclos
	PUSH 	R2			; guarda o valor da coluna
	PUSH 	R6			; guarda o valor de colunas que faltam desenhar
desenha_pixels_aux:     		; desenha todos os pixels da nave a partir da tabela
	MOV	R3, [R4]		; guarda no R3 a cor do próximo pixel da nave
	CALL 	escreve_pixel		; escreve cada pixel da nave usando R1, R2 e R3
	ADD	R4, 2			; endereço da cor do próximo pixel 
    	ADD  	R2, 1      	       	; próxima coluna
   	SUB  	R6, 1			; menos uma coluna para tratar
    	JNZ  	desenha_pixels_aux 	; continua até percorrer toda a largura do objeto
    	ADD  	R1, 1     	      	; proxima linha para tratar
    	POP  	R6	        	; volta a guardar o valor da largura no R6
   	POP  	R2        		; volta a guardar o valor da coluna inicial no R2
    	SUB  	R5, 1         	    	; menos uma linha para tratar
    	JNZ  	desenha_pixels 	    	; volta a percorrer o loop até chegar a 0
	POP  	R6			; retorna o valor original do registo R6
	POP	R5			; retorna o valor original do registo R5
	POP	R4			; retorna o valor original do registo R4
	POP  	R3			; retorna o valor original do registo R3
	POP  	R1			; retorna o valor original do registo R1
	RET		 		; retorna à chamada


; **********************************************************************
; apaga_objetos 	- Apaga uma nave na linha e coluna indicadas com a 
;  			forma definida na tabela indicada.
; Argumentos:  		R1 - linha
;              		R2 - coluna
;              		R4 - tabela que define a nave
;
; Retorna: 		NADA
; **********************************************************************

apaga_objetos:				; prepara os registos para começar a apagar a nave
	PUSH 	R1			; guarda o valor do registo 1
	PUSH 	R3			; guarda o valor do registo 3
	PUSH 	R4            		; guarda o valor do registo 4
	PUSH 	R5			; guarda o valor do registo 5
	PUSH 	R6			; guarda o valor do registo 6
	MOV  	R3, 0 			; guarda em R3 o valor da cor do pixel (transparente)
	MOV  	R5, [R4]		; guarda a altura no registo 5
	ADD  	R4, 2			; passa para R4 o valor da largura
	MOV  	R6, [R4]		; guarda a largura no registo 6
apaga_pixels: 				; guarda valores que serão iterados nos ciclos
	PUSH 	R2			; guarda o valor da coluna
	PUSH 	R6			; guarda o valor de colunas que faltam apagar
apaga_pixels_aux:       		; apaga todos os pixels da nave a partir da tabela
	CALL 	escreve_pixel		; apaga cada pixel da nave
	ADD  	R2, 1              	; próxima coluna
    	SUB  	R6, 1			; menos uma coluna para tratar
    	JNZ  	apaga_pixels_aux  	; continua até apagar toda a largura do objeto
    	ADD  	R1, 1          		; proxima linha para tratar
    	POP  	R6       		; volta a guardar o valor da largura no R6
   	POP  	R2			; volta a guardar o valor da coluna inicial no R2
    	SUB  	R5, 1          		; menos uma linha para tratar
    	JNZ  	apaga_pixels      	; volta a percorrer o loop até chegar a 0
	POP  	R6			; retorna o valor original do registo R6
	POP	R5			; retorna o valor original do registo R5
	POP  	R4 			; retorna o valor original do registo R4
	POP  	R3			; retorna o valor original do registo R3
	POP  	R1			; retorna o valor original do registo R1
	RET		 		; retorna à chamada

; **********************************************************************
; Nota dos programadores: Estas próximas duas rotinas foram cópiadas 
; diretamente dos labs com quase 0 alterações já que para esta fase
; não foi preciso adaptar.
;
; **********************************************************************
; testa_limites 	- Testa se a nave chegou aos limites do ecrã e 
;			nesse caso impede o movimento (força R7 a 0)
; Argumentos:		R2 - coluna em que o objeto está
;			R6 - largura da nave
;			R7 - sentido de movimento da nave (valor a somar à coluna
;			em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************

testa_limites:				; testa os limites
	PUSH	R5			; guarda o valor do registo 5
	PUSH	R6			; guarda o valor do registo 6
testa_limite_esquerdo:			; vê se a nave chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA   	; guarda em R5 a coluna min até onde a nave pode ir
	CMP	R2, R5              	; compara com o limite direito
	JGT	testa_limite_direito	; 
	CMP	R7, 0			; 
	JGE	sai_testa_limites	;
	JMP	impede_movimento	; 
testa_limite_direito:			; vê se a nave chegou ao limite direito
	ADD	R6, R2			; 
	MOV	R5, MAX_COLUNA		;
	CMP	R6, R5			;
	JLE	sai_testa_limites	; 
	CMP	R7, 0			; 
	JGT	impede_movimento	;
	JMP	sai_testa_limites	;
impede_movimento:			;
	MOV	R7, 0			; impede o movimento, forçando R7 a 0
sai_testa_limites:			;
	POP	R6			; retorna o valor original do registo R6
	POP	R5			; retorna o valor original do registo R5
	RET				; retorna

; **********************************************************************
; ve_limites  	- Verifica se a nave atingiu o limite e atualiza R7
; Argumentos:   R2 - Valor da coluna da Nave
;  				R4 - Tabela que define a nave
;
; Retorna:     	R7 - valor que indica o incremento da coluna
; **********************************************************************

ve_limites:				; ve os limites e adapta o R7
	PUSH 	R6			; guarda o valor do registo 6
	MOV	R6, [R4]		; obtém a largura da nave
	CALL	testa_limites		; chama a rotina que testa os limites
	POP  	R6			; retorna o valor original do registo R6
	CMP	R7, 0               	; o objeto vai parar de se movimentar 
	JZ   	limit_fim 		; salta para o retorno
	CALL	apaga_objetos		; apaga a nave na sua posição corrente
	
coluna_seguinte:			; atualiza R2 com o valor da proxima linha a ser desenhada
	ADD	R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)
	CALL	desenha_obj_atraso	; vai desenhar a nave de novo
	JMP  	limit_fim		; salta para o retorno

linha_seguinte:				; TBD
	; WIP				; TBD

limit_fim:				; retorna
	RET				; retorna

		
; **********************************************************************
; teclado 	- Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R1 - linha que começa a dar SHR testar 
;
;
; Retorna: 	R0 - valor que representa a tecla no teclado (00H a 0FH)	
; **********************************************************************

teclado:				; código que deteta o input de teclas
	PUSH 	R1               	; guarda o valor do registo 1
	PUSH 	R2                 	; guarda o valor do registo 2
	PUSH 	R3                 	; guarda o valor do registo 3
	PUSH 	R4                 	; guarda o valor do registo 4
	PUSH 	R5                 	; guarda o valor do registo 5
	MOV  	R0, 0FFFFH         	; copia o número que representa nenhuma tecla
	MOV  	R1, TEC_LIN   		; copia para R1 o endereço do periférico das linhas
	MOV  	R2, TEC_COL   		; copia para R2 o endereço do periférico das colunas
	MOV  	R3, MASCARA   		; isola os 4 bits de menor peso, ao ler as colunas do teclado
teclado_aux1:				; prepara a linha a ser testada 
	MOV  	R4, LINHA_TECLADO	; copia para R4 o valor da 1ª linha antes do SHR
teclado_aux2:				; vai tentar encontrar uma tecla primida
	SHR  	R4, 1 			; muda para o valor da linha seguinte 
	JZ   	teclado_fim		; caso tenha chegado ao fim vai terminar
	MOVB 	[R1], R4     		; escreve no periférico de saída (linhas)
	MOVB 	R5, [R2]      		; ler do periférico de entrada (colunas)
	AND  	R5, R3       		; elimina bits para além dos bits 0-3
	JZ 	teclado_aux2		; volta a percorrer o loop
	MOV 	R0,0            	; inicia R0 a 0 para servir como resultado
converte_c:            			; usa a informacao da coluna para converter R0 no resultado final 
   	 SHR 	R5, 1          		; dá um SHR já que a posição 1 é na verdade 0
    	JZ  	converte_l   		; caso R5 seja 0 vai saltar para converte_l
    	ADD 	R0, 1        	  	; incrementa 1 valor no resultado (representa um salto de linhas)
    	JMP 	converte_c   		; caso R5 ainda não seja 0 vai voltar a repetir o processo
converte_l:         			; usa a informacao da linha para converter R0 no resultado final
    	SHR 	R4, 1       		; dá um SHR já que a posição 1 é na verdade 0
    	JZ 	teclado_fim     	; caso R4 seja 0 vai saltar para ha_tecla
    	ADD 	R0, 4       		; incrementa 4 valores no resultado (representa um salto de colunas)
    	JMP 	converte_l   		; caso R4 ainda não seja 0 vai voltar a repetir o processo
teclado_fim: 				; retorna os registos ao seu valor inicial
	POP 	R5			; retorna o valor original do registo R5
	POP 	R4			; retorna o valor original do registo R4
	POP	R3			; retorna o valor original do registo R3
	POP	R2			; retorna o valor original do registo R2
	POP	R1                  	; retorna o valor original do registo R1
	RET				; retorna

; **********************************************************************
